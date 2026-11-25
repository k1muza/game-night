import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';

import '../model/game_kind.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import 'local_referee_types.dart';

LocalRefereeService createLocalRefereeService(SessionController controller) =>
    IoLocalRefereeService(controller);

class IoLocalRefereeService extends LocalRefereeService {
  IoLocalRefereeService(
    super.controller, {
    bool allowLoopbackForTesting = false,
  }) : _allowLoopbackForTesting = allowLoopbackForTesting;

  static const protocolVersion = 2;
  static const _path = '/session';
  static const _authTimeout = Duration(seconds: 5);
  static const _heartbeatTimeoutMs = 3500;
  static const _maxReconnectAttempts = 5;
  static const _maxPendingPeers = 4;
  static const _maxAuthAttemptsPerMinute = 5;
  static const _maxProcessedActions = 8192;
  static const _pairingLifetimeMs = 4 * 60 * 60 * 1000;
  static const _maxMessageLength = 8192;
  static const _pairingAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

  final bool _allowLoopbackForTesting;
  final _secureRandom = Random.secure();
  final _processedActions = <String, _ProcessedAction>{};
  final _actionEnvelopes = <String, Map<String, dynamic>>{};
  final _pendingActions = <String, Map<String, dynamic>>{};
  final _peerSubscriptions = <WebSocket, StreamSubscription<dynamic>>{};
  final _pendingPeerTimeouts = <WebSocket, Timer>{};
  final _authFailures = <String, List<int>>{};
  final _connectingGenerations = <int>{};
  final _peerChallenges = <WebSocket, String>{};

  HttpServer? _server;
  StreamSubscription<HttpRequest>? _serverSubscription;
  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;
  StreamSubscription<dynamic>? _clientSubscription;
  WebSocket? _hostPeer;
  WebSocket? _client;
  Timer? _monitor;
  Timer? _heartbeat;
  Timer? _clientHandshakeTimeout;
  Timer? _reconnect;

  PairingDetails? _pairing;
  RefereeConnectionStatus _status = RefereeConnectionStatus.idle;
  Map<String, dynamic>? _snapshot;
  String? _lastActionMessage;
  String? _connectionError;
  bool? _lastActionAccepted;
  bool _isHost = false;
  bool _hostSynchronized = false;
  bool _correctionRequested = false;
  bool _stopping = false;
  bool _disposed = false;
  int _generation = 0;
  int _lastHeartbeatMs = 0;
  int _lastHeartbeatAckMs = 0;
  int _heartbeatSequence = 0;
  int _lastHeartbeatAckSequence = -1;
  int _receivedVersion = -1;
  int? _snapshotSentVersion;
  int _reconnectAttempts = 0;
  Session? _hostSession;
  List<int>? _hostKey;
  List<int>? _clientKey;

  @override
  bool get supported => Platform.isAndroid || Platform.isIOS;
  @override
  bool get isHost => _isHost;
  @override
  bool get isHostConnected =>
      _isHost &&
      _hostSynchronized &&
      controller.refereeReady &&
      _status == RefereeConnectionStatus.connected;
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
  String? get connectionError => _connectionError;

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
    final generation = _generation;
    _stopping = false;
    _isHost = true;
    _hostSession = session;
    _correctionRequested = false;
    _hostSynchronized = false;
    _connectionError = null;
    _processedActions.clear();
    _authFailures.clear();
    controller.setRefereeConnectionReady(false);

