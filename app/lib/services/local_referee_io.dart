import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../model/game_kind.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import 'local_referee_types.dart';

LocalRefereeService createLocalRefereeService(SessionController controller) =>
    IoLocalRefereeService(controller);

class IoLocalRefereeService extends LocalRefereeService {
  IoLocalRefereeService(super.controller);

  HttpServer? _server;
  WebSocket? _hostPeer;
  WebSocket? _client;
  StreamSubscription<dynamic>? _peerSubscription;
  StreamSubscription<dynamic>? _clientSubscription;
  Timer? _monitor;
  Timer? _heartbeat;
  Timer? _reconnect;
  final _secureRandom = Random.secure();
  final _processedActions = <String, _ProcessedAction>{};
  final _actionEnvelopes = <String, Map<String, dynamic>>{};
  PairingDetails? _pairing;
  RefereeConnectionStatus _status = RefereeConnectionStatus.idle;
  Map<String, dynamic>? _snapshot;
  String? _lastActionMessage;
  bool? _lastActionAccepted;
  bool _isHost = false;
  bool _correctionRequested = false;
  bool _stopping = false;
  bool _connecting = false;
  int _lastHeartbeatMs = 0;
  int _receivedVersion = -1;

  static const protocolVersion = 1;
  static const _path = '/session';

  @override
  bool get supported => Platform.isAndroid || Platform.isIOS;
  @override
  bool get isHost => _isHost;
  @override
  bool get isHostConnected =>
      _isHost && _status == RefereeConnectionStatus.connected;
  @override
  bool get correctionRequested => _correctionRequested;
  @override
  RefereeConnectionStatus get status => _status;
  @override
  PairingDetails? get pairing => _pairing;
  @override
  Map<String, dynamic>? get snapshot => _snapshot;
  @override
  String? get lastActionMessage => _lastActionMessage;
  @override
  bool? get lastActionAccepted => _lastActionAccepted;

