import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/app.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/fx.dart';
import 'package:game_night/services/local_referee.dart';
import 'package:game_night/services/local_referee_io.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/session/session_controller.dart';
import 'package:game_night/session/store.dart';
import 'package:game_night/ui/screens/local_referee.dart';

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

    test('heartbeat remains connected during sustained referee updates', () async {
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

      // Generate sustained gameplay updates over several seconds alongside
      // periodic heartbeats (every 1s) and authoritative snapshots.
      for (var i = 0; i < 8; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 550));
        final currentCard = refereeService.snapshot!['cardInstanceId'];
        final context = _actionContext(refereeService);
        refereeService.sendAction('buzz', context: context);
        await _waitUntil(
          () =>
              refereeService.lastActionAccepted == true &&
              refereeService.snapshot?['cardInstanceId'] != currentCard,
        );
        expect(refereeService.status, RefereeConnectionStatus.connected);
        expect(hostService.isHostConnected, isTrue);
      }
      expect(refereeService.status, RefereeConnectionStatus.connected);
      expect(hostService.isHostConnected, isTrue);
      expect(host.s.turn!.events, hasLength(8));
    });

    test(
      'suppresses client reconnect while backgrounded and resumes on foreground',
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
        await _waitUntil(() => hostService.isHostConnected);

        refereeService.pauseForBackground();
        await _waitUntil(() => !hostService.isHostConnected);
        expect(refereeService.isInBackground, isTrue);
        expect(refereeService.hasPendingReconnect, isFalse);

        // Remain in background longer than the 1s first reconnect timer delay.
        await Future<void>.delayed(const Duration(milliseconds: 2200));
        expect(hostService.isHostConnected, isFalse);
        expect(refereeService.status, isNot(RefereeConnectionStatus.connected));
        expect(refereeService.hasPendingReconnect, isFalse);

        await refereeService.resumeFromBackground();
        expect(refereeService.isInBackground, isFalse);
        await _waitUntil(
          () =>
              hostService.isHostConnected &&
              refereeService.status == RefereeConnectionStatus.connected,
        );
      },
    );

    test(
      'stale snapshot_ack does not restore host readiness while referee is backgrounded',
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
        addTearDown(hostService.stop);

        final pairing = await hostService.startHost();
        final socket = await WebSocket.connect(
          'ws://127.0.0.1:${pairing.port}/session',
        );
        addTearDown(socket.close);

        Map<String, dynamic>? challengeMsg;
        Map<String, dynamic>? lastSnapshot;
        var synced = false;
        late final List<int> sessionKey;

        final sub = socket.listen((raw) {
          final msg = jsonDecode(raw as String) as Map<String, dynamic>;
          if (msg['type'] == 'pairing_challenge') {
            challengeMsg = msg;
          } else if (msg['type'] == 'session_snapshot') {
            lastSnapshot = msg;
          } else if (msg['type'] == 'synchronization_complete') {
            synced = true;
          }
        });
        addTearDown(sub.cancel);

        await _waitUntil(() => challengeMsg != null);
        final challenge = challengeMsg!['challenge'] as String;
        final sessionId = pairing.sessionId!;
        final proof = base64Url.encode(
          Hmac(sha256, utf8.encode(pairing.token!))
              .convert(
                utf8.encode('local-referee-v2-proof|$sessionId|$challenge'),
              )
              .bytes,
        );
        sessionKey = Hmac(sha256, utf8.encode(pairing.token!))
            .convert(
              utf8.encode('local-referee-v2-session|$sessionId|$challenge'),
            )
            .bytes;

        Map<String, dynamic> sign(Map<String, dynamic> m) {
          final bytes = utf8.encode(jsonEncode(m));
          final mac = base64Url.encode(
            Hmac(sha256, sessionKey).convert(bytes).bytes,
          );
          return {...m, 'mac': mac};
        }

        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'type': 'authenticate',
              'sessionId': sessionId,
              'proof': proof,
            }),
          ),
        );

        await _waitUntil(() => lastSnapshot != null);
        final initialVersion = lastSnapshot!['stateVersion'] as int;
        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'sessionId': sessionId,
              'type': 'snapshot_ack',
              'stateVersion': initialVersion,
            }),
          ),
        );
        await _waitUntil(() => synced && hostService.isHostConnected);

        // Referee goes to background, then a stale snapshot_ack arrives.
        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'sessionId': sessionId,
              'type': 'background',
            }),
          ),
        );
        await _waitUntil(() => !hostService.isHostConnected);
        expect(host.controller.refereeReady, isFalse);

        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'sessionId': sessionId,
              'type': 'snapshot_ack',
              'stateVersion': initialVersion,
            }),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(hostService.isHostConnected, isFalse);
        expect(host.controller.refereeReady, isFalse);

        // Resuming sends a fresh snapshot whose ack restores readiness.
        lastSnapshot = null;
        synced = false;
        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'sessionId': sessionId,
              'type': 'resume',
            }),
          ),
        );
        await _waitUntil(() => lastSnapshot != null);
        socket.add(
          jsonEncode(
            sign({
              'protocolVersion': IoLocalRefereeService.protocolVersion,
              'sessionId': sessionId,
              'type': 'snapshot_ack',
              'stateVersion': lastSnapshot!['stateVersion'],
            }),
          ),
        );
        await _waitUntil(() => synced && hostService.isHostConnected);
      },
    );

    test(
      'joining a second referee session after closing the first maintains a single clean heartbeat',
      () async {
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
              refereeService.hasActiveHeartbeat,
        );

        await refereeService.stop();
        expect(refereeService.hasActiveHeartbeat, isFalse);
        await firstHostService.stop();

        final secondPairing = await secondHostService.startHost();
        await refereeService.connect(jsonEncode(secondPairing.toJson()));
        await _waitUntil(
          () =>
              refereeService.status == RefereeConnectionStatus.connected &&
              secondHostService.isHostConnected &&
              refereeService.hasActiveHeartbeat,
        );
        await Future<void>.delayed(const Duration(milliseconds: 2200));
        expect(refereeService.status, RefereeConnectionStatus.connected);
        expect(secondHostService.isHostConnected, isTrue);
        expect(refereeService.hasActiveHeartbeat, isTrue);
      },
    );
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
        expect(host.controller.refereeCorrectionPending, isTrue);
        expect(
          host.controller.confirmReview(),
          isFalse,
          reason: 'pending correction blocks score settlement until acknowledged',
        );
        expect(host.s.scores, [0, 0]);
        expect(host.s.phase, Phase.turnReview);

        refereeService.sendAction(
          'review_term_correct',
          context: _actionContext(refereeService),
          term: 1,
        );
        await _waitUntil(() => host.s.history.single.points == 3);
        hostService.acknowledgeCorrection();
        expect(host.controller.refereeCorrectionPending, isFalse);
        expect(host.controller.confirmReview(), isTrue);
        expect(host.s.scores, [3, 0]);
        expect(host.s.phase, Phase.turnResults);
      },
    );

    test(
      'correction state resets between sessions even if a correction was pending',
      () {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.sprint, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        host.controller.setRefereeConnectionReady(true);
        host.controller.startTurn();
        host.clock.advance(const Duration(seconds: 35));
        host.controller.tick();
        expect(host.s.phase, Phase.turnReview);

        host.controller.setRefereeCorrectionPending(true);
        expect(host.controller.refereeCorrectionPending, isTrue);
        expect(host.controller.confirmReview(), isFalse);

        host.controller.newSession(
          const GameConfig(game: GameKind.sprint, mode: PlayMode.referee),
          [Team('Team C', 0), Team('Team D', 1)],
        );
        expect(host.controller.refereeCorrectionPending, isFalse);
      },
    );
  });

  group('remote referee UI controls and error handling', () {
    testWidgets('BUZZ button debounces rapid double-taps', (tester) async {
      final host = Harness();
      host.controller.newSession(
        const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
        [Team('Team A', 0), Team('Team B', 1)],
      );
      final fake = _FakeRefereeService(
        host.controller,
        initialStatus: RefereeConnectionStatus.connected,
        initialSnapshot: _tabuuPlayingSnapshot(paused: false, remainingMs: 45000),
      );
      await tester.pumpWidget(_wrapRefereeScreen(host.controller, fake));
      await tester.pump();

      await tester.tap(find.text('BUZZ'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('BUZZ'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      expect(fake.sentActions, ['buzz']);
    });

    testWidgets(
      'disables gameplay controls when paused, expired, syncing, or card unavailable while preserving turn-review controls',
      (tester) async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final fake = _FakeRefereeService(
          host.controller,
          initialStatus: RefereeConnectionStatus.connected,
          initialSnapshot: _tabuuPlayingSnapshot(
            paused: true,
            remainingMs: 30000,
          ),
        );
        await tester.pumpWidget(_wrapRefereeScreen(host.controller, fake));
        await tester.pump();

        // Paused: BUZZ is disabled.
        await tester.tap(find.text('BUZZ'), warnIfMissed: false);
        expect(fake.sentActions, isEmpty);

        // Timer expired: BUZZ is disabled.
        fake.updateSnapshot(
          _tabuuPlayingSnapshot(paused: false, remainingMs: 0),
        );
        await tester.pump();
        await tester.tap(find.text('BUZZ'), warnIfMissed: false);
        expect(fake.sentActions, isEmpty);

        // Synchronising: BUZZ is disabled.
        fake.updateStatus(RefereeConnectionStatus.synchronizing);
        fake.updateSnapshot(
          _tabuuPlayingSnapshot(paused: false, remainingMs: 30000),
        );
        await tester.pump();
        await tester.tap(find.text('BUZZ'), warnIfMissed: false);
        expect(fake.sentActions, isEmpty);

        // Card unavailable: shows waiting message, no BUZZ button.
        fake.updateStatus(RefereeConnectionStatus.connected);
        fake.updateSnapshot(
          _tabuuPlayingSnapshot(
            paused: false,
            remainingMs: 30000,
            includeCard: false,
          ),
        );
        await tester.pump();
        expect(find.text('Waiting for the active card…'), findsOneWidget);
        expect(find.text('BUZZ'), findsNothing);

        // Turn review: Request a correction remains enabled even with remainingMs == 0 and card == null.
        fake.updateSnapshot({
          'protocolVersion': 2,
          'type': 'session_snapshot',
          'sessionId': 's1',
          'stateVersion': 5,
          'game': GameKind.forbidden.name,
          'phase': Phase.turnReview.name,
          'round': 1,
          'team': {'name': 'Team A', 'paletteIndex': 0},
          'scores': [0, 0],
          'turnId': 't1',
          'cardId': null,
          'cardInstanceId': 't1',
          'remainingMs': 0,
          'durationMs': 60000,
          'paused': false,
          'marked': <int>[],
          'disqualified': <int>[],
          'card': null,
          'review': {
            'points': 1,
            'correct': 1,
            'disqualified': 0,
            'passed': 0,
            'buzzed': 0,
            'events': [
              {'outcome': 'correct', 'label': 'Sample'},
            ],
          },
          'correctionRequested': false,
        });
        await tester.pump();
        await tester.tap(find.text('Request a correction'));
        await tester.pump();
        expect(fake.sentActions, ['request_correction']);
      },
    );

    testWidgets(
      'handles stale card, disconnected session, and invalid action exceptions gracefully',
      (tester) async {
        final host = Harness();
        host.controller.newSession(
          const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
          [Team('Team A', 0), Team('Team B', 1)],
        );
        final fake = _FakeRefereeService(
          host.controller,
          initialStatus: RefereeConnectionStatus.connected,
          initialSnapshot: _tabuuPlayingSnapshot(
            paused: false,
            remainingMs: 45000,
          ),
        );
        await tester.pumpWidget(_wrapRefereeScreen(host.controller, fake));
        await tester.pump();

        fake.nextError = StateError(
          'The displayed card or turn is no longer current.',
        );
        await tester.tap(find.text('BUZZ'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          find.text('The displayed card or turn is no longer current.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        fake.nextError = ArgumentError.value('buzz', 'action', 'Not valid.');
        await tester.tap(find.text('BUZZ'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Not valid.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

Map<String, dynamic> _tabuuPlayingSnapshot({
  required bool paused,
  required int remainingMs,
  bool includeCard = true,
}) => {
  'protocolVersion': 2,
  'type': 'session_snapshot',
  'sessionId': 's1',
  'stateVersion': 1,
  'game': GameKind.forbidden.name,
  'phase': Phase.playing.name,
  'round': 1,
  'team': {'name': 'Team A', 'paletteIndex': 0},
  'scores': [0, 0],
  'turnId': 't1',
  'cardId': includeCard ? 'fw1' : null,
  'cardInstanceId': includeCard ? 'ci1' : null,
  'remainingMs': remainingMs,
  'durationMs': 60000,
  'paused': paused,
  'marked': <int>[],
  'disqualified': <int>[],
  'card': includeCard
      ? {
          'target': 'Sadza',
          'clues': ['Maize', 'Pap', 'Mealie', 'Relish', 'Pot'],
        }
      : null,
  'review': null,
  'correctionRequested': false,
};

Widget _wrapRefereeScreen(
  SessionController controller,
  LocalRefereeService service,
) => AppScope(
  controller: controller,
  fx: SilentFx(),
  store: controller.store,
  referee: service,
  nav: AppNav(),
  child: const MaterialApp(home: RefereeGameScreen()),
);

class _FakeRefereeService extends LocalRefereeService {
  _FakeRefereeService(
    super.controller, {
    required RefereeConnectionStatus initialStatus,
    required Map<String, dynamic>? initialSnapshot,
  }) : _status = initialStatus,
       _snapshot = initialSnapshot;

  RefereeConnectionStatus _status;
  Map<String, dynamic>? _snapshot;
  final sentActions = <String>[];
  Object? nextError;

  void updateStatus(RefereeConnectionStatus value) {
    _status = value;
    notifyListeners();
  }

  void updateSnapshot(Map<String, dynamic>? value) {
    _snapshot = value;
    notifyListeners();
  }

  @override
  bool get supported => true;
  @override
  bool get isHost => false;
  @override
  bool get isHostConnected => false;
  @override
  bool get correctionRequested => false;
  @override
  RefereeConnectionStatus get status => _status;
  @override
  PairingDetails? get pairing =>
      const PairingDetails(host: '127.0.0.1', port: 4000, sessionId: 's1');
  @override
  Map<String, dynamic>? get snapshot => _snapshot;
  @override
  String? get lastActionMessage => null;
  @override
  bool? get lastActionAccepted => null;
  @override
  String? get connectionError => null;

  @override
  Future<PairingDetails> startHost() async => throw UnimplementedError();
  @override
  Future<void> connect(String pairingJson) async {}
  @override
  Future<void> connectManual({
    required String host,
    required int port,
    required String pairingCode,
  }) async {}
  @override
  Future<void> retryConnection() async {}
  @override
  String sendAction(
    String action, {
    required RefereeActionContext context,
    int? term,
    String? messageId,
  }) {
    final err = nextError;
    if (err != null) {
      nextError = null;
      throw err;
    }
    sentActions.add(action);
    return 'msg-${sentActions.length}';
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> takeOverClassic() async {}
  @override
  void acknowledgeCorrection() {}
  @override
  void pauseForBackground() {}
  @override
  Future<void> resumeFromBackground() async {}
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
