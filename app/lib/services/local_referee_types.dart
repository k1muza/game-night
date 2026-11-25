import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/game_kind.dart';
import '../session/session.dart';
import '../session/session_controller.dart';

enum RefereeConnectionStatus {
  idle,
  waiting,
  connecting,
  synchronizing,
  connected,
  reconnecting,
  disconnected,
  authenticationFailed,
  unsupported,
}

class PairingDetails {
  const PairingDetails({
    required this.host,
    required this.port,
    this.sessionId,
    this.token,
    this.pairingCode,
    this.expiresAtMs,
  });

  final String host;
  final int port;
  final String? sessionId;
  final String? token;
  final String? pairingCode;
  final int? expiresAtMs;

  Map<String, Object> toJson() => {
    'v': 2,
    'host': host,
    'port': port,
    if (sessionId != null) 'sessionId': sessionId!,
    if (token != null) 'token': token!,
    if (expiresAtMs != null) 'expiresAtMs': expiresAtMs!,
  };

  String get json => jsonEncode(toJson());
  String get encoded => Uri.encodeComponent(json);

  factory PairingDetails.fromJson(Object? value) {
    if (value is! Map<String, dynamic> ||
        value['v'] != 2 ||
        value['host'] is! String ||
        value['port'] is! int) {
      throw const FormatException('Pairing data is invalid.');
    }
    return PairingDetails(
      host: value['host'] as String,
      port: value['port'] as int,
      sessionId: value['sessionId'] is String
          ? value['sessionId'] as String
          : null,
      token: value['token'] is String ? value['token'] as String : null,
      pairingCode: value['pairingCode'] is String
          ? value['pairingCode'] as String
          : null,
      expiresAtMs: value['expiresAtMs'] is int
          ? value['expiresAtMs'] as int
          : null,
    );
  }
}

@immutable
class RefereeActionContext {
  const RefereeActionContext({
    required this.sessionId,
    required this.turnId,
    required this.cardId,
    required this.cardInstanceId,
    required this.stateVersion,
  });

  final String sessionId;
  final String turnId;
  final String? cardId;
  final String cardInstanceId;
  final int stateVersion;

  factory RefereeActionContext.fromSnapshot(Map<String, dynamic> snapshot) {
    final sessionId = snapshot['sessionId'];
    final turnId = snapshot['turnId'];
    final cardId = snapshot['cardId'];
    final cardInstanceId = snapshot['cardInstanceId'];
    final stateVersion = snapshot['stateVersion'];
    if (sessionId is! String ||
        sessionId.isEmpty ||
        turnId is! String ||
        turnId.isEmpty ||
        (cardId != null && cardId is! String) ||
        cardInstanceId is! String ||
        cardInstanceId.isEmpty ||
        stateVersion is! int ||
        stateVersion < 0) {
      throw const FormatException('Snapshot has no valid action context.');
    }
    return RefereeActionContext(
      sessionId: sessionId,
      turnId: turnId,
      cardId: cardId as String?,
      cardInstanceId: cardInstanceId,
      stateVersion: stateVersion,
    );
  }

  Map<String, Object?> toJson() => {
    'sessionId': sessionId,
    'turnId': turnId,
    'cardId': cardId,
    'cardInstanceId': cardInstanceId,
    'stateVersion': stateVersion,
  };

  bool identifiesSameCard(RefereeActionContext other) =>
      sessionId == other.sessionId &&
      turnId == other.turnId &&
      cardId == other.cardId &&
      cardInstanceId == other.cardInstanceId;
}

@immutable
class RefereeSnapshot {
  const RefereeSnapshot._(this._json);

  final Map<String, dynamic> _json;

  Map<String, dynamic> toJson() => Map<String, dynamic>.unmodifiable(_json);

