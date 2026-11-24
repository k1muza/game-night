// Vector marks from the brand boards (design/brand/Brand-Games.png,
// Brand-Logo.png): game glyphs, team shapes, the spark and the four-card mark.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/game_kind.dart';
import '../../theme/tokens.dart';

/// Team / answer shape on a 24×24 grid.
Path shapePath(TeamShape s, double size) {
  final k = size / 24;
  final p = Path();
  switch (s) {
    case TeamShape.circle:
      p.addOval(Rect.fromCircle(center: Offset(12 * k, 12 * k), radius: 9.5 * k));
    case TeamShape.triangle:
      p
        ..moveTo(12 * k, 2.5 * k)
        ..lineTo(22.5 * k, 21 * k)
        ..lineTo(1.5 * k, 21 * k)
        ..close();
    case TeamShape.square:
      p.addRRect(RRect.fromLTRBR(3.5 * k, 3.5 * k, 20.5 * k, 20.5 * k, Radius.circular(3 * k)));
    case TeamShape.diamond:
      p
        ..moveTo(12 * k, 1.5 * k)
        ..lineTo(22.5 * k, 12 * k)
        ..lineTo(12 * k, 22.5 * k)
        ..lineTo(1.5 * k, 12 * k)
        ..close();
    case TeamShape.hex:
      for (var i = 0; i < 6; i++) {
        final a = pi / 6 + i * pi / 3;
        final pt = Offset((12 + 10.5 * cos(a)) * k, (12 + 10.5 * sin(a)) * k);
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      p.close();
    case TeamShape.star:
      for (var i = 0; i < 10; i++) {
        final r = i.isEven ? 11.0 : 4.8;
        final a = -pi / 2 + i * pi / 5;
        final pt = Offset((12 + r * cos(a)) * k, (12.6 + r * sin(a)) * k);
        i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
      }
      p.close();
  }
  return p;
}

class ShapeIcon extends StatelessWidget {
  const ShapeIcon(this.shape, {super.key, required this.color, this.size = 18, this.stroke});
  final TeamShape shape;
  final Color color;
  final double size;

  /// Optional ink outline (used on cream cards).
  final Color? stroke;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _ShapePainter(shape, color, stroke)),
      );
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape, this.color, this.stroke);
  final TeamShape shape;
  final Color color;
  final Color? stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = shapePath(shape, size.width);
    canvas.drawPath(path, Paint()..color = color);
    if (stroke != null) {
      canvas.drawPath(
          path,
          Paint()
            ..color = stroke!
            ..style = PaintingStyle.stroke
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = size.width / 16);
    }
  }

  @override
  bool shouldRepaint(_ShapePainter o) => o.shape != shape || o.color != color || o.stroke != stroke;
}

class TeamMark extends StatelessWidget {
  const TeamMark(this.paletteIndex, {super.key, this.size = 18, this.stroke});
  final int paletteIndex;
  final double size;
  final Color? stroke;

  @override
  Widget build(BuildContext context) {
    final st = teamStyles[paletteIndex];
    return ShapeIcon(st.shape, color: st.color, size: size, stroke: stroke);
  }
}

/// The four-point spark: the brand's "moment a guess lands".
class Spark extends StatelessWidget {
  const Spark({super.key, this.size = 16, this.color = Gn.spark});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _SparkPainter(color)));
}

Path sparkPath(Rect r) {
  final c = r.center, w = r.width / 2, h = r.height / 2;
  const t = 0.16;
  return Path()
    ..moveTo(c.dx, c.dy - h)
    ..quadraticBezierTo(c.dx + w * t, c.dy - h * t, c.dx + w, c.dy)
    ..quadraticBezierTo(c.dx + w * t, c.dy + h * t, c.dx, c.dy + h)
    ..quadraticBezierTo(c.dx - w * t, c.dy + h * t, c.dx - w, c.dy)
    ..quadraticBezierTo(c.dx - w * t, c.dy - h * t, c.dx, c.dy - h)
    ..close();
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(sparkPath(Offset.zero & size), Paint()..color = color);
  @override
  bool shouldRepaint(_SparkPainter o) => o.color != color;
}

/// Game glyph: Sprint stacked bars, Charades figure, Trivia shapes, Forbidden bubble.
class GameGlyph extends StatelessWidget {
  const GameGlyph(this.game, {super.key, this.size = 24, this.color = Gn.ink, this.cut = Gn.card});
  final GameKind game;
  final double size;
  final Color color;

