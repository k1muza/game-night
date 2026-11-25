import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/local_referee.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/session/session_controller.dart';
import 'package:game_night/session/store.dart';

import 'helpers.dart';

void main() {
  group('local referee WebSocket session', () {
    test(
      'authenticates, synchronises active Tabuu, and deduplicates BUZZ',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = createLocalRefereeService(host.controller);
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = createLocalRefereeService(refereeController);
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final pairing = {...hostPairing.toJson(), 'host': '127.0.0.1'};
        await refereeService.connect(jsonEncode(pairing));
        await _waitUntil(
          () => refereeService.status == RefereeConnectionStatus.connected,
        );
        await _waitUntil(() => refereeService.snapshot != null);
        expect(refereeService.snapshot!['phase'], Phase.ready.name);
        expect(refereeService.snapshot!['card'], isNull);

        host.controller.startTurn();
        await _waitUntil(
          () => refereeService.snapshot?['phase'] == Phase.playing.name,
        );
        final card = refereeService.snapshot!['card'] as Map;
        expect(card['target'], isA<String>());
        expect((card['clues'] as List), hasLength(5));

        final messageId = refereeService.sendAction('buzz');
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.events, hasLength(1));
        expect(host.s.turn!.events.single.outcome, Outcome.violation);

        refereeService.sendAction('buzz', messageId: messageId);
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.events, hasLength(1));
        expect(host.s.scores, [0, 0], reason: 'score settles at turn end');

        expect(
          () => refereeService.sendAction(
            'request_correction',
            messageId: messageId,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'rejects invalid pairing credentials without revealing a snapshot',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.sprint, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = createLocalRefereeService(host.controller);
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = createLocalRefereeService(refereeController);
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final invalidPairing = {
          ...hostPairing.toJson(),
          'host': '127.0.0.1',
          'token': 'invalid-token',
        };
        await refereeService.connect(jsonEncode(invalidPairing));
        await _waitUntil(
          () => refereeService.status == RefereeConnectionStatus.disconnected,
        );
        expect(refereeService.snapshot, isNull);
      },
    );

    test(
      'rejects a delayed BUZZ for an advanced card and synchronises after reconnect',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = createLocalRefereeService(host.controller);
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = createLocalRefereeService(refereeController);
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final pairingJson = jsonEncode({
          ...hostPairing.toJson(),
          'host': '127.0.0.1',
        });
        await refereeService.connect(pairingJson);
        await _waitUntil(
          () => refereeService.status == RefereeConnectionStatus.connected,
        );
        host.controller.startTurn();
        await _waitUntil(
          () => refereeService.snapshot?['phase'] == Phase.playing.name,
        );

        final previousCard = refereeService.snapshot!['cardId'];
        host.controller.mark(Outcome.correct);
        final activeCard = host.s.turn!.cardId;
        expect(activeCard, isNot(previousCard));

        refereeService.sendAction('buzz');
        await _waitUntil(() => refereeService.lastActionAccepted != null);
        expect(refereeService.lastActionAccepted, isFalse);
        expect(host.s.turn!.events, hasLength(1));
        expect(host.s.turn!.events.single.outcome, Outcome.correct);
        expect(host.s.turn!.cardId, activeCard);

        await refereeService.stop();
        await _waitUntil(
          () => hostService.status == RefereeConnectionStatus.disconnected,
        );
        expect(host.s.turn!.paused, isTrue);

        await refereeService.connect(pairingJson);
        await _waitUntil(
          () =>
              refereeService.status == RefereeConnectionStatus.connected &&
              refereeService.snapshot?['paused'] == true,
        );
        expect(refereeService.snapshot!['cardId'], activeCard);
        host.controller.resume();
        await _waitUntil(
          () =>
              refereeService.snapshot?['paused'] == false &&
              refereeService.snapshot?['cardId'] == activeCard,
        );
      },
    );

    test(
      'authorises Sprint scoring, rejects a deadline race, and holds review score',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.sprint, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = createLocalRefereeService(host.controller);
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = createLocalRefereeService(refereeController);
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        await refereeService.connect(
          jsonEncode({...hostPairing.toJson(), 'host': '127.0.0.1'}),
        );
        await _waitUntil(
          () => refereeService.status == RefereeConnectionStatus.connected,
        );
        host.controller.startTurn();
        await _waitUntil(
          () => refereeService.snapshot?['phase'] == Phase.playing.name,
        );
        expect(
          ((refereeService.snapshot!['card'] as Map)['terms'] as List),
          hasLength(5),
        );

        refereeService.sendAction('mark_term_correct', term: 0);
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.marked, {0});
        refereeService.sendAction('disqualify_term', term: 1);
        await _waitUntil(
          () =>
              refereeService.snapshot?['disqualified'] is List &&
              (refereeService.snapshot!['disqualified'] as List).contains(1),
        );
        expect(host.s.turn!.disqualified, {1});

        host.clock.advance(const Duration(milliseconds: 29999));
        refereeService.sendAction('mark_term_correct', term: 2);
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.marked, contains(2));

        host.clock.advance(const Duration(milliseconds: 1));
        refereeService.sendAction('mark_term_correct', term: 3);
        await _waitUntil(
          () => refereeService.snapshot?['phase'] == Phase.turnReview.name,
        );
        await _waitUntil(() => refereeService.lastActionAccepted == false);
        expect(refereeService.lastActionAccepted, isFalse);
        expect(host.s.scores, [0, 0]);
        expect(host.s.history.single.points, 2);

        refereeService.sendAction('request_correction');
        await _waitUntil(() => hostService.correctionRequested);
        refereeService.sendAction('review_term_correct', term: 1);
        await _waitUntil(() => host.s.history.single.points == 3);
        host.controller.confirmReview();
        expect(host.s.scores, [3, 0]);
        expect(host.s.phase, Phase.turnResults);
      },
    );
  });
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 4));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for the local referee state.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