    final address = await _localAddress();
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    if (generation != _generation || _stopping) {
      await server.close(force: true);
      throw StateError('Pairing was cancelled before the server started.');
    }
    _server = server;
    _pairing = PairingDetails(
      host: address,
      port: server.port,
      sessionId: _randomBase64Url(16),
      token: _randomBase64Url(32),
      pairingCode: _randomPairingCode(),
      expiresAtMs: DateTime.now().millisecondsSinceEpoch + _pairingLifetimeMs,
    );
    _setStatus(RefereeConnectionStatus.waiting);
    _serverSubscription = server.listen(
      (request) => unawaited(_acceptPeer(request, generation)),
      onError: (Object error, StackTrace stack) {
        if (generation == _generation) {
          _setStatus(
            RefereeConnectionStatus.disconnected,
            error: 'The local pairing server stopped unexpectedly.',
          );
        }
      },
    );
    controller.addListener(_broadcastSnapshot);
    _startConnectivityMonitor(generation);
    _monitor = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (generation != _generation) return;
      final peer = _hostPeer;
      if (peer != null &&
          DateTime.now().millisecondsSinceEpoch - _lastHeartbeatMs >
              _heartbeatTimeoutMs) {
        unawaited(
          _closeSocket(peer, WebSocketStatus.goingAway, 'Heartbeat expired'),
        );
      }
    });
    return _pairing!;
  }

  Future<String> _localAddress() async {
    if (_allowLoopbackForTesting) return InternetAddress.loopbackIPv4.address;
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    final candidates = <(String, String)>[
      for (final interface in interfaces)
        if (!_isVpnInterface(interface.name))
          for (final address in interface.addresses)
            if (address.type == InternetAddressType.IPv4 &&
                _isPrivate(address.address))
              (interface.name, address.address),
    ];
    if (candidates.isEmpty) {
      throw const SocketException(
        'Could not identify a private local-network address. Connect to Wi-Fi or a hotspot and disable any VPN.',
      );
    }
    if (candidates.length == 1) return candidates.single.$2;
    for (final candidate in candidates) {
      final address = candidate.$2;
      if (address.startsWith('172.20.10.') ||
          address.startsWith('192.168.43.') ||
          address.startsWith('192.168.49.') ||
          address.startsWith('192.168.137.')) {
        return address;
      }
    }
    final wifi = candidates.where(
      (candidate) =>
          _isWifiInterface(candidate.$1) && !_isVpnInterface(candidate.$1),
    );
    if (wifi.length == 1) return wifi.single.$2;
    return candidates.first.$2;
  }

  bool _isWifiInterface(String name) => RegExp(
    r'(wlan|wifi|swlan|en\d*|ap\d*|eth\d*|ethernet)',
    caseSensitive: false,
  ).hasMatch(name);

  bool _isVpnInterface(String name) => RegExp(
    r'(vpn|tun|tap|utun|ppp|ipsec|wireguard|zt|tailscale|llw\d*|p2p)',
    caseSensitive: false,
  ).hasMatch(name);

  Future<void> _acceptPeer(HttpRequest request, int generation) async {
    if (generation != _generation || _stopping) return;
    if (request.uri.path != _path) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final remoteAddress =
        request.connectionInfo?.remoteAddress.address ?? 'unknown';
    if ((!_allowLoopbackForTesting && !_isPrivate(remoteAddress)) ||
        (_allowLoopbackForTesting &&
            !_isPrivate(remoteAddress) &&
            remoteAddress != InternetAddress.loopbackIPv4.address)) {
      request.response.statusCode = HttpStatus.forbidden;
      await request.response.close();
      return;
    }
    if (_hostPeer != null || _pendingPeerTimeouts.length >= _maxPendingPeers) {
      request.response.statusCode = HttpStatus.tooManyRequests;
      await request.response.close();
      return;
    }

    final WebSocket socket;
    try {
      socket = await WebSocketTransformer.upgrade(request);
    } on HttpException {
      return;
    } on SocketException {
      return;
    } on WebSocketException {
      return;
    }
    if (generation != _generation || _stopping) {
      unawaited(
        _closeSocket(socket, WebSocketStatus.goingAway, 'Pairing stopped'),
      );
      return;
    }

    _pendingPeerTimeouts[socket] = Timer(_authTimeout, () {
      if (!identical(_hostPeer, socket)) {
        unawaited(
          _closeSocket(
            socket,
            WebSocketStatus.policyViolation,
            'Authentication timed out',
          ),
        );
      }
    });
    final subscription = socket.listen(
      (dynamic raw) {
        if (generation != _generation) return;
        final message = _decode(raw);
        if (message == null) {
          unawaited(
            _closeSocket(
              socket,
              WebSocketStatus.invalidFramePayloadData,
              'Invalid message',
            ),
          );
          return;
        }
        if (!identical(socket, _hostPeer)) {
          _authenticatePeer(socket, message, remoteAddress, generation);
        } else {
          _handleHostMessage(socket, message);
        }
      },
      onDone: () => _peerDisconnected(socket, generation),
      onError: (Object error, StackTrace stack) =>
          _peerDisconnected(socket, generation),
      cancelOnError: true,
    );
    _peerSubscriptions[socket] = subscription;
    final challenge = _randomHex(32);
    _peerChallenges[socket] = challenge;
    _send(socket, {
      'type': 'pairing_challenge',
      'protocolVersion': protocolVersion,
      'sessionId': _pairing?.sessionId,
      'challenge': challenge,
    });
  }

  void _authenticatePeer(
    WebSocket socket,
    Map<String, dynamic> message,
    String remoteAddress,
    int generation,
  ) {
    final pairing = _pairing;
    final suppliedSessionId = message['sessionId'];
    final proof = message['proof'];
    final challenge = _peerChallenges[socket];
    final expiresAt = pairing?.expiresAtMs;
    final expired =
        expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt;
    final matchingSession =
        pairing?.sessionId != null &&
        suppliedSessionId is String &&
        _constantTimeEquals(suppliedSessionId, pairing!.sessionId!);
    final qrAuth =
        challenge != null &&
        pairing?.token != null &&
        proof is String &&
        matchingSession &&
        _constantTimeEquals(
          proof,
          _pairingProof(pairing.token!, pairing.sessionId!, challenge),
        );
    final codeAuth =
        challenge != null &&
        pairing?.pairingCode != null &&
        proof is String &&
        matchingSession &&
        _constantTimeEquals(
          proof,
          _pairingProof(pairing.pairingCode!, pairing.sessionId!, challenge),
        );
    final validMessage =
        message['type'] == 'authenticate' &&
        message['protocolVersion'] == protocolVersion &&
        pairing != null &&
        matchingSession &&
        (qrAuth || codeAuth);
    final withinRateLimit = _authAttemptAllowed(remoteAddress);

    if (expired || _hostPeer != null || !validMessage || !withinRateLimit) {
      if (!expired && _hostPeer == null && withinRateLimit && !validMessage) {
        _recordAuthFailure(remoteAddress);
      }
      final reason = expired
          ? 'pairing_expired'
          : (!withinRateLimit ? 'rate_limited' : 'invalid_pairing');
      _send(socket, {
        'type': 'connection_rejected',
        'protocolVersion': protocolVersion,
        'reason': reason,
      });
      _pendingPeerTimeouts.remove(socket)?.cancel();
      _peerChallenges.remove(socket);
      unawaited(
        _closeSocket(
          socket,
          WebSocketStatus.policyViolation,
          'Authentication failed',
        ),
      );
      return;
    }

    final secret = qrAuth ? pairing.token! : pairing.pairingCode!;
    final sessionKey = _deriveSessionKey(secret, pairing.sessionId!, challenge);
    if (!_verifySignedMessage(message, sessionKey)) {
      _recordAuthFailure(remoteAddress);
      _pendingPeerTimeouts.remove(socket)?.cancel();
      _peerChallenges.remove(socket);
      unawaited(
        _closeSocket(
          socket,
          WebSocketStatus.policyViolation,
          'Authentication proof is invalid',
        ),
      );
      return;
    }
    _authFailures.remove(remoteAddress);
    _pendingPeerTimeouts.remove(socket)?.cancel();
    _peerChallenges.remove(socket);
    _hostPeer = socket;
    _hostKey = sessionKey;
    _hostSynchronized = false;
    _snapshotSentVersion = null;
    _lastHeartbeatMs = DateTime.now().millisecondsSinceEpoch;
    _setStatus(RefereeConnectionStatus.synchronizing);
    controller.setRefereeConnectionReady(false);
    _send(socket, {
      'type': 'connection_accepted',
      'protocolVersion': protocolVersion,
      'sessionId': pairing.sessionId,
    });
    _sendSnapshot(socket);
    if (generation != _generation) {
      unawaited(
        _closeSocket(socket, WebSocketStatus.goingAway, 'Pairing changed'),
      );
    }
  }

  bool _authAttemptAllowed(String address) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final attempts = _authFailures.putIfAbsent(address, () => []);
    attempts.removeWhere((time) => now - time > 60000);
    return attempts.length < _maxAuthAttemptsPerMinute;
  }

  void _recordAuthFailure(String address) {
    final attempts = _authFailures.putIfAbsent(address, () => []);
    final now = DateTime.now().millisecondsSinceEpoch;
    attempts.removeWhere((time) => now - time > 60000);
    attempts.add(now);
  }

  void _handleHostMessage(WebSocket socket, Map<String, dynamic> message) {
    if (!identical(socket, _hostPeer)) return;
    final pairing = _pairing;
    final key = _hostKey;
    if (pairing == null ||
        key == null ||
        !_verifySignedMessage(message, key) ||
        message['protocolVersion'] != protocolVersion ||
        message['sessionId'] != pairing.sessionId) {
      _send(socket, {'type': 'protocol_error', 'reason': 'session_mismatch'});
      unawaited(
        _closeSocket(
          socket,
          WebSocketStatus.policyViolation,
          'Session mismatch',
        ),
      );
      return;
    }
    if (message['type'] == 'heartbeat') {
      final sequence = message['sequence'];
      if (sequence is! int || sequence < 0) return;
      _lastHeartbeatMs = DateTime.now().millisecondsSinceEpoch;
      _send(socket, {
        'type': 'heartbeat_ack',
        'protocolVersion': protocolVersion,
        'sessionId': pairing.sessionId,
        'sequence': sequence,
      });
      return;
    }
    if (message['type'] == 'background') {
      final session = controller.session;
      if (session?.phase == Phase.playing &&
          session?.turn?.deadlineMs != null) {
        controller.pause();
      }
      _setStatus(RefereeConnectionStatus.connected);
      return;
    }
    if (message['type'] == 'resume') {
      _sendSnapshot(socket);
      return;
    }
    if (message['type'] == 'snapshot_ack') {
      final version = message['stateVersion'];
      final session = controller.session;
      if (version is! int ||
          version != _snapshotSentVersion ||
          session == null ||
          version != session.stateVersion) {
        _sendSnapshot(socket);
        return;
      }
      _hostSynchronized = true;
      _setStatus(RefereeConnectionStatus.connected);
      controller.setRefereeConnectionReady(true);
      _send(socket, {
        'type': 'synchronization_complete',
        'protocolVersion': protocolVersion,
        'sessionId': pairing.sessionId,
        'stateVersion': version,
      });
      return;
    }
    if (message['type'] == 'request_snapshot') {
      _sendSnapshot(socket);
      return;
    }
    if (message['type'] != 'referee_action') {
      _send(socket, {'type': 'protocol_error', 'reason': 'unknown_message'});
      return;
    }
    final id = message['messageId'];
    if (id is! String || id.isEmpty || id.length > 128) {
      _send(socket, {'type': 'protocol_error', 'reason': 'invalid_message_id'});
      return;
    }
    final fingerprint = jsonEncode(_unsignedMessage(message));
    final previous = _processedActions[id];
    if (previous != null) {
      if (previous.fingerprint == fingerprint) {
        _send(socket, previous.response);
      } else {
        _send(socket, {
          'type': 'action_result',
          'protocolVersion': protocolVersion,
          'sessionId': pairing.sessionId,
          'messageId': id,
          'accepted': false,
          'reason': 'duplicate_id_conflict',
          'stateVersion': controller.session?.stateVersion ?? 0,
        });
      }
      return;
    }
    if (_processedActions.length >= _maxProcessedActions) {
      _send(socket, {
        'type': 'action_result',
        'protocolVersion': protocolVersion,
        'sessionId': pairing.sessionId,
        'messageId': id,
        'accepted': false,
        'reason': 'action_limit',
        'stateVersion': controller.session?.stateVersion ?? 0,
      });
      return;
    }
    final result = _processAction(message);
    _processedActions[id] = _ProcessedAction(fingerprint, result);
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
    final actionVersion = message['stateVersion'];

    if (!_hostSynchronized ||
        !controller.refereeReady ||
        pairing == null ||
        session == null ||
        turn == null ||
        message['protocolVersion'] != protocolVersion ||
        message['sessionId'] != pairing.sessionId ||
        message['cardId'] != expectedCardId ||
        actionVersion is! int ||
        actionVersion < 0 ||
        actionVersion > session.stateVersion ||
        message['turnId'] != turn.turnId ||
        message['cardInstanceId'] != expectedCardInstanceId) {
      error = 'stale_state';
    } else if (action == 'request_correction' &&
        session.config.mode == PlayMode.referee &&
        session.phase == Phase.turnReview) {
      _correctionRequested = true;
      notifyListeners();
      _sendSnapshot(_hostPeer!);
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
      final cardInstanceId = message['cardInstanceId'];
      if (session.game != GameKind.forbidden ||
          cardInstanceId is! String ||
          !controller.markRefereeViolation(cardInstanceId)) {
        error = 'stale_state';
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
      'protocolVersion': protocolVersion,
      'sessionId': pairing?.sessionId,
      'messageId': message['messageId'],
      'accepted': error == null,
      'reason': error,
      'stateVersion': controller.session?.stateVersion ?? 0,
    };
  }

  void _peerDisconnected(WebSocket socket, int generation) {
    _pendingPeerTimeouts.remove(socket)?.cancel();
    _peerSubscriptions.remove(socket);
    _peerChallenges.remove(socket);
    if (generation != _generation || !identical(socket, _hostPeer)) return;
    _hostPeer = null;
    _hostKey = null;
    _hostSynchronized = false;
    _snapshotSentVersion = null;
    controller.setRefereeConnectionReady(false);
    if (!_stopping) {
      final session = controller.session;
      if (session != null &&
          session.phase == Phase.playing &&
          session.turn?.deadlineMs != null) {
        controller.pause();
      }
      _setStatus(
        RefereeConnectionStatus.disconnected,
        error: 'Referee disconnected. The active turn has been paused.',
      );
    }
  }

  @override
  Future<void> connect(String pairingJson) async {
    final text = pairingJson.trim();
    final decoded = jsonDecode(
      text.startsWith('{') ? text : Uri.decodeComponent(text),
    );
    final details = PairingDetails.fromJson(decoded);
    await _connectTo(details);
  }

  @override
  Future<void> connectManual({
    required String host,
    required int port,
    required String pairingCode,
  }) async {
    final code = _normalisePairingCode(pairingCode);
    if (code == null) {
      throw const FormatException('Enter the 12-character pairing code.');
    }
    await _connectTo(
      PairingDetails(host: host.trim(), port: port, pairingCode: code),
    );
  }

  Future<void> _connectTo(PairingDetails details) async {
    _validatePairing(details);
    final sameSession = _samePairingSession(_pairing, details);
    await _closeCurrent(clearPairing: true, clearSessionState: !sameSession);
    _pairing = details;
    _isHost = false;
    _stopping = false;
    _reconnectAttempts = 0;
    _connectionError = null;
    _setStatus(RefereeConnectionStatus.connecting);
    _startConnectivityMonitor(_generation);
    await _connectClient(_generation);
  }

  void _validatePairing(PairingDetails details) {
    if (details.port < 1 || details.port > 65535) {
      throw const FormatException('Pairing port is invalid.');
    }
    final address = InternetAddress.tryParse(details.host);
    if (address == null ||
        address.type != InternetAddressType.IPv4 ||
        (!_isPrivate(details.host) &&
            !(_allowLoopbackForTesting &&
                details.host == InternetAddress.loopbackIPv4.address))) {
      throw const FormatException(
        'Enter a private IPv4 address from the same Wi-Fi or hotspot.',
      );
    }
    if (details.token != null &&
        details.expiresAtMs != null &&
        details.expiresAtMs! <= DateTime.now().millisecondsSinceEpoch) {
      throw const FormatException('This QR pairing has expired.');
    }
    final hasToken = details.token != null;
    final validQr =
        details.token != null &&
        details.sessionId != null &&
        _isPairingToken(details.token!) &&
        _isPairingSessionId(details.sessionId!) &&
        details.expiresAtMs != null &&
        details.expiresAtMs! > DateTime.now().millisecondsSinceEpoch;
    final validCode =
        details.pairingCode != null &&
        _normalisePairingCode(details.pairingCode!) != null;
    if ((hasToken && !validQr) ||
        (details.sessionId != null &&
            details.token == null &&
            details.pairingCode == null) ||
        (validQr == validCode)) {
      throw const FormatException('Pairing authentication data is invalid.');
    }
  }

  bool _samePairingSession(PairingDetails? old, PairingDetails next) {
    if (old == null || old.host != next.host || old.port != next.port) {
      return false;
    }
    if (old.sessionId != null && next.sessionId != null) {
      return old.sessionId == next.sessionId;
    }
    return old.pairingCode != null &&
        next.pairingCode != null &&
        old.pairingCode == next.pairingCode;
  }

  Future<void> _connectClient(int generation) async {
    final details = _pairing;
    if (generation != _generation ||
        _stopping ||
        _isHost ||
        details == null ||
        _client != null ||
        !_connectingGenerations.add(generation)) {
      return;
    }
    try {
      final socket = await WebSocket.connect(
        Uri(
          scheme: 'ws',
          host: details.host,
          port: details.port,
          path: _path,
        ).toString(),
      ).timeout(const Duration(seconds: 4));
      if (generation != _generation || _stopping || _pairing != details) {
        unawaited(
          _closeSocket(
            socket,
            WebSocketStatus.goingAway,
            'Connection cancelled',
          ),
        );
        return;
      }
      _client = socket;
      _lastHeartbeatAckMs = DateTime.now().millisecondsSinceEpoch;
      _lastHeartbeatAckSequence = -1;
      _clientSubscription = socket.listen(
        (dynamic raw) => _handleClientMessage(raw, socket, generation),
        onDone: () => _clientDisconnected(socket, generation),
        onError: (Object error, StackTrace stack) =>
            _clientDisconnected(socket, generation),
        cancelOnError: true,
      );
      _clientHandshakeTimeout?.cancel();
      _clientHandshakeTimeout = Timer(_authTimeout, () {
        if (generation == _generation &&
            identical(_client, socket) &&
            _status != RefereeConnectionStatus.connected) {
          _connectionError =
              'Host did not complete pairing. Check the code and Wi-Fi, then retry.';
          _setStatus(RefereeConnectionStatus.disconnected);
          unawaited(
            _closeSocket(
              socket,
              WebSocketStatus.goingAway,
              'Pairing timed out',
            ),
          );
        }
      });
    } on SocketException catch (error) {
      _connectionAttemptFailed(generation, error.message);
    } on TimeoutException {
      _connectionAttemptFailed(generation, 'Connection timed out.');
    } on WebSocketException catch (error) {
      _connectionAttemptFailed(generation, error.message);
    } finally {
      _connectingGenerations.remove(generation);
    }
  }

  void _handleClientMessage(dynamic raw, WebSocket socket, int generation) {
    if (generation != _generation || !identical(socket, _client)) return;
    final message = _decode(raw);
    if (message == null) {
      _protocolFailure(socket, 'Host sent an invalid message.');
      return;
    }
    final type = message['type'];
    final pairing = _pairing;
    if (pairing == null) return;
    if (type == 'pairing_challenge') {
      final sessionId = message['sessionId'];
      final challenge = message['challenge'];
      final secret = pairing.token ?? pairing.pairingCode;
      if (message['protocolVersion'] != protocolVersion ||
          sessionId is! String ||
          !_isPairingSessionId(sessionId) ||
          challenge is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(challenge) ||
          (pairing.sessionId != null && pairing.sessionId != sessionId) ||
          secret == null) {
        _protocolFailure(socket, 'Host pairing challenge is invalid.');
        return;
      }
      _clientKey = _deriveSessionKey(secret, sessionId, challenge);
      _pairing = PairingDetails(
        host: pairing.host,
        port: pairing.port,
        sessionId: sessionId,
        token: pairing.token,
        pairingCode: pairing.pairingCode,
        expiresAtMs: pairing.expiresAtMs,
      );
      _send(socket, {
        'protocolVersion': protocolVersion,
        'type': 'authenticate',
        'sessionId': sessionId,
        'proof': _pairingProof(secret, sessionId, challenge),
      });
      return;
    }
    if (type == 'connection_rejected') {
      final reason = message['reason'];
      _clientHandshakeTimeout?.cancel();
      _connectionError = switch (reason) {
        'pairing_expired' =>
          'This pairing code has expired. Ask the host to create a new code.',
        'rate_limited' =>
          'Too many pairing attempts. Wait a minute before trying again.',
        _ => 'Pairing was rejected. Check the host address and pairing code.',
      };
      _setStatus(RefereeConnectionStatus.authenticationFailed);
      unawaited(
        _closeSocket(
          socket,
          WebSocketStatus.policyViolation,
          'Pairing rejected',
        ),
      );
      return;
    }
    final key = _clientKey;
    if (key == null || !_verifySignedMessage(message, key)) {
      _protocolFailure(socket, 'Host message authentication failed.');
      return;
    }
    if (message['protocolVersion'] != protocolVersion ||
        (pairing.sessionId != null &&
            message['sessionId'] != pairing.sessionId)) {
      _protocolFailure(socket, 'Host sent data for a different session.');
      return;
    }
    switch (type) {
      case 'connection_accepted':
        final sessionId = message['sessionId'];
        if (sessionId is! String || !_isPairingSessionId(sessionId)) {
          _protocolFailure(socket, 'Host pairing response is invalid.');
          return;
        }
        _pairing = PairingDetails(
          host: pairing.host,
          port: pairing.port,
          sessionId: sessionId,
          token: pairing.token,
          pairingCode: pairing.pairingCode,
          expiresAtMs: pairing.expiresAtMs,
        );
        _setStatus(RefereeConnectionStatus.synchronizing);
      case 'session_snapshot':
        final RefereeSnapshot snapshot;
        try {
          snapshot = RefereeSnapshot.parse(
            message,
            expectedSessionId: pairing.sessionId ?? '',
          );
        } on FormatException {
          _protocolFailure(socket, 'Host sent an invalid session snapshot.');
          return;
        }
        final version = snapshot.toJson()['stateVersion'] as int;
        if (version < _receivedVersion) return;
        _receivedVersion = version;
        _snapshot = snapshot.toJson();
        _send(socket, {
          'protocolVersion': protocolVersion,
          'sessionId': pairing.sessionId,
          'type': 'snapshot_ack',
          'stateVersion': version,
        });
        notifyListeners();
      case 'synchronization_complete':
        final version = message['stateVersion'];
        if (version is! int ||
            _snapshot == null ||
            version > _receivedVersion) {
          _protocolFailure(
            socket,
            'Host synchronization acknowledgement is invalid.',
          );
          return;
        }
        _clientHandshakeTimeout?.cancel();
        _reconnectAttempts = 0;
        _connectionError = null;
        _startClientHeartbeat(socket, generation);
        _setStatus(RefereeConnectionStatus.connected);
        _replayPendingActions(socket);
      case 'action_result':
        final id = message['messageId'];
        if (id is! String) {
          _protocolFailure(socket, 'Host action acknowledgement is invalid.');
          return;
        }
        final RefereeActionResult result;
        try {
          result = RefereeActionResult.parse(message, expectedMessageId: id);
        } on FormatException {
          _protocolFailure(socket, 'Host action acknowledgement is invalid.');
          return;
        }
        _pendingActions.remove(id);
        _lastActionAccepted = result.accepted;
        _lastActionMessage = result.accepted
            ? 'Action acknowledged'
            : _actionError(result.reason);
        notifyListeners();
      case 'heartbeat_ack':
        final sequence = message['sequence'];
        if (sequence is int && sequence > _lastHeartbeatAckSequence) {
          _lastHeartbeatAckSequence = sequence;
          _lastHeartbeatAckMs = DateTime.now().millisecondsSinceEpoch;
        }
      case 'background':
        final session = controller.session;
        if (session?.phase == Phase.playing &&
            session?.turn?.deadlineMs != null) {
          controller.pause();
        }
        _setStatus(RefereeConnectionStatus.connected);
      case 'resume':
        if (identical(socket, _client) &&
            _pairing?.sessionId == message['sessionId']) {
          _send(socket, {
            'protocolVersion': protocolVersion,
            'sessionId': _pairing?.sessionId,
            'type': 'request_snapshot',
          });
        }
      case 'protocol_error':
        _protocolFailure(socket, 'Host rejected the connection protocol.');
      case 'game_ended':
        _clientHandshakeTimeout?.cancel();
        _pairing = null;
        _snapshot = null;
        _receivedVersion = -1;
        _pendingActions.clear();
        _actionEnvelopes.clear();
        _setStatus(
          RefereeConnectionStatus.disconnected,
          error: message['reason'] == 'classic_mode'
              ? 'The host switched this game to Classic Mode.'
              : 'The host ended the local referee session.',
        );
        unawaited(
          _closeSocket(socket, WebSocketStatus.normalClosure, 'Game ended'),
        );
    }
  }

  void _startClientHeartbeat(WebSocket socket, int generation) {
    _heartbeat?.cancel();
    _lastHeartbeatAckMs = DateTime.now().millisecondsSinceEpoch;
    _lastHeartbeatAckSequence = -1;
    _heartbeat = Timer.periodic(const Duration(seconds: 1), (_) {
      if (generation != _generation || !identical(_client, socket)) return;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastHeartbeatAckMs > _heartbeatTimeoutMs) {
        unawaited(
          _closeSocket(
            socket,
            WebSocketStatus.goingAway,
            'Heartbeat acknowledgement expired',
          ),
        );
        return;
      }
      final sequence = ++_heartbeatSequence;
      _send(socket, {
        'protocolVersion': protocolVersion,
        'sessionId': _pairing?.sessionId,
        'type': 'heartbeat',
        'sequence': sequence,
      });
    });
  }

  void _replayPendingActions(WebSocket socket) {
    for (final envelope in _pendingActions.values) {
      _send(socket, envelope);
    }
  }

  String _actionError(String? reason) => switch (reason) {
    'stale_state' => 'That card or turn has changed. State refreshed.',
    'turn_not_active' => 'The turn has ended.',
    'action_not_allowed' => 'That action is not available.',
    'duplicate_id_conflict' => 'Action was already processed differently.',
    'action_limit' =>
      'The session reached its action limit. Ask the host to restart pairing.',
    _ => 'Action was not accepted.',
  };

  void _clientDisconnected(WebSocket socket, int generation) {
    if (generation != _generation || !identical(socket, _client)) return;
    _client = null;
    _clientKey = null;
    _clientSubscription = null;
    _clientHandshakeTimeout?.cancel();
    _heartbeat?.cancel();
    if (_stopping ||
        _pairing == null ||
        _status == RefereeConnectionStatus.authenticationFailed) {
      return;
    }
    _setStatus(RefereeConnectionStatus.reconnecting);
    _scheduleReconnect(generation);
  }

  void _connectionAttemptFailed(int generation, String reason) {
    if (generation != _generation || _stopping) return;
    _connectionError = reason;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _setStatus(
        RefereeConnectionStatus.disconnected,
        error:
            'Could not reconnect after $_maxReconnectAttempts attempts. Check Wi-Fi and tap Retry.',
      );
      return;
    }
    _setStatus(RefereeConnectionStatus.reconnecting);
    _scheduleReconnect(generation);
  }

  void _scheduleReconnect(int generation) {
    if (generation != _generation ||
        _stopping ||
        _pairing == null ||
        _reconnectAttempts >= _maxReconnectAttempts) {
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        _setStatus(
          RefereeConnectionStatus.disconnected,
          error:
              'Could not reconnect after $_maxReconnectAttempts attempts. Check Wi-Fi and tap Retry.',
        );
      }
      return;
    }
    const delays = [1, 2, 4, 8, 15];
    final seconds = delays[_reconnectAttempts++];
    _reconnect?.cancel();
    _reconnect = Timer(Duration(seconds: seconds), () {
      if (generation == _generation) unawaited(_connectClient(generation));
    });
  }

  @override
  Future<void> retryConnection() async {
    final details = _pairing;
    if (_isHost || details == null) {
      throw StateError('There is no referee pairing to retry.');
    }
    await _connectTo(details);
  }

  @override
  String sendAction(
    String action, {
    required RefereeActionContext context,
    int? term,
    String? messageId,
  }) {
    final details = _pairing;
    final snapshot = _snapshot;
    final socket = _client;
    if (_isHost ||
        details == null ||
        snapshot == null ||
        socket == null ||
        _status != RefereeConnectionStatus.connected) {
      throw StateError('No synchronized referee session is available.');
    }
    final id = messageId ?? _randomHex(16);
    final existing = _actionEnvelopes[id];
    late final Map<String, dynamic> envelope;
    if (existing != null) {
      final previousPayload = existing['payload'] as Map;
      if (previousPayload['action'] != action ||
          previousPayload['term'] != term ||
          existing['sessionId'] != context.sessionId ||
          existing['turnId'] != context.turnId ||
          existing['cardId'] != context.cardId ||
          existing['cardInstanceId'] != context.cardInstanceId ||
          existing['stateVersion'] != context.stateVersion) {
        throw StateError(
          'A message ID cannot be reused for a different action.',
        );
      }
      envelope = existing;
    } else {
      final current = RefereeActionContext.fromSnapshot(snapshot);
      if (!context.identifiesSameCard(current) ||
          context.stateVersion > current.stateVersion) {
        throw StateError('The displayed card or turn is no longer current.');
      }
      if (!_isAllowedAction(action, snapshot, term)) {
        throw ArgumentError.value(
          action,
          'action',
          'Not valid for this state.',
        );
      }
      if (_pendingActions.length >= 64) {
        throw StateError(
          'Wait for pending referee actions to be acknowledged.',
        );
      }
      final payload = <String, Object>{'action': action};
      if (term != null) payload['term'] = term;
      envelope = {
        'protocolVersion': protocolVersion,
        'type': 'referee_action',
        'sessionId': context.sessionId,
        'turnId': context.turnId,
        'cardId': context.cardId,
        'cardInstanceId': context.cardInstanceId,
        'messageId': id,
        'stateVersion': context.stateVersion,
        'payload': payload,
      };
      _actionEnvelopes[id] = envelope;
      if (_actionEnvelopes.length > 512) {
        _actionEnvelopes.remove(_actionEnvelopes.keys.first);
      }
    }
    _pendingActions[id] = envelope;
    _send(socket, envelope);
    _lastActionMessage = 'Sending…';
    _lastActionAccepted = null;
    notifyListeners();
    return id;
  }

  bool _isAllowedAction(
    String action,
    Map<String, dynamic> snapshot,
    int? term,
  ) {
    final game = snapshot['game'];
    final phase = snapshot['phase'];
    final review = phase == Phase.turnReview.name;
    if (review) {
      if (action == 'request_correction') return true;
      if (term == null || term < 0 || term >= 64) return false;
      return game == GameKind.sprint.name
          ? {
                  'review_term_correct',
                  'review_term_pending',
                  'review_term_disqualified',
                }.contains(action) &&
                term < 5
          : {
              'review_tabuu_correct',
              'review_tabuu_pass',
              'review_tabuu_buzz',
            }.contains(action);
    }
    if (phase != Phase.playing.name) return false;
    return game == GameKind.sprint.name
        ? term != null &&
              term >= 0 &&
              term < 5 &&
              {
                'mark_term_correct',
                'mark_term_pending',
                'disqualify_term',
              }.contains(action)
        : action == 'buzz' && term == null;
  }

  void _broadcastSnapshot() {
    final session = controller.session;
    final endSession =
        session == null ||
        !identical(session, _hostSession) ||
        session.phase == Phase.gameResults ||
        session.config.mode == PlayMode.classic;
    if (endSession) {
      final peer = _hostPeer;
      if (peer != null) {
        if (session != null && identical(session, _hostSession)) {
          _sendSnapshot(peer);
        }
        _send(peer, {
          'type': 'game_ended',
          'protocolVersion': protocolVersion,
          'sessionId': _pairing?.sessionId,
        });
      }
      final generation = _generation;
      Timer.run(() {
        if (generation == _generation) unawaited(stop());
      });
      return;
    }
    if (session.phase != Phase.turnReview) _correctionRequested = false;
    if (_hostPeer != null) _sendSnapshot(_hostPeer!);
  }

  void _sendSnapshot(WebSocket socket) {
    final session = controller.session;
    final details = _pairing;
    if (session == null ||
        details?.sessionId == null ||
        !identical(session, _hostSession)) {
      return;
    }
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
    final snapshot = <String, dynamic>{
      'protocolVersion': protocolVersion,
      'type': 'session_snapshot',
      'sessionId': details!.sessionId,
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
    };
    final validated = RefereeSnapshot.parse(
      snapshot,
      expectedSessionId: details.sessionId!,
    );
    final json = validated.toJson();
    if (identical(socket, _hostPeer)) {
      _snapshotSentVersion = session.stateVersion;
    }
    _send(socket, json);
  }

  Map<String, dynamic>? _decode(dynamic raw) {
    if (raw is! String || utf8.encode(raw).length > _maxMessageLength) {
      return null;
    }
    try {
      final value = jsonDecode(raw);
      return value is Map<String, dynamic> ? value : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  void _send(WebSocket socket, Map<String, dynamic> message) {
    if (socket.readyState != WebSocket.open) return;
    try {
      final key = identical(socket, _hostPeer)
          ? _hostKey
          : identical(socket, _client)
          ? _clientKey
          : null;
      socket.add(
        jsonEncode(key == null ? message : _signMessage(message, key)),
      );
    } on SocketException {
      if (identical(socket, _hostPeer)) {
        _peerDisconnected(socket, _generation);
      } else if (identical(socket, _client)) {
        _clientDisconnected(socket, _generation);
      }
    } on WebSocketException {
      if (identical(socket, _hostPeer)) {
        _peerDisconnected(socket, _generation);
      } else if (identical(socket, _client)) {
        _clientDisconnected(socket, _generation);
      }
    }
  }

  void _protocolFailure(WebSocket socket, String message) {
    _connectionError = message;
    _setStatus(RefereeConnectionStatus.authenticationFailed);
    unawaited(
      _closeSocket(socket, WebSocketStatus.policyViolation, 'Protocol error'),
    );
  }

  Future<void> _closeSocket(WebSocket socket, int code, String reason) async {
    try {
      await socket.close(code, reason).timeout(const Duration(seconds: 1));
    } on SocketException {
      // The socket is already closed.
    } on WebSocketException {
      // The socket is already closed.
    } on TimeoutException {
      // The operating system will release the socket after the close request.
    }
  }

  bool _isPrivate(String address) {
    final parsed = InternetAddress.tryParse(address);
    if (parsed == null || parsed.type != InternetAddressType.IPv4) return false;
    final bytes = parsed.rawAddress;
    return bytes[0] == 10 ||
        (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
        (bytes[0] == 192 && bytes[1] == 168);
  }

  String _randomHex(int bytes) => List.generate(
    bytes,
    (_) => _secureRandom.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  String _randomBase64Url(int bytes) => base64Url
      .encode(List.generate(bytes, (_) => _secureRandom.nextInt(256)))
      .replaceAll('=', '');

  bool _isPairingSessionId(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{22}$').hasMatch(value) ||
      RegExp(r'^[0-9a-f]{32}$').hasMatch(value);

  bool _isPairingToken(String value) =>
      RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(value) ||
      RegExp(r'^[0-9a-f]{64}$').hasMatch(value);

  String _pairingProof(String secret, String sessionId, String challenge) =>
      base64Url.encode(
        Hmac(sha256, utf8.encode(secret))
            .convert(
              utf8.encode('local-referee-v2-proof|$sessionId|$challenge'),
            )
            .bytes,
      );

  List<int> _deriveSessionKey(
    String secret,
    String sessionId,
    String challenge,
  ) => Hmac(sha256, utf8.encode(secret))
      .convert(utf8.encode('local-referee-v2-session|$sessionId|$challenge'))
      .bytes;

  Map<String, dynamic> _signMessage(
    Map<String, dynamic> message,
    List<int> key,
  ) {
    final unsigned = _unsignedMessage(message);
    final bytes = utf8.encode(jsonEncode(unsigned));
    final mac = base64Url.encode(Hmac(sha256, key).convert(bytes).bytes);
    return {...unsigned, 'mac': mac};
  }

  bool _verifySignedMessage(Map<String, dynamic> message, List<int> key) {
    final mac = message['mac'];
    if (mac is! String) return false;
    final expected = _signMessage(message, key)['mac'];
    return _constantTimeEquals(mac, expected);
  }

  Map<String, dynamic> _unsignedMessage(Map<String, dynamic> message) => {
    for (final entry in message.entries)
      if (entry.key != 'mac') entry.key: entry.value,
  };

  String _randomPairingCode() {
    final bytes = List<int>.generate(8, (_) => _secureRandom.nextInt(256));
    var buffer = 0;
    var bits = 0;
    final result = StringBuffer();
    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bits += 8;
      while (bits >= 5 && result.length < 12) {
        bits -= 5;
        result.write(_pairingAlphabet[(buffer >> bits) & 31]);
      }
    }
    return result.toString();
  }

  String? _normalisePairingCode(String value) {
    final code = value.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (code.length != 12 ||
        code
            .split('')
            .any((character) => !_pairingAlphabet.contains(character))) {
      return null;
    }
    return code;
  }

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

  void _startConnectivityMonitor(int generation) {
    if (!supported) return;
    _networkSubscription?.cancel();
    _networkSubscription = Connectivity().onConnectivityChanged.listen(
      (_) {
        if (generation != _generation || _stopping) return;
        if (!_isHost && _client == null && _pairing != null) {
          _reconnectAttempts = 0;
          _setStatus(RefereeConnectionStatus.reconnecting);
          _scheduleReconnect(generation);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (generation == _generation && !_stopping) {
          _connectionError =
              'Network change notifications are unavailable; connection health is monitored by heartbeat.';
          notifyListeners();
        }
      },
    );
  }

  void _setStatus(RefereeConnectionStatus value, {String? error}) {
    _status = value;
    if (error != null) _connectionError = error;
    if (value == RefereeConnectionStatus.connected ||
        value == RefereeConnectionStatus.waiting) {
      _connectionError = null;
    }
    if (!_disposed) notifyListeners();
  }

  @override
  Future<void> takeOverClassic() async {
    final peer = _hostPeer;
    final pairing = _pairing;
    if (peer != null && pairing?.sessionId != null) {
      _send(peer, {
        'type': 'game_ended',
        'protocolVersion': protocolVersion,
        'sessionId': pairing!.sessionId,
        'reason': 'classic_mode',
      });
    }
    await stop();
    controller.switchToClassic();
    if (controller.session?.turn?.paused == true) controller.resume();
  }

  @override
  void pauseForBackground() {
    if (controller.session?.phase == Phase.playing &&
        controller.session?.turn?.deadlineMs != null) {
      controller.pause();
    }
    final pairing = _pairing;
    if (pairing?.sessionId != null) {
      if (_isHost && _hostPeer != null) {
        _send(_hostPeer!, {
          'type': 'background',
          'protocolVersion': protocolVersion,
          'sessionId': pairing!.sessionId,
        });
      } else if (_client != null) {
        _send(_client!, {
          'type': 'background',
          'protocolVersion': protocolVersion,
          'sessionId': pairing!.sessionId,
        });
      }
    }
  }

  @override
  Future<void> resumeFromBackground() async {
    final pairing = _pairing;
    if (_stopping || pairing == null) return;
    final generation = _generation;
    _reconnectAttempts = 0;
    _reconnect?.cancel();
    _reconnect = null;

    if (_isHost) {
      final peer = _hostPeer;
      if (peer == null ||
          peer.readyState != WebSocket.open ||
          (DateTime.now().millisecondsSinceEpoch - _lastHeartbeatMs >
              _heartbeatTimeoutMs)) {
        if (peer != null) {
          await _closeSocket(
            peer,
            WebSocketStatus.goingAway,
            'Connection health check failed',
          );
        }
      } else {
        _send(peer, {
          'type': 'resume',
          'protocolVersion': protocolVersion,
          'sessionId': pairing.sessionId,
        });
        _sendSnapshot(peer);
      }
      return;
    }

    final socket = _client;
    if (socket == null ||
        socket.readyState != WebSocket.open ||
        (DateTime.now().millisecondsSinceEpoch - _lastHeartbeatAckMs >
            _heartbeatTimeoutMs)) {
      if (socket != null) {
        await _closeSocket(
          socket,
          WebSocketStatus.goingAway,
          'Connection health check failed',
        );
      } else {
        _setStatus(RefereeConnectionStatus.reconnecting);
        _scheduleReconnect(generation);
      }
      return;
    }
    _send(socket, {
      'type': 'resume',
      'protocolVersion': protocolVersion,
      'sessionId': pairing.sessionId,
    });
    _send(socket, {
      'type': 'request_snapshot',
      'protocolVersion': protocolVersion,
      'sessionId': pairing.sessionId,
    });
  }

  Future<void> _closeCurrent({
    required bool clearPairing,
    required bool clearSessionState,
  }) async {
    _stopping = true;
    _generation++;
    controller.removeListener(_broadcastSnapshot);
    _monitor?.cancel();
    _heartbeat?.cancel();
    _clientHandshakeTimeout?.cancel();
    _reconnect?.cancel();
    await _networkSubscription?.cancel();
    _networkSubscription = null;

    final sockets = <WebSocket>{
      if (_hostPeer != null) _hostPeer!,
      if (_client != null) _client!,
      ..._pendingPeerTimeouts.keys,
    };
    _hostPeer = null;
    _client = null;
    _hostSynchronized = false;
    _snapshotSentVersion = null;
    for (final timer in _pendingPeerTimeouts.values) {
      timer.cancel();
    }
    _pendingPeerTimeouts.clear();
    _peerChallenges.clear();
    await Future.wait([
      for (final subscription in _peerSubscriptions.values)
        subscription.cancel(),
    ]);
    _peerSubscriptions.clear();
    await _clientSubscription?.cancel();
    _clientSubscription = null;
    for (final socket in sockets) {
      unawaited(
        _closeSocket(socket, WebSocketStatus.goingAway, 'Session closed'),
      );
    }
    await _serverSubscription?.cancel();
    _serverSubscription = null;
    await _server?.close(force: true);
    _server = null;
    controller.setRefereeConnectionReady(false);

    if (clearPairing) _pairing = null;
    if (clearSessionState) {
      _snapshot = null;
      _receivedVersion = -1;
      _processedActions.clear();
      _actionEnvelopes.clear();
      _pendingActions.clear();
      _lastActionMessage = null;
      _lastActionAccepted = null;
      _correctionRequested = false;
    }
    _hostSession = null;
    _hostKey = null;
    _clientKey = null;
    _isHost = false;
    _reconnectAttempts = 0;
    _connectionError = null;
    _status = RefereeConnectionStatus.idle;
    _stopping = false;
  }

  @override
  Future<void> stop() async {
    await _closeCurrent(clearPairing: true, clearSessionState: true);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_closeCurrent(clearPairing: true, clearSessionState: true));
    super.dispose();
  }
}

class _ProcessedAction {
  const _ProcessedAction(this.fingerprint, this.response);
  final String fingerprint;
  final Map<String, dynamic> response;
}
