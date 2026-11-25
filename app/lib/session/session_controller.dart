import 'dart:math';

import 'package:flutter/foundation.dart';

import '../model/cards.dart';
import '../model/game_kind.dart';
import 'deck_planner.dart';
import 'session.dart';
import 'store.dart';

typedef NowMs = int Function();

int systemNow() => DateTime.now().millisecondsSinceEpoch;

/// Owns the single local game session: team rotation, rounds, decks, the turn
/// clock and scoring. UI code calls these methods; every method validates the
/// current phase, so invalid transitions and duplicate scoring are impossible.
///
/// The clock is an absolute deadline (epoch ms), never a decrementing counter:
/// refreshing or backgrounding the browser can't add time, and every scoring
/// action first checks whether the deadline has already passed.
class SessionController extends ChangeNotifier {
  SessionController({
    required this.library,
    required this.store,
    NowMs? now,
    Random? random,
  }) : now = now ?? systemNow,
       _random = random ?? Random();

  final ContentLibrary library;
  final SessionStore store;
  final NowMs now;
  final Random _random;

  Session? _session;
  Session? get session => _session;

  /// Number of milliseconds input stays locked after a turn ends, so late taps
  /// from the clue-giver aren't mistaken for anything else.
  static const lateTapGuardMs = 900;

  // ---------------------------------------------------------------- lifecycle

  /// Restores an unfinished session (e.g. after a refresh). An expired clock is
  /// settled immediately; no extra time is granted.
  void restore() {
    _session = store.loadSession();
    for (final game in GameKind.values) {
      _reconcilePersistentDeck(game);
    }
    if (_session != null) {
      if (!_cardsExist(_session!) || !_contentMatches(_session!)) {
        _session = null;
        store.saveSession(null);
      } else {
        _sanitizeSessionCards(_session!);
      }
    }
    tick();
    notifyListeners();
  }

  void _reconcilePersistentDeck(GameKind game) {
    final canonical = library.ids(game);
    final seen = store.seen(game);
    final existing = store.loadDeck(game);
    final reconciled = existing.isEmpty
        ? DeckPlanner.initialise(library, game, _random, seen)
        : DeckPlanner.reconcile(existing, canonical, _random);
    store.saveDeck(game, reconciled);
  }

  void _syncSessionQueue(Session s) {
    s.queues
      ..clear()
      ..addAll({'main': store.loadDeck(s.game)});
  }

  void _sanitizeSessionCards(Session s) {
    final known = library.ids(s.game).toSet();
    s.used.removeWhere((id) => !known.contains(id));
    s.queues
      ..clear()
      ..addAll({
        'main': store
            .loadDeck(s.game)
            .where((id) => known.contains(id))
            .toList(),
      });
    final t = s.turn;
    if (t != null) {
      if (t.cardId != null && !known.contains(t.cardId)) t.cardId = null;
      t.events.removeWhere((event) => !known.contains(event.cardId));
    }
    s.history.removeWhere(
      (record) => record.events.every((event) => !known.contains(event.cardId)),
    );
    for (final record in s.history) {
      record.events.removeWhere((event) => !known.contains(event.cardId));
    }
  }

  bool _contentMatches(Session s) {
    final fingerprints = s.contentFingerprints;
    if (fingerprints == null) return true;
    final games = library.manifest?['games'] as Map<String, dynamic>?;
    if (games == null) return fingerprints.isEmpty;
    final runtimeName = switch (s.game) {
      GameKind.sprint => 'sprint',
      GameKind.charades => 'charades',
      GameKind.trivia => 'trivia',
      GameKind.forbidden => 'forbidden',
    };
    final current = games[runtimeName] as Map<String, dynamic>?;
    return current != null &&
        fingerprints[runtimeName] == current['runtimeFingerprint'];
  }

  Map<String, String> _currentFingerprints() {
    final games = library.manifest?['games'] as Map<String, dynamic>? ?? {};
    return {
      for (final e in games.entries)
        if (e.value is Map && e.value['runtimeFingerprint'] is String)
          e.key: e.value['runtimeFingerprint'] as String,
    };
  }