  factory RefereeSnapshot.parse(
    Map<String, dynamic> json, {
    required String expectedSessionId,
  }) {
    final game = json['game'];
    final phase = json['phase'];
    final version = json['stateVersion'];
    final team = json['team'];
    final scores = json['scores'];
    final marked = json['marked'];
    final disqualified = json['disqualified'];
    final duration = json['durationMs'];
    final remaining = json['remainingMs'];
    final card = json['card'];
    final review = json['review'];
    final turnId = json['turnId'];
    final cardId = json['cardId'];
    final cardInstanceId = json['cardInstanceId'];

    if (json['type'] != 'session_snapshot' ||
        json['protocolVersion'] != 2 ||
        json['sessionId'] != expectedSessionId ||
        version is! int ||
        version < 0 ||
        (game != GameKind.sprint.name && game != GameKind.forbidden.name) ||
        !Phase.values.any((value) => value.name == phase) ||
        team is! Map<String, dynamic> ||
        team['name'] is! String ||
        (team['name'] as String).isEmpty ||
        (team['name'] as String).length > 64 ||
        team['paletteIndex'] is! int ||
        (team['paletteIndex'] as int) < 0 ||
        (team['paletteIndex'] as int) >= 6 ||
        scores is! List ||
        scores.length < 2 ||
        scores.length > 6 ||
        scores.any((score) => score is! int || score.abs() > 1000000) ||
        marked is! List ||
        marked.any((index) => index is! int || index < 0 || index >= 5) ||
        disqualified is! List ||
        disqualified.any((index) => index is! int || index < 0 || index >= 5) ||
        duration is! int ||
        duration < 0 ||
        remaining is! int ||
        remaining < 0 ||
        remaining > duration + 1000 ||
        json['paused'] is! bool ||
        (turnId != null && !_boundedString(turnId, 128)) ||
        (cardId != null && !_boundedString(cardId, 128)) ||
        (cardInstanceId != null && !_boundedString(cardInstanceId, 128)) ||
        (card != null && card is! Map<String, dynamic>) ||
        (review != null && review is! Map<String, dynamic>)) {
      throw const FormatException('Snapshot fields are invalid.');
    }

    if (phase == Phase.playing.name && turnId == null) {
      throw const FormatException('Active snapshot has no turn identity.');
    }
    if (phase == Phase.playing.name &&
        cardId != null &&
        (cardInstanceId == null || card == null)) {
      throw const FormatException('Active card identity or data is missing.');
    }
    if (card != null) {
      if (game == GameKind.sprint.name) {
        final terms = card['terms'];
        if (terms is! List ||
            terms.length != 5 ||
            terms.any(
              (term) =>
                  term is! Map<String, dynamic> ||
                  !_boundedString(term['text'], 96) ||
                  (term['context'] != null &&
                      !_boundedString(term['context'], 96)),
            )) {
          throw const FormatException('Sprint card data is invalid.');
        }
      } else {
        final clues = card['clues'];
        if (!_boundedString(card['target'], 96) ||
            clues is! List ||
            clues.length != 5 ||
            clues.any((clue) => !_boundedString(clue, 96))) {
          throw const FormatException('Tabuu card data is invalid.');
        }
      }
    }
    if (review != null) {
      final events = review['events'];
      if (review['points'] is! int ||
          (review['points'] as int).abs() > 1000000 ||
          events is! List ||
          events.length > 64 ||
          events.any(
            (event) =>
                event is! Map<String, dynamic> ||
                !_boundedString(event['label'], 96) ||
                !Outcome.values.any(
                  (outcome) => outcome.name == event['outcome'],
                ),
          )) {
        throw const FormatException('Review data is invalid.');
      }
    }

    return RefereeSnapshot._(Map<String, dynamic>.unmodifiable(json));
  }
}

@immutable
class RefereeActionResult {
  const RefereeActionResult({
    required this.messageId,
    required this.accepted,
    required this.reason,
    required this.stateVersion,
  });

  final String messageId;
  final bool accepted;
  final String? reason;
  final int stateVersion;

  factory RefereeActionResult.parse(
    Map<String, dynamic> json, {
    required String expectedMessageId,
  }) {
    final version = json['stateVersion'];
    final reason = json['reason'];
    if (json['type'] != 'action_result' ||
        json['messageId'] != expectedMessageId ||
        json['accepted'] is! bool ||
        (reason != null && reason is! String) ||
        version is! int ||
        version < 0) {
      throw const FormatException('Action result is invalid.');
    }
    return RefereeActionResult(
      messageId: expectedMessageId,
      accepted: json['accepted'] as bool,
      reason: reason as String?,
      stateVersion: version,
    );
  }
}

bool _boundedString(Object? value, int maxLength) =>
    value is String && value.isNotEmpty && value.length <= maxLength;

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
  String? get connectionError;

  Future<PairingDetails> startHost();
  Future<void> connect(String pairingJson);
  Future<void> connectManual({
    required String host,
    required int port,
    required String pairingCode,
  });
  Future<void> retryConnection();
  String sendAction(
    String action, {
    required RefereeActionContext context,
    int? term,
    String? messageId,
  });
  Future<void> stop();
  Future<void> takeOverClassic();
  void pauseForBackground();
}
