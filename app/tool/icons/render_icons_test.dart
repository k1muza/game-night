// Renders the PWA icons from the same LogoMarkPainter the app uses
// (design/brand/Brand-Logo.png: ink square, four fanned cards, spark).
// Run:  flutter test tool/icons/render_icons_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/theme/tokens.dart';
import 'package:game_night/ui/widgets/glyphs.dart';

Future<void> _render(String path, int size, {required bool maskable, bool sparkOnly = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  final bg = Paint()..color = Gn.table;
  if (maskable) {
    canvas.drawRect(Rect.fromLTWH(0, 0, s, s), bg);
  } else {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.22)), bg);
  }
  if (sparkOnly) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, s, s), Radius.circular(s * 0.22)), Paint()..color = Gn.spark);
    canvas.drawPath(sparkPath(Rect.fromLTWH(s * 0.18, s * 0.18, s * 0.64, s * 0.64)), Paint()..color = Gn.ink);
  } else {
    // Maskable icons keep the mark inside the 80% safe zone.
    final inset = maskable ? s * 0.2 : s * 0.1;
    canvas.save();
    canvas.translate(inset, inset);
    LogoMarkPainter().paint(canvas, Size(s - inset * 2, s - inset * 2));
    canvas.restore();
  }
  final img = await recorder.endRecording().toImage(size, size);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('render icons', () async {
    await _render('web/icons/Icon-192.png', 192, maskable: false);
    await _render('web/icons/Icon-512.png', 512, maskable: false);
    await _render('web/icons/Icon-maskable-192.png', 192, maskable: true);
    await _render('web/icons/Icon-maskable-512.png', 512, maskable: true);
    await _render('web/favicon.png', 32, maskable: false, sparkOnly: true);
  });
}