  bool _cardsExist(Session s) {
    final known = library.ids(s.game).toSet();
    final t = s.turn;
    final ids = <String>[
      ...s.queues.values.expand((q) => q),
      ...s.used,
      ...s.history.expand((h) => h.events.map((e) => e.cardId)),
      if (t?.cardId != null) t!.cardId!,
      ...?t?.events.map((e) => e.cardId),
    ];
    return ids.every(known.contains);
  }

  bool get hasUnfinished =>
      _session != null && _session!.phase != Phase.gameResults;

  void newSession(GameConfig config, List<Team> teams) {
    assert(teams.length >= 2 && teams.length <= 6);
    final seed = _random.nextInt(1 << 31);
    _reconcilePersistentDeck(config.game);
    _session = Session(
      config: config,
      teams: teams,
      queues: {'main': store.loadDeck(config.game)},
      seed: seed,
      createdAt: now(),
      contentFingerprints: _currentFingerprints(),
    );
    _commit();
  }

  /// Same teams and settings, scores reset, fresh cards.
  void rematch() {
    final s = _session;
    if (s == null) return;
    newSession(s.config, [
      for (final t in s.teams) Team(t.name, t.paletteIndex),
    ]);
  }

  void discard() {
    _session = null;
    store.saveSession(null);
    notifyListeners();
  }

  /// Teams have had unequal numbers of turns (the game stopped mid-round).
  bool get unequalTurns {
    final s = _session;
    if (s == null) return false;
    final counts = List.filled(s.teams.length, 0);
    for (final h in s.history) {
      counts[h.team]++;
    }
    return counts.toSet().length > 1;
  }

  /// Ends the game now and shows standings. A game with no turns played is
  /// simply discarded.
  void endGame() {
    final s = _session;
    if (s == null || s.phase == Phase.gameResults) return;
    if (s.phase == Phase.playing) _endTurn(EndReason.finished);
    if (s.history.isEmpty) {
      discard();
      return;
    }
    s.endedEarly = s.history.length < s.totalTurns;
    s.turn = null;
    s.phase = Phase.gameResults;
    _commit();
  }

  // -------------------------------------------------------------------- turns

  /// Cards still available to deal without repeating.
  int get remainingCards => _session == null
      ? 0
      : store
            .loadDeck(_session!.game)
            .where((id) => !_session!.used.contains(id))
            .length;

  bool get canStartTurn {
    final s = _session;
    if (s == null || s.phase != Phase.ready) return false;
    final q = store.loadDeck(s.game);
    if (s.game == GameKind.trivia) {
      final slots = DeckPlanner.triviaSlots(
        s.config.questionsPerTurn,
        s.round,
        s.config.difficulty,
      );
      final selected = <String>{};
      for (final slot in slots) {
        final id = _firstEligibleTrivia(q, slot, selected);
        if (id == null) return false;
        selected.add(id);
      }
      return true;
    }
    return q.any(
      (id) =>
          !s.used.contains(id) &&
          (s.config.difficulty == null ||
              s.game == GameKind.sprint ||
              library.difficultyOf(s.game, id) == s.config.difficulty),
    );
  }

  String? _firstEligibleTrivia(
    List<String> queue,
    Difficulty slot,
    Set<String> excluded,
  ) {
    final used = _session?.used ?? const <String>{};
    final difficulties = _session?.config.difficulty == null
        ? DeckPlanner.nearest(slot)
        : [slot];
    for (final difficulty in difficulties) {
      for (final id in queue) {
        if (!used.contains(id) &&
            !excluded.contains(id) &&
            library.trivia[id]!.difficulty == difficulty) {
          return id;
        }
      }
    }
    return null;
  }

  /// Starts the clock. Only valid from [Phase.ready] — the timer never runs
  /// during handover.
  bool startTurn() {
    final s = _session;
    if (s == null || s.phase != Phase.ready || !canStartTurn) return false;
    final t = Turn();
    s.turn = t;
    s.phase = Phase.playing;
    if (s.game == GameKind.trivia) {
      t.slots.addAll(
        DeckPlanner.triviaSlots(
          s.config.questionsPerTurn,
          s.round,
          s.config.difficulty,
        ),
      );
      _presentQuestion();
    } else {
      t.cardId = _draw();
      t.deadlineMs = now() + s.config.effectiveSeconds * 1000;
    }
    _commit();
    return true;
  }

