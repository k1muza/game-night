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
  bool _refereeReady = false;
  bool _refereeCorrectionPending = false;

  bool get refereeReady => _refereeReady;

  /// The networking service enables referee control only after a valid snapshot
  /// has been acknowledged by the paired device.
  void setRefereeConnectionReady(bool ready) {
    final next =
        ready &&
        _session?.config.mode == PlayMode.referee &&
        _session?.phase != Phase.gameResults;
    if (_refereeReady == next) return;
    _refereeReady = next;
    notifyListeners();
  }

  bool get refereeCorrectionPending => _refereeCorrectionPending;

  void setRefereeCorrectionPending(bool pending) {
    final next =
        pending &&
        _session?.config.mode == PlayMode.referee &&
        _session?.phase == Phase.turnReview;
    if (_refereeCorrectionPending == next) return;
    _refereeCorrectionPending = next;
    notifyListeners();
  }

  /// Explicitly resolves or acknowledges a pending referee correction request
  /// so the host can confirm the turn result.
  void resolveRefereeCorrection() {
    if (!_refereeCorrectionPending) return;
    _refereeCorrectionPending = false;
    notifyListeners();
  }

  /// Number of milliseconds input stays locked after a turn ends, so late taps
  /// from the clue-giver aren't mistaken for anything else.
  static const lateTapGuardMs = 900;

  // ---------------------------------------------------------------- lifecycle

  /// Restores an unfinished session (e.g. after a refresh). An expired clock is
  /// settled immediately; no extra time is granted.
  void restore() {
    _refereeReady = false;
    _refereeCorrectionPending = false;
    _session = store.loadSession();
    var needsCommit = false;
    for (final game in GameKind.values) {
      _reconcilePersistentDeck(game);
    }
    if (_session != null) {
      if (!_cardsExist(_session!) || !_contentMatches(_session!)) {
        _session = null;
        store.saveSession(null);
      } else {
        _sanitizeSessionCards(_session!);
        final turn = _session!.turn;
        if (turn != null) {
          if (turn.turnId == null) {
            turn.turnId = _newId();
            needsCommit = true;
          }
          if (turn.cardId != null && turn.cardInstanceId == null) {
            turn.cardInstanceId = _newId();
            needsCommit = true;
          }
          if (_session!.config.mode == PlayMode.referee &&
              _session!.phase == Phase.playing &&
              turn.deadlineMs != null) {
            turn.pausedRemainingMs = max(0, turn.deadlineMs! - now());
            turn.deadlineMs = null;
            needsCommit = true;
          }
        }
      }
    }
    if (needsCommit) _commit();
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
    _refereeReady = false;
    _refereeCorrectionPending = false;
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
    _refereeReady = false;
    _refereeCorrectionPending = false;
    _session = null;
    store.saveSession(null);
    notifyListeners();
  }

  /// Stops remote control while preserving all local session progress.
  void switchToClassic() {
    final s = _session;
    if (s == null || s.config.mode == PlayMode.classic) return;
    _refereeReady = false;
    _refereeCorrectionPending = false;
    if (s.phase == Phase.turnReview) confirmReview();
    s.config = GameConfig(
      game: s.config.game,
      rounds: s.config.rounds,
      seconds: s.config.seconds,
      questionsPerTurn: s.config.questionsPerTurn,
      difficulty: s.config.difficulty,
      mode: PlayMode.classic,
    );
    _commit();
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
    _refereeCorrectionPending = false;
    if (s.phase == Phase.playing) _endTurn(EndReason.finished);
    if (s.phase == Phase.turnReview) confirmReview();
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
    if (s == null ||
        s.phase != Phase.ready ||
        (s.config.mode == PlayMode.referee && !_refereeReady)) {
      return false;
    }
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
    final t = Turn(turnId: _newId());
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
      t.cardInstanceId = _newId();
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

  void pause({String? expectedTurnId}) {
    final t = _session?.turn;
    if (!_live ||
        t == null ||
        (expectedTurnId != null && t.turnId != expectedTurnId)) {
      return;
    }
    t.pausedRemainingMs = max(0, t.deadlineMs! - now());
    t.deadlineMs = null;
    _commit();
  }

  void resume({String? expectedTurnId}) {
    final s = _session;
    final t = s?.turn;
    if (s == null ||
        t == null ||
        s.phase != Phase.playing ||
        t.pausedRemainingMs == null ||
        (expectedTurnId != null && t.turnId != expectedTurnId) ||
        (s.config.mode == PlayMode.referee && !_refereeReady))
      return;
    if (t.pausedRemainingMs! <= 0) {
      _endTurn(EndReason.time);
      return;
    }
    t.deadlineMs = now() + t.pausedRemainingMs!;
    t.pausedRemainingMs = null;
    _commit();
  }

  /// Ends the current turn early (Finish Turn / End turn).
  void finishTurn({String? expectedTurnId}) {
    final s = _session;
    if (s == null ||
        s.phase != Phase.playing ||
        (expectedTurnId != null && s.turn?.turnId != expectedTurnId)) {
      return;
    }
    tick();
    if (s.phase != Phase.playing) return;
    _endTurn(EndReason.finished);
  }

  void nextTurn() {
    final s = _session;
    if (s == null || s.phase != Phase.turnResults) return;
    _refereeCorrectionPending = false;
    s.turn = null;
    s.teamIndex++;
    if (s.teamIndex >= s.teams.length) {
      s.teamIndex = 0;
      s.round++;
    }
    s.phase = s.round > s.config.rounds ? Phase.gameResults : Phase.ready;
    _commit();
  }

  /// Confirms a referee-mode review and posts its score exactly once.
  bool confirmReview({String? expectedTurnId}) {
    final s = _session;
    if (s == null ||
        s.phase != Phase.turnReview ||
        s.history.isEmpty ||
        _refereeCorrectionPending ||
        (expectedTurnId != null && s.turn?.turnId != expectedTurnId)) {
      return false;
    }
    final record = s.history.last;
    s.scores[record.team] += record.points;
    s.phase = Phase.turnResults;
    _commit();
    return true;
  }

  /// Corrects a Sprint term during the referee review window only.
  bool reviewSprintTerm(int index, Outcome outcome) {
    final s = _session;
    if (s == null ||
        s.phase != Phase.turnReview ||
        s.game != GameKind.sprint ||
        index < 0 ||
        index >= 5 ||
        (outcome != Outcome.correct &&
            outcome != Outcome.disqualified &&
            outcome != Outcome.pass)) {
      return false;
    }
    final record = s.history.last;
    final eventIndex = record.events.indexWhere((event) => event.term == index);
    if (eventIndex < 0) return false;
    final events = List<TurnEvent>.of(record.events);
    events[eventIndex] = TurnEvent(
      events[eventIndex].cardId,
      outcome,
      term: index,
      cardInstanceId: events[eventIndex].cardInstanceId,
      origin: events[eventIndex].origin,
    );
    s.history[s.history.length - 1] = TurnRecord(
      team: record.team,
      round: record.round,
      points: events.fold(0, (total, event) => total + event.outcome.points),
      events: events,
    );
    final turn = s.turn!;
    turn.marked.remove(index);
    turn.disqualified.remove(index);
    if (outcome == Outcome.correct) turn.marked.add(index);
    if (outcome == Outcome.disqualified) turn.disqualified.add(index);
    _commit();
    return true;
  }

  /// Corrects a Tabuu result before the host settles its referee review.
  bool reviewTabuuEvent(int index, Outcome outcome) {
    final s = _session;
    if (s == null ||
        s.phase != Phase.turnReview ||
        s.game != GameKind.forbidden ||
        index < 0 ||
        index >= s.history.last.events.length ||
        (outcome != Outcome.correct &&
            outcome != Outcome.pass &&
            outcome != Outcome.violation)) {
      return false;
    }
    final record = s.history.last;
    final events = List<TurnEvent>.of(record.events);
    final previous = events[index];
    events[index] = TurnEvent(
      previous.cardId,
      outcome,
      cardInstanceId: previous.cardInstanceId,
      origin: previous.origin,
    );
    s.history[s.history.length - 1] = TurnRecord(
      team: record.team,
      round: record.round,
      points: events.fold(0, (total, event) => total + event.outcome.points),
      events: events,
    );
    if (s.turn!.events.length > index) s.turn!.events[index] = events[index];
    _commit();
    return true;
  }

  // ------------------------------------------------------------------- Sprint

  /// Marks or un-marks a term. Corrections are allowed while the clock runs.
  void toggleTerm(int index, {String? expectedCardInstanceId}) {
    final s = _session;
    if (s?.game != GameKind.sprint ||
        s?.config.mode == PlayMode.referee ||
        !_live) {
      return;
    }
    final t = s!.turn!;
    if (t.cardId == null ||
        (expectedCardInstanceId != null &&
            t.cardInstanceId != expectedCardInstanceId) ||
        index < 0 ||
        index >= 5) {
      return;
    }
    if (!t.marked.remove(index)) t.marked.add(index);
    t.disqualified.remove(index);
    if (t.marked.length + t.disqualified.length == 5) {
      _endTurn(EndReason.allFound);
    } else {
      _commit();
    }
  }

  /// Applies an authorised referee decision to one Sprint term.
  ///
  /// Returns false without mutation when the turn, card or term is stale.
  bool setSprintTerm(
    int index,
    String cardInstanceId, {
    required bool correct,
    bool disqualified = false,
  }) {
    final s = _session;
    if (s?.game != GameKind.sprint ||
        s?.config.mode != PlayMode.referee ||
        !_refereeReady ||
        !_live) {
      return false;
    }
    final t = s!.turn!;
    if (t.cardId == null ||
        t.cardInstanceId != cardInstanceId ||
        index < 0 ||
        index >= 5 ||
        (correct && disqualified)) {
      return false;
    }
    t.marked.remove(index);
    t.disqualified.remove(index);
    if (correct) t.marked.add(index);
    if (disqualified) t.disqualified.add(index);
    if (t.marked.length + t.disqualified.length == 5) {
      _endTurn(EndReason.allFound);
    } else {
      _commit();
    }
    return true;
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
        t.disqualified.isEmpty &&
        t.skips < sprintSkipsPerTurn &&
        store.loadDeck(s.game).any((id) => !s.used.contains(id));
  }

  /// Replaces the Sprint card with a fresh one. The clock keeps running; the
  /// skipped card is used up and won't be dealt again this game.
  void skipSprintCard({String? expectedCardInstanceId}) {
    if (!_live || !canSkipSprintCard) return;
    final t = _session!.turn!;
    if (expectedCardInstanceId != null &&
        t.cardInstanceId != expectedCardInstanceId) {
      return;
    }
    t.cardId = _draw();
    t.cardInstanceId = _newId();
    t.skips++;
    _commit();
  }

  // ------------------------------------------------------ Charades / Forbidden

  /// Records the on-screen card and immediately deals the next one.
  void mark(Outcome outcome, {String? expectedCardInstanceId}) {
    final s = _session;
    if (s == null ||
        (s.config.mode == PlayMode.referee && !_refereeReady) ||
        !_live) {
      return;
    }
    _recordCardOutcome(
      outcome,
      expectedCardInstanceId: expectedCardInstanceId,
      origin: ActionOrigin.host,
    );
  }

  bool markRefereeViolation(String expectedCardInstanceId) {
    final s = _session;
    if (s == null ||
        s.config.mode != PlayMode.referee ||
        !_refereeReady ||
        s.game != GameKind.forbidden ||
        !_live) {
      return false;
    }
    return _recordCardOutcome(
      Outcome.violation,
      expectedCardInstanceId: expectedCardInstanceId,
      origin: ActionOrigin.referee,
    );
  }

  bool _recordCardOutcome(
    Outcome outcome, {
    required String? expectedCardInstanceId,
    required ActionOrigin origin,
  }) {
    final s = _session;
    if (s == null) return false;
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
    if (!allowed ||
        t.cardId == null ||
        (expectedCardInstanceId != null &&
            t.cardInstanceId != expectedCardInstanceId)) {
      return false;
    }
    t.events.add(
      TurnEvent(
        t.cardId!,
        outcome,
        cardInstanceId: t.cardInstanceId,
        origin: origin,
      ),
    );
    t.cardId = _draw();
    t.cardInstanceId = _newId();
    _commit();
    return true;
  }

  /// Undoes the most recent Correct/Pass/Violation and returns that card to the
  /// screen. Only while the clock is still running.
  bool get canUndoLast {
    final s = _session;
    final t = s?.turn;
    if (s == null ||
        (s.game != GameKind.charades && s.game != GameKind.forbidden) ||
        s.phase != Phase.playing ||
        t == null ||
        t.events.isEmpty ||
        t.paused ||
        t.deadlineMs == null ||
        now() >= t.deadlineMs!) {
      return false;
    }
    return !(s.config.mode == PlayMode.referee &&
        t.events.last.origin == ActionOrigin.referee);
  }

  bool undoLast({String? expectedCardInstanceId}) {
    final s = _session;
    if (s == null ||
        (s.game != GameKind.charades && s.game != GameKind.forbidden) ||
        !_live)
      return false;
    final t = s.turn!;
    if (t.events.isEmpty) return false;
    final last = t.events.last;
    if ((expectedCardInstanceId != null &&
            last.cardInstanceId != expectedCardInstanceId) ||
        (s.config.mode == PlayMode.referee &&
            last.origin == ActionOrigin.referee)) {
      return false;
    }
    t.events.removeLast();
    t.cardId = last.cardId;
    t.cardInstanceId = _newId();
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
      t.cardInstanceId = _newId();
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
    t.cardInstanceId = _newId();
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
    t.events.add(
      TurnEvent(
        t.cardId!,
        outcome,
        choice: choice,
        cardInstanceId: t.cardInstanceId,
      ),
    );
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

  /// Ends the live turn; referee sessions hold the score until review is confirmed.
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
              t.marked.contains(i)
                  ? Outcome.correct
                  : (t.disqualified.contains(i)
                        ? Outcome.disqualified
                        : Outcome.pass),
              term: i,
              cardInstanceId: t.cardInstanceId,
              origin: s.config.mode == PlayMode.referee
                  ? ActionOrigin.referee
                  : ActionOrigin.host,
            ),
        ]);
    }
    t.ended = reason;
    t.deadlineMs = null;
    t.pausedRemainingMs = null;
    final points = t.points;
    s.history.add(
      TurnRecord(
        team: s.teamIndex,
        round: s.round,
        points: points,
        events: List.of(t.events),
      ),
    );
    if (s.config.mode == PlayMode.referee &&
        (s.game == GameKind.sprint || s.game == GameKind.forbidden)) {
      s.phase = Phase.turnReview;
    } else {
      s.scores[s.teamIndex] += points;
      s.phase = Phase.turnResults;
    }
    _commit();
  }

  void _commit() {
    final s = _session;
    if (s != null) {
      s.updatedAt = now();
      s.stateVersion++;
    }
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

  String _newId() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