  @override
  Future<PairingDetails> startHost() async {
    final session = controller.session;
    if (session == null ||
        session.config.mode != PlayMode.referee ||
        (session.game != GameKind.sprint &&
            session.game != GameKind.forbidden)) {
      throw StateError(
        'Start a Sprint or Tabuu session in Referee mode first.',
      );
    }
    await stop();
    _stopping = false;
    _isHost = true;
    _correctionRequested = false;
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    String address;
    try {
      address = await _localAddress();
    } catch (_) {
      await server.close(force: true);
      rethrow;
    }
    _server = server;
    _pairing = PairingDetails(
      host: address,
      port: server.port,
      sessionId: _randomHex(16),
      token: _randomHex(32),
    );
    _status = RefereeConnectionStatus.waiting;
    _server!.listen(
      _acceptPeer,
      onError: (Object error, StackTrace stack) {
        _setStatus(RefereeConnectionStatus.disconnected);
      },
    );
    controller.addListener(_broadcastSnapshot);
    _monitor = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_hostPeer != null &&
          DateTime.now().millisecondsSinceEpoch - _lastHeartbeatMs > 3500) {
        _hostPeer?.close(WebSocketStatus.goingAway, 'Heartbeat expired');
      }
    });
    notifyListeners();
    return _pairing!;
  }

  Future<String> _localAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    final addresses = [
      for (final interface in interfaces)
        for (final address in interface.addresses)
          if (address.type == InternetAddressType.IPv4) address.address,
    ];
    addresses.sort((a, b) {
      final aPrivate = _isPrivate(a);
      final bPrivate = _isPrivate(b);
      return aPrivate == bPrivate ? 0 : (aPrivate ? -1 : 1);
    });
    if (addresses.isEmpty) {
      throw const SocketException('No local IPv4 network is available.');
    }
    return addresses.first;
  }

  bool _isPrivate(String address) =>
      address.startsWith('10.') ||
      address.startsWith('192.168.') ||
      RegExp(r'^172\.(1[6-9]|2[0-9]|3[01])\.').hasMatch(address);

  Future<void> _acceptPeer(HttpRequest request) async {
    if (request.uri.path != _path) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    if (_hostPeer != null) {
      socket.add(
        jsonEncode({
          'type': 'connection_rejected',
          'reason': 'Referee already connected',
        }),
      );
      await socket.close(
        WebSocketStatus.policyViolation,
        'One referee is supported',
      );
      return;
    }
    var authenticated = false;
    _peerSubscription = socket.listen(
      (dynamic raw) {
        final message = _decode(raw);
        if (message == null) {
          socket.close(WebSocketStatus.invalidFramePayloadData, 'Invalid JSON');
          return;
        }
        if (!authenticated) {
          final pairing = _pairing;
          if (message['type'] != 'authenticate' ||
              message['protocolVersion'] != protocolVersion ||
              pairing == null ||
              (_hostPeer != null && !identical(socket, _hostPeer)) ||
              message['sessionId'] != pairing.sessionId ||
              !_constantTimeEquals('${message['token']}', pairing.token)) {
            socket.add(
              jsonEncode({
                'type': 'connection_rejected',
                'reason': 'Pairing details are invalid',
              }),
            );
            socket.close(
              WebSocketStatus.policyViolation,
              'Authentication failed',
            );
            return;
          }
          authenticated = true;
          _hostPeer = socket;
          _lastHeartbeatMs = DateTime.now().millisecondsSinceEpoch;
          _setStatus(RefereeConnectionStatus.connected);
          _send(socket, {
            'type': 'connection_accepted',
            'protocolVersion': protocolVersion,
            'sessionId': pairing.sessionId,
          });
          _sendSnapshot(socket);
          return;
        }
        _handleHostMessage(socket, message);
      },
      onDone: () => _hostDisconnected(socket),
      onError: (Object error, StackTrace stack) => _hostDisconnected(socket),
      cancelOnError: true,
    );
  }

  void _handleHostMessage(WebSocket socket, Map<String, dynamic> message) {
    if (!identical(socket, _hostPeer)) return;
    if (message['type'] == 'heartbeat') {
      _lastHeartbeatMs = DateTime.now().millisecondsSinceEpoch;
      _send(socket, {'type': 'heartbeat_ack'});
      return;
    }
    if (message['type'] == 'request_snapshot') {
      _sendSnapshot(socket);
      return;
    }
    if (message['type'] != 'referee_action') return;
    final id = message['messageId'];
    if (id is! String || id.isEmpty || id.length > 128) return;
    final previous = _processedActions[id];
    if (previous != null) {
      if (previous.fingerprint == jsonEncode(message)) {
        _send(socket, previous.response);
      } else {
        _send(socket, {
          'type': 'action_result',
          'messageId': id,
          'accepted': false,
          'reason': 'duplicate_id_conflict',
          'stateVersion': controller.session?.stateVersion ?? 0,
        });
      }
      return;
    }
    final result = _processAction(message);
    _processedActions[id] = _ProcessedAction(jsonEncode(message), result);
    if (_processedActions.length > 512) {
      _processedActions.remove(_processedActions.keys.first);
    }
    _send(socket, result);
  }

  Map<String, dynamic> _processAction(Map<String, dynamic> message) {
    final pairing = _pairing;
    final session = controller.session;
    String? error;
    final payload = message['payload'];
    final action = payload is Map ? payload['action'] : null;
    final turn = session?.turn;
    final tabuuReview =
        session?.phase == Phase.turnReview &&
        session?.game == GameKind.forbidden;
    final expectedCardId = tabuuReview ? null : turn?.cardId;
    final expectedCardInstanceId = tabuuReview
        ? turn?.turnId
        : turn?.cardInstanceId;
    if (pairing == null ||
        session == null ||
        turn == null ||
        message['protocolVersion'] != protocolVersion ||
        message['sessionId'] != pairing.sessionId ||
        message['cardId'] != expectedCardId ||
        message['stateVersion'] is! int ||
        (message['stateVersion'] as int) > session.stateVersion ||
        message['turnId'] != turn.turnId ||
        message['cardInstanceId'] != expectedCardInstanceId) {
      error = 'stale_state';
    } else if (action == 'request_correction' &&
        session.config.mode == PlayMode.referee &&
        session.phase == Phase.turnReview) {
      _correctionRequested = true;
      notifyListeners();
      if (_hostPeer != null) _sendSnapshot(_hostPeer!);
    } else if (session.config.mode == PlayMode.referee &&
        session.phase == Phase.turnReview &&
        action is String) {
      final payloadMap = payload is Map ? payload : const <Object?, Object?>{};
      final index = payloadMap['term'];
      final outcome = switch (action) {
        'review_term_correct' => Outcome.correct,
        'review_term_pending' => Outcome.pass,
        'review_term_disqualified' => Outcome.disqualified,
        _ => null,
      };
      final tabuuOutcome = switch (action) {
        'review_tabuu_correct' => Outcome.correct,
        'review_tabuu_pass' => Outcome.pass,
        'review_tabuu_buzz' => Outcome.violation,
        _ => null,
      };
      final accepted =
          _correctionRequested &&
          index is int &&
          ((session.game == GameKind.sprint &&
                  outcome != null &&
                  controller.reviewSprintTerm(index, outcome)) ||
              (session.game == GameKind.forbidden &&
                  tabuuOutcome != null &&
                  controller.reviewTabuuEvent(index, tabuuOutcome)));
      if (!accepted) error = 'action_not_allowed';
    } else if (session.config.mode != PlayMode.referee ||
        session.phase != Phase.playing ||
        turn.paused ||
        turn.deadlineMs == null ||
        controller.now() >= turn.deadlineMs!) {
      controller.tick();
      error = 'turn_not_active';
    } else if (action == 'buzz') {
      if (session.game != GameKind.forbidden || turn.cardId == null) {
        error = 'action_not_allowed';
      } else {
        controller.mark(Outcome.violation);
      }
    } else if (action == 'mark_term_correct' ||
        action == 'mark_term_pending' ||
        action == 'disqualify_term') {
      if (session.game != GameKind.sprint ||
          payload is! Map ||
          payload['term'] is! int) {
        error = 'action_not_allowed';
      } else {
        final index = payload['term'] as int;
        final accepted = controller.setSprintTerm(
          index,
          '${message['cardInstanceId']}',
          correct: action == 'mark_term_correct',
          disqualified: action == 'disqualify_term',
        );
        if (!accepted) error = 'stale_state';
      }
    } else {
      error = 'action_not_allowed';
    }
    return {
      'type': 'action_result',
      'messageId': message['messageId'],
      'accepted': error == null,
      'reason': error,
      'stateVersion': controller.session?.stateVersion ?? 0,
    };
  }

  void _hostDisconnected(WebSocket socket) {
    if (!identical(socket, _hostPeer)) return;
    _hostPeer = null;
    _peerSubscription = null;
    if (!_stopping) {
      final session = controller.session;
      if (session != null &&
          session.phase == Phase.playing &&
          session.turn?.deadlineMs != null) {
        controller.pause();
      }
      _setStatus(RefereeConnectionStatus.disconnected);
    }
  }

  @override
  Future<void> connect(String pairingJson) async {
    await stop();
    final decoded = jsonDecode(pairingJson);
    if (decoded is! Map<String, dynamic> ||
        decoded['v'] != 1 ||
        decoded['host'] is! String ||
        decoded['port'] is! int ||
        decoded['sessionId'] is! String ||
        decoded['token'] is! String) {
      throw const FormatException('Pairing data is invalid.');
    }
    final host = decoded['host'] as String;
    final port = decoded['port'] as int;
    if (host.isEmpty || port < 1 || port > 65535) {
      throw const FormatException('Pairing address is invalid.');
    }
    _pairing = PairingDetails(
      host: host,
      port: port,
      sessionId: decoded['sessionId'] as String,
      token: decoded['token'] as String,
    );
    _isHost = false;
    _stopping = false;
    _status = RefereeConnectionStatus.connecting;
    notifyListeners();
    await _connectClient();
  }

  Future<void> _connectClient() async {
    if (_connecting || _client != null || _pairing == null || _stopping) return;
    _connecting = true;
    final details = _pairing!;
    try {
      final socket = await WebSocket.connect(
        'ws://${details.host}:${details.port}$_path',
      ).timeout(const Duration(seconds: 3));
      if (_stopping || _pairing != details) {
        await socket.close();
        return;
      }
      _client = socket;
      socket.add(
        jsonEncode({
          'protocolVersion': protocolVersion,
          'type': 'authenticate',
          'sessionId': details.sessionId,
          'token': details.token,
        }),
      );
      _clientSubscription = socket.listen(
        _handleClientMessage,
        onDone: _clientDisconnected,
        onError: (Object error, StackTrace stack) => _clientDisconnected(),
        cancelOnError: true,
      );
      _heartbeat?.cancel();
      _heartbeat = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_client != null) _send(_client!, {'type': 'heartbeat'});
      });
    } catch (error) {
      if (!_stopping) {
        _status = RefereeConnectionStatus.reconnecting;
        notifyListeners();
        _scheduleReconnect();
      }
    } finally {
      _connecting = false;
    }
  }

  void _handleClientMessage(dynamic raw) {
    final message = _decode(raw);
    if (message == null) return;
    switch (message['type']) {
      case 'connection_accepted':
        _setStatus(RefereeConnectionStatus.connected);
        _client?.add(jsonEncode({'type': 'request_snapshot'}));
      case 'connection_rejected':
        if (message['reason'] == 'Referee already connected') {
          _setStatus(RefereeConnectionStatus.reconnecting);
        } else {
          _setStatus(RefereeConnectionStatus.disconnected);
          _pairing = null;
        }
        _client?.close(
          WebSocketStatus.policyViolation,
          'Authentication rejected',
        );
      case 'session_snapshot':
        final version = message['stateVersion'];
        if (version is int && version >= _receivedVersion) {
          _receivedVersion = version;
          _snapshot = message;
          notifyListeners();
        } else if (version is int) {
          _client?.add(jsonEncode({'type': 'request_snapshot'}));
        }
      case 'action_result':
        _lastActionAccepted = message['accepted'] == true;
        _lastActionMessage = _lastActionAccepted!
            ? 'Action sent'
            : _actionError(message['reason']);
        notifyListeners();
      case 'heartbeat_ack':
        break;
      case 'game_ended':
        _pairing = null;
        _setStatus(RefereeConnectionStatus.disconnected);
        _client?.close(WebSocketStatus.normalClosure, 'Game ended');
    }
  }

  String _actionError(dynamic reason) => switch (reason) {
    'stale_state' => 'That card has changed. State refreshed.',
    'turn_not_active' => 'The turn has ended.',
    'action_not_allowed' => 'That action is not available.',
    _ => 'Action was not accepted.',
  };

  void _clientDisconnected() {
    _client = null;
    _clientSubscription = null;
    _heartbeat?.cancel();
    if (!_stopping && _pairing != null) {
      _status = RefereeConnectionStatus.reconnecting;
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnect?.cancel();
    _reconnect = Timer(const Duration(seconds: 1), _connectClient);
  }

  @override
  String sendAction(String action, {int? term, String? messageId}) {
    final details = _pairing;
    final snapshot = _snapshot;
    final socket = _client;
    if (_isHost || details == null || snapshot == null || socket == null) {
      throw StateError('No connected referee session is available.');
    }
    final id = messageId ?? _randomHex(16);
    final previous = _actionEnvelopes[id];
    late final Map<String, dynamic> envelope;
    if (previous != null) {
      final previousPayload = previous['payload'] as Map;
      if (previousPayload['action'] != action ||
          previousPayload['term'] != term) {
        throw StateError(
          'A message ID cannot be reused for a different action.',
        );
      }
      envelope = previous;
    } else {
      final payload = <String, Object>{'action': action};
      if (term != null) payload['term'] = term;
      envelope = {
        'protocolVersion': protocolVersion,
        'type': 'referee_action',
        'sessionId': details.sessionId,
        'turnId': snapshot['turnId'],
        'cardId': snapshot['cardId'],
        'cardInstanceId': snapshot['cardInstanceId'],
        'messageId': id,
        'stateVersion': snapshot['stateVersion'],
        'payload': payload,
      };
      _actionEnvelopes[id] = envelope;
      if (_actionEnvelopes.length > 512) {
        _actionEnvelopes.remove(_actionEnvelopes.keys.first);
      }
    }
    _send(socket, envelope);
    _lastActionMessage = 'Sending…';
    _lastActionAccepted = null;
    notifyListeners();
    return id;
  }

  void _broadcastSnapshot() {
    if (controller.session?.phase != Phase.turnReview) {
      _correctionRequested = false;
    }
    final session = controller.session;
    final endSession =
        session == null ||
        session.phase == Phase.gameResults ||
        session.config.mode == PlayMode.classic;
    if (endSession) {
      if (_hostPeer != null) {
        if (session != null) _sendSnapshot(_hostPeer!);
        _send(_hostPeer!, {'type': 'game_ended'});
      }
      Timer.run(() => unawaited(stop()));
      return;
    }
    if (_hostPeer != null) _sendSnapshot(_hostPeer!);
  }

  void _sendSnapshot(WebSocket socket) {
    final session = controller.session;
    final details = _pairing;
    if (session == null || details == null) return;
    final turn = session.turn;
    final id = turn?.cardId;
    Map<String, dynamic>? card;
    if ((session.phase == Phase.playing ||
            (session.phase == Phase.turnReview &&
                session.game == GameKind.sprint)) &&
        id != null) {
      card = switch (session.game) {
        GameKind.sprint => {
          'terms': [
            for (final term in controller.library.sprint[id]!.terms)
              {'text': term.text, 'context': term.context},
          ],
        },
        GameKind.forbidden => {
          'target': controller.library.forbidden[id]!.target,
          'clues': controller.library.forbidden[id]!.clues,
        },
        _ => null,
      };
    }
    final history = session.history.isEmpty ? null : session.history.last;
    _send(socket, {
      'protocolVersion': protocolVersion,
      'type': 'session_snapshot',
      'sessionId': details.sessionId,
      'stateVersion': session.stateVersion,
      'game': session.game.name,
      'phase': session.phase.name,
      'round': session.round,
      'team': {
        'name': session.activeTeam.name,
        'paletteIndex': session.activeTeam.paletteIndex,
      },
      'scores': session.scores,
      'turnId': turn?.turnId,
      'cardId':
          session.phase == Phase.turnReview &&
              session.game == GameKind.forbidden
          ? null
          : id,
      'cardInstanceId':
          session.phase == Phase.turnReview &&
              session.game == GameKind.forbidden
          ? turn?.turnId
          : turn?.cardInstanceId,
      'remainingMs': controller.remainingMs(),
      'durationMs': controller.durationMs,
      'paused': turn?.paused ?? false,
      'marked': turn?.marked.toList() ?? const [],
      'disqualified': turn?.disqualified.toList() ?? const [],
      'card': card,
      'review':
          (session.phase == Phase.turnReview ||
                  session.phase == Phase.turnResults) &&
              history != null
          ? {
              'points': history.points,
              'correct': history.count(Outcome.correct),
              'disqualified': history.count(Outcome.disqualified),
              'passed': history.count(Outcome.pass),
              'buzzed': history.count(Outcome.violation),
              'events': [
                for (final event in history.events)
                  {
                    'outcome': event.outcome.name,
                    'label': session.game == GameKind.forbidden
                        ? controller.library.forbidden[event.cardId]!.target
                        : (event.term == null
                              ? ''
                              : controller
                                    .library
                                    .sprint[event.cardId]!
                                    .terms[event.term!]
                                    .text),
                  },
              ],
            }
          : null,
      'correctionRequested': _correctionRequested,
    });
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    try {
      final value = jsonDecode(raw as String);
      return value is Map<String, dynamic> ? value : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  void _send(WebSocket socket, Map<String, dynamic> message) {
    try {
      socket.add(jsonEncode(message));
    } on SocketException {
      if (identical(socket, _hostPeer)) _hostDisconnected(socket);
    } on WebSocketException {
      if (identical(socket, _hostPeer)) _hostDisconnected(socket);
    }
  }

  String _randomHex(int bytes) => List.generate(
    bytes,
    (_) => _secureRandom.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  bool _constantTimeEquals(String a, String b) {
    final left = utf8.encode(a);
    final right = utf8.encode(b);
    var difference = left.length ^ right.length;
    for (var i = 0; i < max(left.length, right.length); i++) {
      difference |=
          (i < left.length ? left[i] : 0) ^ (i < right.length ? right[i] : 0);
    }
    return difference == 0;
  }

  void _setStatus(RefereeConnectionStatus value) {
    _status = value;
    notifyListeners();
  }

  @override
  Future<void> takeOverClassic() async {
    await stop();
    controller.switchToClassic();
    if (controller.session?.turn?.paused == true) controller.resume();
  }

  @override
  void pauseForBackground() {
    if (_isHost &&
        _hostPeer != null &&
        controller.session?.phase == Phase.playing &&
        controller.session?.turn?.deadlineMs != null) {
      controller.pause();
    }
  }

  @override
  Future<void> stop() async {
    _stopping = true;
    controller.removeListener(_broadcastSnapshot);
    _monitor?.cancel();
    _heartbeat?.cancel();
    _reconnect?.cancel();
    final peer = _hostPeer;
    _hostPeer = null;
    if (peer != null) {
      await peer.close(WebSocketStatus.goingAway, 'Session closed');
    }
    final client = _client;
    _client = null;
    if (client != null) {
      await client.close(WebSocketStatus.goingAway, 'Session closed');
    }
    await _peerSubscription?.cancel();
    await _clientSubscription?.cancel();
    await _server?.close(force: true);
    _peerSubscription = null;
    _clientSubscription = null;
    _server = null;
    _pairing = null;
    _snapshot = null;
    _processedActions.clear();
    _actionEnvelopes.clear();
    _correctionRequested = false;
    _isHost = false;
    _status = RefereeConnectionStatus.idle;
    notifyListeners();
  }
}

class _ProcessedAction {
  const _ProcessedAction(this.fingerprint, this.response);
  final String fingerprint;
  final Map<String, dynamic> response;
}