  /// Colour of the strike-through cut on the Forbidden bubble (the background).
  final Color cut;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _GlyphPainter(game, color, cut)));
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.game, this.color, this.cut);
  final GameKind game;
  final Color color;
  final Color cut;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.6 * k
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    switch (game) {
      case GameKind.sprint:
        // Five terms racing down: bars that shorten, with a lead dot.
        const rows = [(4.0, 4.0), (8.5, 6.0), (13.0, 8.0), (17.5, 10.0)];
        for (final (y, x) in rows) {
          canvas.drawLine(Offset(x * k, y * k), Offset(21 * k, y * k), line);
        }
        canvas.drawCircle(Offset(5 * k, 20.5 * k), 1.9 * k, fill);
      case GameKind.charades:
        // A figure with arms up.
        canvas.drawCircle(Offset(12 * k, 4 * k), 2.6 * k, fill);
        final body = Path()
          ..moveTo(4.5 * k, 6.5 * k)
          ..lineTo(12 * k, 10 * k)
          ..lineTo(19.5 * k, 6.5 * k)
          ..moveTo(12 * k, 10 * k)
          ..lineTo(12 * k, 14.5 * k)
          ..lineTo(7.5 * k, 21.5 * k)
          ..moveTo(12 * k, 14.5 * k)
          ..lineTo(16.5 * k, 21.5 * k);
        canvas.drawPath(body, line..strokeJoin = StrokeJoin.round);
      case GameKind.trivia:
        // The four answer shapes.
        void at(TeamShape s, double dx, double dy) {
          canvas.save();
          canvas.translate(dx * k, dy * k);
          canvas.drawPath(shapePath(s, 10 * k), fill);
          canvas.restore();
        }
        at(TeamShape.triangle, 1.5, 1.5);
        at(TeamShape.diamond, 12.5, 1.5);
        at(TeamShape.circle, 1.5, 12.5);
        at(TeamShape.square, 12.5, 12.5);
      case GameKind.forbidden:
        // A speech bubble, struck through.
        final bubble = Path()
          ..addRRect(RRect.fromLTRBR(2 * k, 3 * k, 22 * k, 17 * k, Radius.circular(3.5 * k)))
          ..moveTo(5 * k, 16 * k)
          ..lineTo(4.5 * k, 22 * k)
          ..lineTo(11 * k, 16 * k)
          ..close();
        canvas.drawPath(bubble, fill);
        canvas.drawLine(
            Offset(7 * k, 13 * k),
            Offset(17 * k, 7 * k),
            Paint()
              ..color = cut
              ..strokeWidth = 2.6 * k
              ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter o) => o.game != game || o.color != color || o.cut != cut;
}

/// Ink tile holding a game glyph, as on the home cards.
class GlyphTile extends StatelessWidget {
  const GlyphTile(this.game, {super.key, this.size = 44});
  final GameKind game;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Gn.ink, borderRadius: BorderRadius.circular(size * 0.3)),
        alignment: Alignment.center,
        child: GameGlyph(game, size: size * 0.55, color: game.palette.accent, cut: Gn.ink),
      );
}

/// Background motif per game (Brand-Games board): stripes, burst, shapes, hatch.
class GameMotif extends StatelessWidget {
  const GameMotif(this.game, {super.key});
  final GameKind game;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _MotifPainter(game), child: const SizedBox.expand());
}

class _MotifPainter extends CustomPainter {
  _MotifPainter(this.game);
  final GameKind game;

  @override
  void paint(Canvas canvas, Size s) {
    final c = game.palette.deep.withValues(alpha: 0.38);
    final p = Paint()
      ..color = c
      ..strokeCap = StrokeCap.round;
    switch (game) {
      case GameKind.sprint:
        p.strokeWidth = 14;
        for (var i = 0; i < 3; i++) {
          final y = 22.0 + i * 30;
          canvas.drawLine(Offset(s.width * 0.42 + i * 18, y), Offset(s.width - 16, y), p);
        }
      case GameKind.charades:
        p.strokeWidth = 4;
        final o = Offset(s.width * 0.74, s.height * 0.42);
        for (var i = 0; i < 12; i++) {
          final a = i * pi / 6;
          canvas.drawLine(o + Offset(cos(a), sin(a)) * 14, o + Offset(cos(a), sin(a)) * 74, p);
        }
      case GameKind.trivia:
        void at(TeamShape sh, double x, double y, double sz) {
          canvas.save();
          canvas.translate(x, y);
          canvas.drawPath(shapePath(sh, sz), p);
          canvas.restore();
        }
        at(TeamShape.diamond, s.width * 0.62, 18, 40);
        at(TeamShape.square, s.width * 0.84, 70, 34);
        at(TeamShape.circle, s.width * 0.66, 104, 30);
        at(TeamShape.triangle, s.width * 0.86, 4, 28);
      case GameKind.forbidden:
        p.strokeWidth = 16;
        for (var x = -s.height; x < s.width + s.height; x += 46) {
          canvas.drawLine(Offset(x, s.height), Offset(x + s.height * 0.8, 0), p);
        }
    }
  }

  @override
  bool shouldRepaint(_MotifPainter o) => o.game != game;
}

/// The mark: a hand of four cards, one per game, top card carrying the spark.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: LogoMarkPainter()));
}

class LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 100;
    final cards = [
      (GameKind.trivia.palette.accent, -0.42, 30.0),
      (GameKind.charades.palette.accent, -0.22, 40.0),
      (GameKind.forbidden.palette.accent, -0.02, 50.0),
      (Gn.card, 0.20, 60.0),
    ];
    for (final (color, angle, cx) in cards) {
      canvas.save();
      canvas.translate(cx * k, 54 * k);
      canvas.rotate(angle);
      final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 40 * k, height: 54 * k),
          Radius.circular(7 * k));
      canvas.drawRRect(r.shift(Offset(0, 2.5 * k)), Paint()..color = Colors.black.withValues(alpha: 0.25));
      canvas.drawRRect(r, Paint()..color = color);
      if (color == Gn.card) {
        canvas.drawPath(sparkPath(Rect.fromCenter(center: Offset.zero, width: 20 * k, height: 20 * k)),
            Paint()..color = Gn.ink);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(LogoMarkPainter oldDelegate) => false;
}
