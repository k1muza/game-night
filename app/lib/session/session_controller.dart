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
  SessionController({required this.library, required this.store, NowMs? now, Random? random})
      : now = now ?? systemNow,
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
    if (_session != null && !_cardsExist(_session!)) {
      // Saved by an older app version whose deck has since changed: the game
      // can't continue safely, so drop it rather than crash on every launch.
      _session = null;
      store.saveSession(null);
    }
    tick();
    notifyListeners();
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

  bool get hasUnfinished => _session != null && _session!.phase != Phase.gameResults;

  void newSession(GameConfig config, List<Team> teams) {
    assert(teams.length >= 2 && teams.length <= 6);
    final seed = _random.nextInt(1 << 31);
    final r = Random(seed);
    _session = Session(
      config: config,
      teams: teams,
      queues: DeckPlanner.buildQueues(library, config.game, config.difficulty, r, store.seen(config.game)),
      seed: seed,
      createdAt: now(),
    );
    _commit();
  }

  /// Same teams and settings, scores reset, fresh cards.
  void rematch() {
    final s = _session;
    if (s == null) return;
    newSession(s.config, [for (final t in s.teams) Team(t.name, t.paletteIndex)]);
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
  int get remainingCards => _session?.queues.values.fold<int>(0, (a, q) => a + q.length) ?? 0;

  bool get canStartTurn {
    final s = _session;
    if (s == null || s.phase != Phase.ready) return false;
    // Trivia needs a full turn's questions so every team gets the same number;
    // other games need at least one card.
    return remainingCards >= (s.game == GameKind.trivia ? s.config.questionsPerTurn : 1);
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
      t.slots.addAll(DeckPlanner.triviaSlots(s.config.questionsPerTurn, s.round, s.config.difficulty));
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
    return s != null && s.phase == Phase.playing && t != null && !t.paused && t.deadlineMs != null;
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
    if (s == null || t == null || s.phase != Phase.playing || t.pausedRemainingMs == null) return;
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

  // ------------------------------------------------------ Charades / Forbidden

  /// Records the on-screen card and immediately deals the next one.
  void mark(Outcome outcome) {
    final s = _session;
    if (s == null || !_live) return;
    final allowed = switch (s.game) {
      GameKind.charades => outcome == Outcome.correct || outcome == Outcome.pass,
      GameKind.forbidden => outcome == Outcome.correct || outcome == Outcome.pass || outcome == Outcome.violation,
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
    if (s == null || (s.game != GameKind.charades && s.game != GameKind.forbidden) || !_live) return false;
    final t = s.turn!;
    if (t.events.isEmpty) return false;
    final last = t.events.removeLast();
    if (t.cardId != null) {
      s.queues['main']!.insert(0, t.cardId!);
      s.used.remove(t.cardId);
    }
    t.cardId = last.cardId;
    _commit();
    return true;
  }

  /// Explicitly returns all dealt cards (except this turn's) to the deck.
  void reshuffle() {
    final s = _session;
    if (s == null) return;
    final keep = <String>{
      if (s.turn?.cardId != null) s.turn!.cardId!,
      ...?s.turn?.events.map((e) => e.cardId),
    };
    final r = Random(s.seed ^ now());
    s.queues
      ..clear()
      ..addAll(DeckPlanner.buildQueues(library, s.game, s.config.difficulty, r, const {}, exclude: keep));
    s.used
      ..clear()
      ..addAll(keep);
    final t = s.turn;
    if (s.phase == Phase.playing && t != null && t.cardId == null && s.game != GameKind.trivia) {
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
    if (s?.game != GameKind.trivia || s!.phase != Phase.playing || t == null || !t.revealed) return;
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
    final choice = timeout || t.selected == null ? null : t.optionOrder[t.selected!];
    final outcome = choice == null ? Outcome.timeout : (choice == 0 ? Outcome.correct : Outcome.wrong);
    t.events.add(TurnEvent(t.cardId!, outcome, choice: choice));
    t.revealed = true;
    t.deadlineMs = null;
    t.pausedRemainingMs = null;
    _commit();
  }

  String? _drawTrivia(Difficulty slot, Set<String> avoidCategories) {
    final s = _session!;
    for (final d in DeckPlanner.nearest(slot)) {
      final q = s.queues[d.name];
      if (q == null || q.isEmpty) continue;
      // Prefer a category not yet used this turn (look a short way ahead).
      var pick = 0;
      for (var i = 0; i < min(q.length, 12); i++) {
        if (!avoidCategories.contains(library.trivia[q[i]]!.category)) {
          pick = i;
          break;
        }
      }
      final id = q.removeAt(pick);
      _markUsed(id);
      return id;
    }
    return null;
  }

  // ------------------------------------------------------------------ helpers

  String? _draw() {
    final q = _session!.queues['main']!;
    if (q.isEmpty) return null;
    final id = q.removeAt(0);
    _markUsed(id);
    return id;
  }

  void _markUsed(String id) {
    final s = _session!;
    s.used.add(id);
    final seen = store.seen(s.game)..add(id);
    // Once the whole deck has been seen on this device, start the cycle again.
    store.saveSeen(s.game, seen.length >= library.count(s.game) ? {id} : seen);
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
          for (var i = 0; i < 5; i++) TurnEvent(t.cardId!, t.marked.contains(i) ? Outcome.correct : Outcome.pass, term: i)
        ]);
    }
    if (s.game == GameKind.trivia && t.cardId != null && !t.revealed && reason != EndReason.questionsDone) {
      // Turn ended mid-question: the unanswered question is returned to the deck.
      s.queues[library.trivia[t.cardId]!.difficulty.name]!.insert(0, t.cardId!);
      s.used.remove(t.cardId);
    }
    t.ended = reason;
    t.deadlineMs = null;
    t.pausedRemainingMs = null;
    final points = t.points;
    s.scores[s.teamIndex] += points;
    s.history.add(TurnRecord(team: s.teamIndex, round: s.round, points: points, events: List.of(t.events)));
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
    return [for (var i = 0; i < s.scores.length; i++) if (s.scores[i] == top) i];
  }

  bool get isFinalTurn {
    final s = _session;
    return s != null && s.round == s.config.rounds && s.teamIndex == s.teams.length - 1;
  }

  /// Team index that plays after the current one, or null if the game ends.
  int? get nextTeamIndex {
    final s = _session;
    if (s == null || isFinalTurn) return null;
    return (s.teamIndex + 1) % s.teams.length;
  }
}
