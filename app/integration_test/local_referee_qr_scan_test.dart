import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/model/cards.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/local_referee.dart';
import 'package:game_night/services/local_referee_io.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/session/session_controller.dart';
import 'package:game_night/session/store.dart';
import 'package:game_night/theme/tokens.dart';
import 'package:game_night/ui/screens/local_referee.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scans styled host QR and pairs through the referee flow', (
    tester,
  ) async {
    final library = await ContentLibrary.load(rootBundle);
    final hostController =
        SessionController(library: library, store: MemorySessionStore())
          ..newSession(
            const GameConfig(game: GameKind.forbidden, mode: PlayMode.referee),
            [Team('Team A', 0), Team('Team B', 1)],
          );
    final refereeController = SessionController(
      library: library,
      store: MemorySessionStore(),
    );
    final host = IoLocalRefereeService(
      hostController,
      allowLoopbackForTesting: true,
    );
    final referee = IoLocalRefereeService(
      refereeController,
      allowLoopbackForTesting: true,
    );
    final scanner = MobileScannerController();
    final imageFile = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}referee-qr.png',
    );
    addTearDown(() async {
      await referee.stop();
      await host.stop();
      await scanner.dispose();
      if (await imageFile.exists()) await imageFile.delete();
    });

    final pairing = await tester.runAsync(host.startHost);
    expect(pairing, isNotNull);
    final details = pairing!;
    expect(details.sessionId, hasLength(22));
    expect(
      base64Url.decode(base64Url.normalize(details.sessionId!)),
      hasLength(16),
    );
    expect(details.token, hasLength(43));
    expect(
      base64Url.decode(base64Url.normalize(details.token!)),
      hasLength(32),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          backgroundColor: Gn.table,
          body: Center(child: HostPairingQrCode(pairing: details)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('host-pairing-qr')),
    );
    final image = await boundary.toImage(pixelRatio: 3);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await imageFile.writeAsBytes(
      png!.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
    );

    final capture = await tester.runAsync(
      () => scanner.analyzeImage(
        imageFile.path,
        formats: const [BarcodeFormat.qrCode],
      ),
    );
    expect(capture, isNotNull);
    expect(capture!.barcodes, hasLength(1));
    final scannedPairing = capture.barcodes.single.rawValue;
    expect(scannedPairing, details.json);

    await tester.runAsync(() async {
      await referee.connect(scannedPairing!);
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (referee.status != RefereeConnectionStatus.connected &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    });
    expect(referee.status, RefereeConnectionStatus.connected);
    expect(referee.snapshot?['sessionId'], details.sessionId);
  });
}
