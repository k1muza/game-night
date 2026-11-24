import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/model/cards.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/session/deck_planner.dart';
import 'package:game_night/session/session.dart';

import 'helpers.dart';

void main() {
  group('session creation and teams', () {
    test('defaults: two teams, five rounds, ready phase, zero scores', () {
      final h = Harness()..start(GameKind.sprint);
      expect(h.s.phase, Phase.ready);
      expect(h.s.teams.map((t) => t.name), ['Team A', 'Team B']);
      expect(h.s.config.rounds, 5);
      expect(h.s.config.effectiveSeconds, 30);
      expect(h.s.scores, [0, 0]);
      expect(h.s.round, 1);
      expect(h.s.teamIndex, 0);
    });

    test('game-specific default timers', () {
      expect(const GameConfig(game: GameKind.charades).effectiveSeconds, 60);
      expect(const GameConfig(game: GameKind.forbidden).effectiveSeconds, 60);
      expect(const GameConfig(game: GameKind.trivia).effectiveSeconds, 20);
      expect(const GameConfig(game: GameKind.trivia).questionsPerTurn, 5);
    });

    test('custom team count and names are kept', () {
      final h = Harness();
      h.controller.newSession(const GameConfig(game: GameKind.charades, rounds: 2),
          [Team('Sadza Squad', 0), Team('Night Owls', 1), Team('Kombi Crew', 3)]);
      expect(h.s.teams.length, 3);
      expect(h.s.scores, [0, 0, 0]);
      expect(h.s.teams[2].name, 'Kombi Crew');
      expect(h.s.totalTurns, 6);
    });
  });

  group('turn rotation and rounds', () {
    test('teams rotate, rounds advance, every team gets equal turns', () {
      final h = Harness()..start(GameKind.charades, teams: 3, rounds: 2);
      final c = h.controller;
      final order = <(int, int)>[];
      while (h.s.phase != Phase.gameResults) {
        expect(h.s.phase, Phase.ready);
        order.add((h.s.round, h.s.teamIndex));
        c.startTurn();
        c.finishTurn();
        expect(h.s.phase, Phase.turnResults);
        c.nextTurn();
      }
      expect(order, [(1, 0), (1, 1), (1, 2), (2, 0), (2, 1), (2, 2)]);
      final perTeam = List.filled(3, 0);
      for (final r in h.s.history) {
        perTeam[r.team]++;
      }
      expect(perTeam, [2, 2, 2]);
    });

    test('invalid transitions are rejected', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller;
      c.nextTurn(); // not in results
      expect(h.s.phase, Phase.ready);
      c.toggleTerm(0); // not playing
      expect(h.s.turn, isNull);
      expect(c.startTurn(), isTrue);
      expect(c.startTurn(), isFalse); // already playing
      c.nextTurn();
      expect(h.s.phase, Phase.playing);
    });

    test('timer does not start during handover', () {
      final h = Harness()..start(GameKind.forbidden);
      h.clock.advance(const Duration(minutes: 5));
      h.controller.tick();
      expect(h.s.phase, Phase.ready);
      h.controller.startTurn();
      expect(h.controller.remainingMs(), 60000);
    });
  });

  group('timer', () {
    test('expires exactly at the deadline and settles once', () {
      final h = Harness()..start(GameKind.charades);
      final c = h.controller..startTurn();
      c.mark(Outcome.correct);
      h.clock.advance(const Duration(milliseconds: 59999));
      c.tick();
      expect(h.s.phase, Phase.playing);
      expect(c.remainingMs(), 1);
      h.clock.advance(const Duration(milliseconds: 1));
      c.tick();
      c.tick();
      c.tick();
      expect(h.s.phase, Phase.turnResults);
      expect(h.s.history.length, 1);
      expect(h.s.scores[0], 1);
      expect(h.s.turn!.ended, EndReason.time);
    });

    test('no scoring after expiry even without a tick', () {
      final h = Harness()..start(GameKind.forbidden);
      final c = h.controller..startTurn();
      c.mark(Outcome.correct);
      h.clock.advance(const Duration(seconds: 61));
      c.mark(Outcome.correct); // late tap — must not count
      c.mark(Outcome.violation);
      expect(h.s.scores[0], 1);
      expect(h.s.history.single.points, 1);
    });

    test('backgrounding gains no time: deadline is absolute', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller..startTurn();
      h.clock.advance(const Duration(seconds: 20)); // tab hidden, no ticks
      expect(c.remainingMs(), 10000);
    });

    test('pause freezes and resume restores the remaining time', () {
      final h = Harness()..start(GameKind.charades);
      final c = h.controller..startTurn();
      h.clock.advance(const Duration(seconds: 10));
      c.pause();
      h.clock.advance(const Duration(minutes: 3));
      c.tick();
      expect(h.s.phase, Phase.playing);
      expect(c.remainingMs(), 50000);
      c.mark(Outcome.correct); // no scoring while paused
      expect(h.s.turn!.events, isEmpty);
      c.resume();
      expect(c.remainingMs(), 50000);
    });

    test('early finish ends the turn and posts the score once', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller..startTurn();
      c.toggleTerm(0);
      c.toggleTerm(3);
      c.finishTurn();
      c.finishTurn();
      expect(h.s.scores[0], 2);
      expect(h.s.history.length, 1);
      expect(h.s.turn!.ended, EndReason.finished);
    });
  });

  group('30-Second Sprint', () {
    test('tap to mark, tap again to correct, live score out of five', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller..startTurn();
      c.toggleTerm(1);
      c.toggleTerm(2);
      expect(c.turnScore, 2);
      c.toggleTerm(2); // correction
      expect(c.turnScore, 1);
      h.clock.advance(const Duration(seconds: 30));
      c.tick();
      expect(h.s.scores[0], 1);
      final ev = h.s.history.single.events;
      expect(ev.length, 5);
      expect(ev.where((e) => e.outcome == Outcome.correct).map((e) => e.term), [1]);
    });

    test('all five ends the turn immediately with five points', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller..startTurn();
      for (var i = 0; i < 5; i++) {
        c.toggleTerm(i);
      }
      expect(h.s.phase, Phase.turnResults);
      expect(h.s.turn!.ended, EndReason.allFound);
      expect(h.s.scores[0], 5);
      c.toggleTerm(0); // no change after the end
      expect(h.s.scores[0], 5);
    });

    test('preassembled cards are used as-is (2 easy, 2 medium, 1 hard)', () {
      final h = Harness()..start(GameKind.sprint);
      h.controller.startTurn();
      final card = h.controller.library.sprint[h.s.turn!.cardId]!;
      final d = card.terms.map((t) => t.difficulty).toList()..sort((a, b) => a.index - b.index);
      expect(d, [Difficulty.easy, Difficulty.easy, Difficulty.medium, Difficulty.medium, Difficulty.hard]);
    });
  });

  group('Charades and Forbidden Words', () {
    test('Charades: correct +1, pass 0, next card dealt immediately', () {
      final h = Harness()..start(GameKind.charades);
      final c = h.controller..startTurn();
      final first = h.s.turn!.cardId;
      c.mark(Outcome.correct);
      expect(h.s.turn!.cardId, isNot(first));
      c.mark(Outcome.pass);
      c.mark(Outcome.correct);
      c.mark(Outcome.violation); // not a Charades action
      expect(h.s.turn!.events.length, 3);
      c.finishTurn();
      expect(h.s.scores[0], 2);
      expect(h.s.history.single.count(Outcome.pass), 1);
    });

    test('Forbidden: violation is −1 and turn scores may be negative', () {
      final h = Harness()..start(GameKind.forbidden);
      final c = h.controller..startTurn();
      c.mark(Outcome.violation);
      c.mark(Outcome.violation);
      c.mark(Outcome.correct);
      c.mark(Outcome.pass);
      c.finishTurn();
      expect(h.s.history.single.points, -1);
      expect(h.s.scores, [-1, 0]);
    });

    test('undo returns the previous card and removes its score', () {
      final h = Harness()..start(GameKind.forbidden);
      final c = h.controller..startTurn();
      final first = h.s.turn!.cardId;
      c.mark(Outcome.violation);
      final second = h.s.turn!.cardId;
      expect(c.undoLast(), isTrue);
      expect(h.s.turn!.cardId, first);
      expect(h.s.turn!.events, isEmpty);
      c.mark(Outcome.correct);
      expect(h.s.turn!.cardId, second, reason: 'the card behind is dealt again, not skipped');
    });
  });

  group('Trivia', () {
    test('answer positions are randomised across questions', () {
      final h = Harness()..start(GameKind.trivia, rounds: 10);
      final c = h.controller;
      final correctPositions = <int>{};
      for (var turn = 0; turn < 6; turn++) {
        c.startTurn();
        for (var q = 0; q < 5; q++) {
          correctPositions.add(h.s.turn!.optionOrder.indexOf(0));
          c.selectOption(0);
          c.lockAnswer();
          c.nextQuestion();
        }
        c.nextTurn();
      }
      expect(correctPositions, {0, 1, 2, 3});
    });

    test('correct and incorrect answers; answer hidden until locked', () {
      final h = Harness()..start(GameKind.trivia);
      final c = h.controller..startTurn();
      final t = h.s.turn!;
      expect(t.revealed, isFalse);
      c.selectOption(t.optionOrder.indexOf(0));
      expect(t.revealed, isFalse, reason: 'selection alone does not reveal');
      c.lockAnswer();
      expect(t.revealed, isTrue);
      expect(t.events.last.outcome, Outcome.correct);
      c.selectOption(0); // locked — ignored
      c.nextQuestion();
      c.selectOption(h.s.turn!.optionOrder.indexOf(2));
      c.lockAnswer();
      expect(h.s.turn!.events.last.outcome, Outcome.wrong);
      expect(c.turnScore, 1);
    });

    test('timeout locks options, records unanswered, reveals; next timer starts on next question', () {
      final h = Harness()..start(GameKind.trivia);
      final c = h.controller..startTurn();
      h.clock.advance(const Duration(seconds: 20));
      c.tick();
      final t = h.s.turn!;
      expect(t.revealed, isTrue);
      expect(t.events.single.outcome, Outcome.timeout);
      expect(c.remainingMs(), 0);
      h.clock.advance(const Duration(minutes: 2)); // reading the explanation
      c.tick();
      expect(h.s.phase, Phase.playing);
      c.nextQuestion();
      expect(c.remainingMs(), 20000);
    });

    test('only a locked answer counts: an unlocked pick at timeout is unanswered', () {
      final h = Harness()..start(GameKind.trivia);
      final c = h.controller..startTurn();
      c.selectOption(h.s.turn!.optionOrder.indexOf(0));
      h.clock.advance(const Duration(seconds: 25));
      c.tick();
      expect(h.s.turn!.events.single.outcome, Outcome.timeout);
    });

    test('five questions per turn, then turn results', () {
      final h = Harness()..start(GameKind.trivia);
      final c = h.controller..startTurn();
      for (var q = 0; q < 5; q++) {
        c.selectOption(h.s.turn!.optionOrder.indexOf(0));
        c.lockAnswer();
        c.nextQuestion();
      }
      expect(h.s.phase, Phase.turnResults);
      expect(h.s.scores[0], 5);
    });

    test('teams in the same round get identical difficulty allocations', () {
      final h = Harness()..start(GameKind.trivia, teams: 3, rounds: 4);
      final c = h.controller;
      final byRoundTeam = <(int, int), List<Difficulty>>{};
      while (h.s.phase != Phase.gameResults) {
        c.startTurn();
        final key = (h.s.round, h.s.teamIndex);
        while (h.s.phase == Phase.playing) {
          c.selectOption(0);
          c.lockAnswer();
          c.nextQuestion();
        }
        byRoundTeam[key] = [for (final e in h.s.history.last.events) c.library.trivia[e.cardId]!.difficulty];
        c.nextTurn();
      }
      for (var r = 1; r <= 4; r++) {
        expect(byRoundTeam[(r, 1)], byRoundTeam[(r, 0)]);
        expect(byRoundTeam[(r, 2)], byRoundTeam[(r, 0)]);
      }
      final all = byRoundTeam.values.expand((d) => d).toList();
      final mh = all.where((d) => d == Difficulty.medium || d == Difficulty.hard).length;
      expect(mh / all.length, greaterThanOrEqualTo(0.75), reason: 'predominantly medium and hard');
      expect(all, contains(Difficulty.easy));
      expect(all, contains(Difficulty.expert));
    });

    test('difficulty filter restricts questions', () {
      final h = Harness()..start(GameKind.trivia, difficulty: Difficulty.expert);
      final c = h.controller..startTurn();
      expect(c.library.trivia[h.s.turn!.cardId]!.difficulty, Difficulty.expert);
    });
  });

  group('content selection', () {
    test('no card repeats within a session', () {
      final h = Harness()..start(GameKind.charades, rounds: 10);
      final c = h.controller;
      final dealt = <String>[];
      while (h.s.phase != Phase.gameResults) {
        c.startTurn();
        for (var i = 0; i < 12; i++) {
          dealt.add(h.s.turn!.cardId!);
          c.mark(i.isEven ? Outcome.correct : Outcome.pass);
        }
        c.finishTurn();
        c.nextTurn();
      }
      expect(dealt.toSet().length, dealt.length);
    });

    test('mixed Charades deck avoids concentrating hard prompts', () {
      final h = Harness()..start(GameKind.charades);
      final first60 = h.s.queues['main']!.take(60).map((id) => h.controller.library.charades[id]!.difficulty);
      final hard = first60.where((d) => d == Difficulty.hard).length;
      expect(hard, inInclusiveRange(4, 10));
    });

    test('exhaustion is reported, not silently repeated; reshuffle is explicit', () {
      final h = Harness()..start(GameKind.charades, difficulty: Difficulty.hard);
      final c = h.controller..startTurn();
      final total = c.library.charades.values.where((x) => x.difficulty == Difficulty.hard).length;
      for (var i = 0; i < 40; i++) {
        c.mark(Outcome.pass);
      }
      c.finishTurn();
      c.nextTurn();
      // The card on screen when a turn ends has been seen by that describer, so
      // it is consumed rather than handed to the next team.
      expect(h.s.queues['main']!.length, total - 41);
      c.startTurn();
      for (var i = 0; i < total - 41; i++) {
        c.mark(Outcome.pass);
      }
      expect(h.s.turn!.cardId, isNull, reason: 'deck empty');
      c.mark(Outcome.correct); // nothing to score
      expect(h.s.turn!.events.length, total - 41);
      c.reshuffle();
      expect(h.s.turn!.cardId, isNotNull);
      expect(h.s.turn!.events.map((e) => e.cardId), isNot(contains(h.s.turn!.cardId)));
    });

    test('Sprint cannot start once every card has been dealt', () {
      final h = Harness()..start(GameKind.sprint, rounds: 10, teams: 6);
      h.s.queues['main']!.clear();
      expect(h.controller.canStartTurn, isFalse);
      expect(h.controller.startTurn(), isFalse);
      h.controller.reshuffle();
      expect(h.controller.canStartTurn, isTrue);
    });

    test('a new session prefers cards not seen on this device', () {
      final h = Harness()..start(GameKind.forbidden);
      final c = h.controller..startTurn();
      final seenNow = <String>{};
      for (var i = 0; i < 20; i++) {
        seenNow.add(h.s.turn!.cardId!);
        c.mark(Outcome.pass);
      }
      h.start(GameKind.forbidden);
      final next = h.s.queues['main']!.take(200).toSet();
      expect(next.intersection(seenNow), isEmpty);
    });

    test('trivia slots: mostly medium/hard with easy or expert wildcard', () {
      expect(DeckPlanner.triviaSlots(5, 1, null),
          [Difficulty.easy, Difficulty.medium, Difficulty.medium, Difficulty.hard, Difficulty.hard]);
      expect(DeckPlanner.triviaSlots(5, 2, null),
          [Difficulty.medium, Difficulty.medium, Difficulty.hard, Difficulty.hard, Difficulty.expert]);
    });
  });

  group('persistence and restoration', () {
    test('refresh between turns restores everything', () {
      final h = Harness()..start(GameKind.charades, teams: 3);
      final c = h.controller..startTurn();
      c.mark(Outcome.correct);
      c.finishTurn();
      c.nextTurn();
      final r = h.reload();
      final s = r.session!;
      expect(s.phase, Phase.ready);
      expect(s.teamIndex, 1);
      expect(s.scores, [1, 0, 0]);
      expect(s.used, h.s.used);
      expect(s.queues['main'], h.s.queues['main']);
      expect(s.teams.map((t) => t.name), ['Team A', 'Team B', 'Team C']);
    });

    test('refresh during an active turn keeps the original deadline', () {
      final h = Harness()..start(GameKind.sprint);
      final c = h.controller..startTurn();
      c.toggleTerm(4);
      h.clock.advance(const Duration(seconds: 12));
      final r = h.reload();
      expect(r.session!.phase, Phase.playing);
      expect(r.remainingMs(), 18000);
      expect(r.session!.turn!.marked, {4});
      expect(r.session!.turn!.cardId, h.s.turn!.cardId);
    });

    test('refresh after the deadline settles the turn without extra time or duplicate score', () {
      final h = Harness()..start(GameKind.forbidden);
      final c = h.controller..startTurn();
      c.mark(Outcome.correct);
      h.clock.advance(const Duration(minutes: 4));
      final r = h.reload();
      expect(r.session!.phase, Phase.turnResults);
      expect(r.session!.scores, [1, 0]);
      final r2 = h.reload(); // refresh again on the results screen
      expect(r2.session!.scores, [1, 0]);
      expect(r2.session!.history.length, 1);
    });

    test('refresh during a Trivia question keeps answer order and timer', () {
      final h = Harness()..start(GameKind.trivia);
      final c = h.controller..startTurn();
      c.selectOption(2);
      h.clock.advance(const Duration(seconds: 5));
      final r = h.reload();
      expect(r.session!.turn!.optionOrder, h.s.turn!.optionOrder);
      expect(r.session!.turn!.selected, 2);
      expect(r.remainingMs(), 15000);
    });

    test('a saved game that references cards no longer in the deck is dropped, not crashed on', () {
      final h = Harness()..start(GameKind.charades);
      h.controller.startTurn();
      h.s.queues['main']!.insert(0, 'CH-REMOVED-9999');
      h.controller.pause(); // persist
      final r = h.reload();
      expect(r.session, isNull);
      expect(h.store.raw, isNull);
    });

    test('discard removes the saved session', () {
      final h = Harness()..start(GameKind.trivia);
      h.controller.discard();
      expect(h.reload().session, isNull);
    });
  });

  group('results', () {
    test('winner is the highest cumulative score', () {
      expect(standingsFor([3, 9, 5]).map((s) => (s.team, s.rank)), [(1, 1), (2, 2), (0, 3)]);
    });

    test('ties share a rank and produce multiple winners', () {
      final h = Harness()..start(GameKind.forbidden, rounds: 1);
      final c = h.controller;
      for (var i = 0; i < 2; i++) {
        c.startTurn();
        c.mark(Outcome.correct);
        c.mark(Outcome.correct);
        c.finishTurn();
        c.nextTurn();
      }
      expect(h.s.phase, Phase.gameResults);
      expect(c.winners, [0, 1]);
      final st = c.standings;
      expect(st.every((x) => x.rank == 1 && x.tied), isTrue);
    });

    test('ending at a round boundary keeps turns equal; ending with no turns discards', () {
      final h = Harness()..start(GameKind.charades, rounds: 3);
      final c = h.controller;
      for (var i = 0; i < 2; i++) {
        c.startTurn();
        c.finishTurn();
        c.nextTurn();
      }
      c.endGame();
      expect(h.s.endedEarly, isTrue);
      expect(c.unequalTurns, isFalse);

      final h2 = Harness()..start(GameKind.sprint);
      h2.controller.endGame();
      expect(h2.controller.session, isNull);
    });

    test('Trivia turn cannot start without a full set of questions', () {
      final h = Harness()..start(GameKind.trivia);
      final q = h.s.queues;
      final keep = q.values.expand((x) => x).take(4).toList();
      q.updateAll((k, v) => v.where(keep.contains).toList());
      expect(h.controller.canStartTurn, isFalse);
    });

    test('ending a game early is flagged', () {
      final h = Harness()..start(GameKind.charades);
      h.controller
        ..startTurn()
        ..mark(Outcome.correct)
        ..endGame();
      expect(h.s.phase, Phase.gameResults);
      expect(h.s.endedEarly, isTrue);
      expect(h.s.scores[0], 1);
    });
  });
}
