import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../session/session_controller.dart';

enum RefereeConnectionStatus {
  idle,
  waiting,
  connecting,
  connected,
  reconnecting,
  disconnected,
  unsupported,
}

class PairingDetails {
  const PairingDetails({
    required this.host,
    required this.port,
    required this.sessionId,
    required this.token,
  });

  final String host;
  final int port;
  final String sessionId;
  final String token;

  Map<String, Object> toJson() => {
    'v': 1,
    'host': host,
    'port': port,
    'sessionId': sessionId,
    'token': token,
  };

  String get encoded => Uri.encodeComponent(json);
  String get json => jsonEncode(toJson());
}

abstract class LocalRefereeService extends ChangeNotifier {
  LocalRefereeService(this.controller);

  final SessionController controller;
  bool get supported;
  bool get isHost;
  bool get isHostConnected;
  bool get correctionRequested;
  RefereeConnectionStatus get status;
  PairingDetails? get pairing;
  Map<String, dynamic>? get snapshot;
  String? get lastActionMessage;
  bool? get lastActionAccepted;

  Future<PairingDetails> startHost();
  Future<void> connect(String pairingJson);
  String sendAction(String action, {int? term, String? messageId});
  Future<void> stop();
  Future<void> takeOverClassic();
  void pauseForBackground();
}
