import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/app.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/fx.dart';
import 'package:game_night/services/local_referee.dart';
import 'package:game_night/services/local_referee_types.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/theme/tokens.dart';
import 'package:game_night/ui/screens/local_referee.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'helpers.dart';

void main() {
  test('compact QR payload preserves entropy and lowers the QR version', () {
    final legacyPayload = jsonEncode({
      'v': 2,
      'host': '192.168.1.23',
      'port': 49152,
      'sessionId': '0123456789abcdef0123456789abcdef',
      'token':
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      'expiresAtMs': 1800000000000,
    });
    final legacy = PairingDetails.fromJson(jsonDecode(legacyPayload));
    expect(legacy.host, '192.168.1.23');
    expect(legacy.token, hasLength(64));

    final compact = PairingDetails(
      host: legacy.host,
      port: legacy.port,
      sessionId: base64Url
          .encode(List<int>.generate(16, (index) => index))
          .replaceAll('=', ''),
      token: base64Url
          .encode(List<int>.generate(32, (index) => index))
          .replaceAll('=', ''),
      expiresAtMs: legacy.expiresAtMs,
    );
    final compactJson = compact.json;
    final decoded = PairingDetails.fromJson(jsonDecode(compactJson));
    expect(decoded.host, compact.host);
    expect(decoded.sessionId, hasLength(22));
    expect(decoded.token, hasLength(43));
    expect(
      base64Url.decode(base64Url.normalize(decoded.token!)),
      hasLength(32),
    );
    expect(compactJson.length, lessThan(legacyPayload.length));

    final legacyQr = QrValidator.validate(
      data: legacyPayload,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    ).qrCode!;
    final compactQr = QrValidator.validate(
      data: compactJson,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    ).qrCode!;
    expect(legacyPayload.length, 192);
    expect(legacyQr.typeNumber, 10);
    expect(legacyQr.moduleCount, 57);
    expect(compactJson.length, 133);
    expect(compactQr.typeNumber, 8);
    expect(compactQr.moduleCount, 49);
    expect(compactQr.typeNumber, lessThan(legacyQr.typeNumber));
    expect(compactQr.moduleCount, lessThan(legacyQr.moduleCount));
  });

  testWidgets('host QR uses rounded modules and medium error correction', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(432, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await loadAppFonts();

    final harness = Harness();
    harness.controller.newSession(
      const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
      [Team('Team A', 0), Team('Team B', 1)],
    );
    const pairing = PairingDetails(
      host: '192.168.1.23',
      port: 49152,
      sessionId: 'AAECAwQFBgcICQoLDA0ODw',
      token: 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8',
      pairingCode: 'ABCDEFGHJKLM',
      expiresAtMs: 1800000000000,
    );
    final referee = _PairingService(harness.controller, pairing);
    addTearDown(referee.dispose);
    final nav = AppNav();
    addTearDown(nav.dispose);

    await tester.pumpWidget(
      AppScope(
        controller: harness.controller,
        fx: SilentFx(),
        store: harness.store,
        referee: referee,
        nav: nav,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const HostPairingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    final decoded = PairingDetails.fromJson(jsonDecode(pairing.json));
    expect(decoded.host, pairing.host);
    expect(decoded.port, pairing.port);
    expect(decoded.sessionId, pairing.sessionId);
    expect(decoded.token, pairing.token);
    expect(qr.errorCorrectionLevel, QrErrorCorrectLevel.M);
    expect(qr.size, 260);
    expect(qr.padding, const EdgeInsets.all(14));
    expect(qr.eyeStyle.eyeShape, QrEyeShape.circle);
    expect(qr.dataModuleStyle.dataModuleShape, QrDataModuleShape.circle);
    expect(qr.backgroundColor, Gn.card);
    expect(qr.semanticsLabel, 'Secure referee pairing QR code');
    expect(find.text('SCAN TO PAIR'), findsOneWidget);
  });
}

class _PairingService extends LocalRefereeService {
  _PairingService(super.controller, this._pairing);

  final PairingDetails _pairing;

  @override
  bool get supported => true;
  @override
  bool get isHost => true;
  @override
  bool get isHostConnected => false;
  @override
  bool get correctionRequested => false;
  @override
  RefereeConnectionStatus get status => RefereeConnectionStatus.waiting;
  @override
  PairingDetails get pairing => _pairing;
  @override
  Map<String, dynamic>? get snapshot => null;
  @override
  String? get lastActionMessage => null;
  @override
  bool? get lastActionAccepted => null;
  @override
  String? get connectionError => null;

  @override
  Future<PairingDetails> startHost() async => _pairing;
  @override
  Future<void> connect(String pairingJson) async =>
      throw UnsupportedError('Not used in this widget test.');
  @override
  Future<void> connectManual({
    required String host,
    required int port,
    required String pairingCode,
  }) async => throw UnsupportedError('Not used in this widget test.');
  @override
  Future<void> retryConnection() async =>
      throw UnsupportedError('Not used in this widget test.');
  @override
  String sendAction(
    String action, {
    required RefereeActionContext context,
    int? term,
    String? messageId,
  }) => throw UnsupportedError('Not used in this widget test.');
  @override
  Future<void> stop() async {}
  @override
  Future<void> takeOverClassic() async {}
  @override
  void pauseForBackground() {}
}