  /// Remaining clock time for the current turn / question.
  int remainingMs() {
    final t = _session?.turn;
    if (t == null || _session!.phase != Phase.playing) return 0;
    if (t.pausedRemainingMs != null) return t.pausedRemainingMs!;
    if (t.deadlineMs == null) return 0;
    return max(0, t.deadlineMs! - now());
  }

  int get durationMs => (_session?.config.effectiveSeconds ?? 0) * 1000;

  /// Settles the clock. Safe to call repeatedly (e.g. every animation frame):
  /// expiry is processed exactly once because it changes the phase/reveal state.
  void tick() {
    final s = _session;
    final t = s?.turn;
    if (s == null || t == null || s.phase != Phase.playing) return;
    if (t.deadlineMs == null || now() < t.deadlineMs!) return;
    if (s.game == GameKind.trivia) {
      if (!t.revealed) _reveal(timeout: true);
    } else {
      _endTurn(EndReason.time);
    }
  }

  /// True when the clock is running and accepting scoring actions.
  bool get _live {
    tick();
    final s = _session;
    final t = s?.turn;
    return s != null &&
        s.phase == Phase.playing &&
        t != null &&
        !t.paused &&
        t.deadlineMs != null;
  }

  void pause() {
    final t = _session?.turn;
    if (!_live || t == null) return;
    t.pausedRemainingMs = max(0, t.deadlineMs! - now());
    t.deadlineMs = null;
    _commit();
  }

  void resume() {
    final s = _session;
    final t = s?.turn;
    if (s == null ||
        t == null ||
        s.phase != Phase.playing ||
        t.pausedRemainingMs == null)
      return;
    t.deadlineMs = now() + t.pausedRemainingMs!;
    t.pausedRemainingMs = null;
    _commit();
  }

  /// Ends the current turn early (Finish Turn / End turn).
  void finishTurn() {
    final s = _session;
    if (s == null || s.phase != Phase.playing) return;
    tick();
    if (s.phase != Phase.playing) return;
    _endTurn(EndReason.finished);
  }

  void nextTurn() {
    final s = _session;
    if (s == null || s.phase != Phase.turnResults) return;
    s.turn = null;
    s.teamIndex++;
    if (s.teamIndex >= s.teams.length) {
      s.teamIndex = 0;
      s.round++;
    }
    s.phase = s.round > s.config.rounds ? Phase.gameResults : Phase.ready;
    _commit();
  }

  // ------------------------------------------------------------------- Sprint

  /// Marks or un-marks a term. Corrections are allowed while the clock runs.
  void toggleTerm(int index) {
    final s = _session;
    if (s?.game != GameKind.sprint || !_live) return;
    final t = s!.turn!;
    if (t.cardId == null || index < 0 || index >= 5) return;
    if (!t.marked.remove(index)) t.marked.add(index);
    if (t.marked.length == 5) {
      _endTurn(EndReason.allFound);
    } else {
      _commit();
    }
  }

  /// Sprint skips allowed per turn.
  static const sprintSkipsPerTurn = 1;

  /// A Sprint card can be skipped once per turn, and only before any of its
  /// terms is ticked — so skipping can't be used to bank easy terms from
  /// several cards and beat the five-point cap.
  bool get canSkipSprintCard {
    final s = _session;
    final t = s?.turn;
    return s?.game == GameKind.sprint &&
        s!.phase == Phase.playing &&
        t != null &&
        t.deadlineMs != null &&
        t.marked.isEmpty &&
        t.skips < sprintSkipsPerTurn &&
        store.loadDeck(s.game).any((id) => !s.used.contains(id));
  }

  /// Replaces the Sprint card with a fresh one. The clock keeps running; the
  /// skipped card is used up and won't be dealt again this game.
  void skipSprintCard() {
    if (!_live || !canSkipSprintCard) return;
    final t = _session!.turn!;
    t.cardId = _draw();
    t.skips++;
    _commit();
  }

  // ------------------------------------------------------ Charades / Forbidden

