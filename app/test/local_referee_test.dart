import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/local_referee.dart';
import 'package:game_night/services/local_referee_io.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/session/session_controller.dart';
import 'package:game_night/session/store.dart';

import 'helpers.dart';

void main() {
  group('local referee WebSocket session', () {
    test('Classic Mode backgrounding does not pause gameplay', () async {
      final host = Harness();
      host.controller.newSession(
        const GameConfig(game: GameKind.forbidden, mode: PlayMode.classic),
        [Team('Team A', 0), Team('Team B', 1)],
      );
      host.controller.startTurn();
      final service = IoLocalRefereeService(
        host.controller,
        allowLoopbackForTesting: true,
      );
      addTearDown(service.stop);

      final deadline = host.s.turn!.deadlineMs;
      service.pauseForBackground();
      expect(host.s.turn!.deadlineMs, deadline);
      expect(host.s.turn!.paused, isFalse);
    });
    test(
      'background invalidates referee readiness and recovers from reconnect',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        await refereeService.connect(jsonEncode(hostPairing.toJson()));
        await Future<void>.delayed(const Duration(milliseconds: 800));
        expect(hostService.isHostConnected, isTrue);
        expect(refereeService.status, RefereeConnectionStatus.connected);

        refereeService.pauseForBackground();
        await _waitUntil(() => !hostService.isHostConnected);
        expect(host.controller.refereeReady, isFalse);
        expect(host.controller.canStartTurn, isFalse);

        await refereeService.resumeFromBackground();
        await _waitUntil(
          () =>
              hostService.isHostConnected &&
              refereeService.status == RefereeConnectionStatus.connected,
        );
        expect(refereeService.snapshot, isNotNull);
      },
    );

    test('heartbeat remains connected during rapid referee actions', () async {
      final host = Harness();
      host.controller.newSession(
        const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
        [Team('Team A', 0), Team('Team B', 1)],
      );
      final hostService = IoLocalRefereeService(
        host.controller,
        allowLoopbackForTesting: true,
      );
      final refereeController = SessionController(
        library: host.controller.library,
        store: MemorySessionStore(),
      );
      final refereeService = IoLocalRefereeService(
        refereeController,
        allowLoopbackForTesting: true,
      );
      addTearDown(hostService.stop);
      addTearDown(refereeService.stop);

      final pairing = await hostService.startHost();
      await refereeService.connect(jsonEncode(pairing.toJson()));
      await _waitUntil(() => hostService.isHostConnected);
      host.controller.startTurn();
      await _waitUntil(
        () => refereeService.snapshot?['phase'] == Phase.playing.name,
      );

      final context = _actionContext(refereeService);
      for (var i = 0; i < 12; i++) {
        refereeService.sendAction('buzz', context: context);
      }
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(refereeService.status, RefereeConnectionStatus.connected);
      expect(hostService.isHostConnected, isTrue);
      expect(host.s.turn!.events.length, lessThanOrEqualTo(1));
    });
    test('pairs by manual address and one-time code', () async {
      final host = Harness();
      host.controller.newSession(
        const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
        [Team('Team A', 0), Team('Team B', 1)],
      );
      final hostService = IoLocalRefereeService(
        host.controller,
        allowLoopbackForTesting: true,
      );
      final refereeController = SessionController(
        library: host.controller.library,
        store: MemorySessionStore(),
      );
      final refereeService = IoLocalRefereeService(
        refereeController,
        allowLoopbackForTesting: true,
      );
      addTearDown(hostService.stop);
      addTearDown(refereeService.stop);

      final pairing = await hostService.startHost();
      await refereeService.connectManual(
        host: '127.0.0.1',
        port: pairing.port,
        pairingCode: pairing.pairingCode!,
      );
      await _waitUntil(
        () => refereeService.status == RefereeConnectionStatus.connected,
      );
      await _waitUntil(() => refereeService.snapshot != null);
      expect(refereeService.snapshot!['sessionId'], pairing.sessionId);
    });

    test(
      'authenticates, synchronises active Tabuu, and deduplicates BUZZ',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final pairing = {...hostPairing.toJson(), 'h': '127.0.0.1'};
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

        final context = _actionContext(refereeService);
        final messageId = refereeService.sendAction('buzz', context: context);
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.events, hasLength(1));
        expect(host.s.turn!.events.single.outcome, Outcome.violation);
        expect(host.s.turn!.events.single.origin, ActionOrigin.referee);

        refereeService.sendAction(
          'buzz',
          context: context,
          messageId: messageId,
        );
        await _waitUntil(() => refereeService.lastActionAccepted == true);
        expect(host.s.turn!.events, hasLength(1));
        expect(host.s.scores, [0, 0], reason: 'score settles at turn end');

        expect(
          () => refereeService.sendAction(
            'request_correction',
            context: context,
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
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final invalidPairing = {
          ...hostPairing.toJson(),
          'h': '127.0.0.1',
          't': List.filled(43, 'A').join(),
        };
        await refereeService.connect(jsonEncode(invalidPairing));
        await _waitUntil(
          () =>
              refereeService.status ==
              RefereeConnectionStatus.authenticationFailed,
        );
        expect(refereeService.snapshot, isNull);
      },
    );

    test('new pairing clears the previous session projection', () async {
      final firstHost = Harness();
      firstHost.controller.newSession(
        const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
        [Team('First', 0), Team('Other', 1)],
      );
      final firstHostService = IoLocalRefereeService(
        firstHost.controller,
        allowLoopbackForTesting: true,
      );
      final secondHost = Harness();
      secondHost.controller.newSession(
        const GameConfig(game: GameKind.sprint, mode: PlayMode.referee),
        [Team('Second', 0), Team('Other', 1)],
      );
      final secondHostService = IoLocalRefereeService(
        secondHost.controller,
        allowLoopbackForTesting: true,
      );
      final refereeController = SessionController(
        library: firstHost.controller.library,
        store: MemorySessionStore(),
      );
      final refereeService = IoLocalRefereeService(
        refereeController,
        allowLoopbackForTesting: true,
      );
      addTearDown(firstHostService.stop);
      addTearDown(secondHostService.stop);
      addTearDown(refereeService.stop);

      final firstPairing = await firstHostService.startHost();
      await refereeService.connect(jsonEncode(firstPairing.toJson()));
      await _waitUntil(
        () =>
            refereeService.status == RefereeConnectionStatus.connected &&
            refereeService.snapshot != null,
      );
      expect(refereeService.snapshot!['sessionId'], firstPairing.sessionId);

      await firstHostService.stop();
      final secondPairing = await secondHostService.startHost();
      await refereeService.connect(jsonEncode(secondPairing.toJson()));
      await _waitUntil(
        () =>
            refereeService.status == RefereeConnectionStatus.connected &&
            refereeService.snapshot?['sessionId'] == secondPairing.sessionId,
      );
      expect(refereeService.snapshot!['game'], GameKind.sprint.name);
      expect(refereeService.lastActionMessage, isNull);
    });

    test(
      'host can fall back to Classic without reconnecting the referee',
      () async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final pairing = await hostService.startHost();
        await refereeService.connect(jsonEncode(pairing.toJson()));
        await _waitUntil(
          () => refereeService.status == RefereeConnectionStatus.connected,
        );
        await hostService.takeOverClassic();
        await _waitUntil(
          () =>
              refereeService.snapshot == null &&
              refereeService.connectionError?.contains('Classic Mode') == true,
        );
        expect(host.s.config.mode, PlayMode.classic);
        expect(refereeService.pairing, isNull);
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
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        final pairingJson = jsonEncode({
          ...hostPairing.toJson(),
          'h': '127.0.0.1',
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
        final delayedContext = _actionContext(refereeService);
        host.controller.mark(Outcome.correct);
        final activeCard = host.s.turn!.cardId;
        expect(activeCard, isNot(previousCard));

        refereeService.sendAction('buzz', context: delayedContext);
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
        final hostService = IoLocalRefereeService(
          host.controller,
          allowLoopbackForTesting: true,
        );
        final refereeController = SessionController(
          library: host.controller.library,
          store: MemorySessionStore(),
        );
        final refereeService = IoLocalRefereeService(
          refereeController,
          allowLoopbackForTesting: true,
        );
        addTearDown(hostService.stop);
        addTearDown(refereeService.stop);

        final hostPairing = await hostService.startHost();
        await refereeService.connect(
          jsonEncode({...hostPairing.toJson(), 'h': '127.0.0.1'}),
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

        final actionsContext = _actionContext(refereeService);
        refereeService.sendAction(
          'mark_term_correct',
          context: actionsContext,
          term: 0,
        );
        refereeService.sendAction(
          'disqualify_term',
          context: actionsContext,
          term: 1,
        );
        await _waitUntil(
          () =>
              host.s.turn!.marked.contains(0) &&
              host.s.turn!.disqualified.contains(1),
        );
        expect(host.s.turn!.disqualified, {1});

        host.clock.advance(const Duration(milliseconds: 29999));
        refereeService.sendAction(
          'mark_term_correct',
          context: _actionContext(refereeService),
          term: 2,
        );
        await _waitUntil(() => host.s.turn!.marked.contains(2));
        expect(host.s.turn!.marked, contains(2));

        host.clock.advance(const Duration(milliseconds: 1));
        refereeService.sendAction(
          'mark_term_correct',
          context: _actionContext(refereeService),
          term: 3,
        );
        await _waitUntil(
          () => refereeService.snapshot?['phase'] == Phase.turnReview.name,
        );
        await _waitUntil(() => refereeService.lastActionAccepted == false);
        expect(refereeService.lastActionAccepted, isFalse);
        expect(host.s.scores, [0, 0]);
        expect(host.s.history.single.points, 2);

        refereeService.sendAction(
          'request_correction',
          context: _actionContext(refereeService),
        );
        await _waitUntil(() => hostService.correctionRequested);
        refereeService.sendAction(
          'review_term_correct',
          context: _actionContext(refereeService),
          term: 1,
        );
        await _waitUntil(() => host.s.history.single.points == 3);
        host.controller.confirmReview();
        expect(host.s.scores, [3, 0]);
        expect(host.s.phase, Phase.turnResults);
      },
    );
  });
}

RefereeActionContext _actionContext(LocalRefereeService service) {
  final snapshot = service.snapshot;
  if (snapshot == null) {
    throw StateError('The referee has not received a session snapshot.');
  }
  return RefereeActionContext.fromSnapshot(snapshot);
}

Future<void> _waitUntil(
  bool Function() condition, {
  Object? Function()? debug,
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail(
        'Timed out waiting for the local referee state.${debug == null ? '' : ' ${debug()}'}',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