  /// Records the on-screen card and immediately deals the next one.
  void mark(Outcome outcome) {
    final s = _session;
    if (s == null || !_live) return;
    final allowed = switch (s.game) {
      GameKind.charades =>
        outcome == Outcome.correct || outcome == Outcome.pass,
      GameKind.forbidden =>
        outcome == Outcome.correct ||
            outcome == Outcome.pass ||
            outcome == Outcome.violation,
      _ => false,
    };
    final t = s.turn!;
    if (!allowed || t.cardId == null) return;
    t.events.add(TurnEvent(t.cardId!, outcome));
    t.cardId = _draw();
    _commit();
  }

  /// Undoes the most recent Correct/Pass/Violation and returns that card to the
  /// screen. Only while the clock is still running.
  bool undoLast() {
    final s = _session;
    if (s == null ||
        (s.game != GameKind.charades && s.game != GameKind.forbidden) ||
        !_live)
      return false;
    final t = s.turn!;
    if (t.events.isEmpty) return false;
    final last = t.events.removeLast();
    t.cardId = last.cardId;
    _commit();
    return true;
  }

  /// Manually shuffles the persistent deck.
  void reshuffle() {
    final s = _session;
    if (s == null) return;
    final q = store.loadDeck(s.game);
    if (q.isEmpty) q.addAll(library.ids(s.game));
    q.shuffle(Random(s.seed ^ now()));
    if (s.game == GameKind.charades || s.game == GameKind.forbidden) {
      final buckets = <Difficulty, List<String>>{};
      for (final id in q) {
        buckets.putIfAbsent(library.difficultyOf(s.game, id), () => []).add(id);
      }
      final balanced = DeckPlanner.stratified(
        buckets,
        DeckPlanner.mixedWeights[s.game]!,
      );
      store.saveDeck(s.game, balanced);
    } else {
      store.saveDeck(s.game, q);
    }
    _syncSessionQueue(s);
    final t = s.turn;
    if (s.phase == Phase.playing && t != null && t.cardId == null) {
      t.cardId = _draw();
    }
    _commit();
  }

  // ------------------------------------------------------------------- Trivia

  void selectOption(int display) {
    final s = _session;
    if (s?.game != GameKind.trivia || !_live) return;
    final t = s!.turn!;
    if (t.revealed || display < 0 || display >= t.optionOrder.length) return;
    t.selected = display;
    _commit();
  }

  void lockAnswer() {
    final s = _session;
    if (s?.game != GameKind.trivia || !_live) return;
    final t = s!.turn!;
    if (t.revealed || t.selected == null) return;
    _reveal(timeout: false);
  }

  /// Option index (0 = correct) chosen for the current question, if any.
  int? get lockedChoice {
    final t = _session?.turn;
    if (t == null || !t.revealed || t.events.isEmpty) return null;
    return t.events.last.choice;
  }

  void nextQuestion() {
    final s = _session;
    final t = s?.turn;
    if (s?.game != GameKind.trivia ||
        s!.phase != Phase.playing ||
        t == null ||
        !t.revealed)
      return;
    if (t.qIndex + 1 >= t.slots.length) {
      _endTurn(EndReason.questionsDone);
      return;
    }
    t.qIndex++;
    _presentQuestion();
    if (s.phase == Phase.playing) _commit();
  }

  void _presentQuestion() {
    final s = _session!;
    final t = s.turn!;
    final id = _drawTrivia(t.slots[t.qIndex], {
      for (final e in t.events) library.trivia[e.cardId]!.category,
    });
    if (id == null) {
      // Deck exhausted mid-turn: end the turn with what was answered.
      t.cardId = null;
      _endTurn(EndReason.questionsDone);
      return;
    }
    t.cardId = id;
    t.optionOrder = [0, 1, 2, 3]..shuffle(_random);
    t.selected = null;
    t.revealed = false;
    t.deadlineMs = now() + s.config.effectiveSeconds * 1000;
    t.pausedRemainingMs = null;
  }

  /// Locks the selection, or records a timeout, and reveals the answer. Only a
  /// locked answer counts: a tentative tap during the team's argument that
  /// wasn't locked in when time ran out is recorded as unanswered.
  void _reveal({required bool timeout}) {
    final t = _session!.turn!;
    final choice = timeout || t.selected == null
        ? null
        : t.optionOrder[t.selected!];
    final outcome = choice == null
        ? Outcome.timeout
        : (choice == 0 ? Outcome.correct : Outcome.wrong);
    t.events.add(TurnEvent(t.cardId!, outcome, choice: choice));
    t.revealed = true;
    t.deadlineMs = null;
    t.pausedRemainingMs = null;
    _commit();
  }

  String? _drawTrivia(Difficulty slot, Set<String> avoidCategories) {
    final s = _session!;
    final q = store.loadDeck(s.game);
    final difficulties = s.config.difficulty == null
        ? DeckPlanner.nearest(slot)
        : [slot];
    for (final d in difficulties) {
      var candidates = <int>[
        for (var i = 0; i < q.length; i++)
          if (!s.used.contains(q[i]) && library.trivia[q[i]]!.difficulty == d)
            i,
      ];
      if (candidates.isEmpty) continue;
      candidates.sort((a, b) {
        final ac = avoidCategories.contains(library.trivia[q[a]]!.category);
        final bc = avoidCategories.contains(library.trivia[q[b]]!.category);
        return ac == bc ? a.compareTo(b) : (ac ? 1 : -1);
      });
      final index = candidates.first;
      final id = q.removeAt(index);
      q.add(id);
      store.saveDeck(s.game, q);
      s.queues
        ..clear()
        ..addAll({'main': q});
      s.used.add(id);
      return id;
    }
    return null;
  }

  // ------------------------------------------------------------------ helpers

  String? _draw() {
    final s = _session!;
    final q = store.loadDeck(s.game);
    if (q.isEmpty) return null;
    final index = q.indexWhere((id) {
      if (s.used.contains(id)) return false;
      if (s.config.difficulty == null) return true;
      if (s.game == GameKind.sprint) return true;
      return library.difficultyOf(s.game, id) == s.config.difficulty;
    });
    if (index < 0) return null;
    final id = q.removeAt(index);
    q.add(id);
    store.saveDeck(s.game, q);
    s.used.add(id);
    _syncSessionQueue(s);
    return id;
  }

  /// Settles the turn and posts its score exactly once.
  void _endTurn(EndReason reason) {
    final s = _session!;
    final t = s.turn!;
    if (s.phase != Phase.playing) return;
    if (s.game == GameKind.sprint && t.cardId != null) {
      t.events
        ..clear()
        ..addAll([
          for (var i = 0; i < 5; i++)
            TurnEvent(
              t.cardId!,
              t.marked.contains(i) ? Outcome.correct : Outcome.pass,
              term: i,
            ),
        ]);
    }
    t.ended = reason;
    t.deadlineMs = null;
    t.pausedRemainingMs = null;
    final points = t.points;
    s.scores[s.teamIndex] += points;
    s.history.add(
      TurnRecord(
        team: s.teamIndex,
        round: s.round,
        points: points,
        events: List.of(t.events),
      ),
    );
    s.phase = Phase.turnResults;
    _commit();
  }

  void _commit() {
    final s = _session;
    if (s != null) s.updatedAt = now();
    store.saveSession(s);
    notifyListeners();
  }

  // ------------------------------------------------------------- read models

  /// Live score for the turn in progress.
  int get turnScore {
    final s = _session;
    final t = s?.turn;
    if (s == null || t == null) return 0;
    if (s.game == GameKind.sprint && t.ended == null) return t.marked.length;
    return t.points;
  }

  List<Standing> get standings => standingsFor(_session?.scores ?? const []);

  List<int> get winners {
    final s = _session;
    if (s == null || s.scores.isEmpty) return const [];
    final top = s.scores.reduce(max);
    return [
      for (var i = 0; i < s.scores.length; i++)
        if (s.scores[i] == top) i,
    ];
  }

  bool get isFinalTurn {
    final s = _session;
    return s != null &&
        s.round == s.config.rounds &&
        s.teamIndex == s.teams.length - 1;
  }

  /// Team index that plays after the current one, or null if the game ends.
  int? get nextTeamIndex {
    final s = _session;
    if (s == null || isFinalTurn) return null;
    return (s.teamIndex + 1) % s.teams.length;
  }
}
