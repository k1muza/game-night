// Design tokens transcribed from design/design-system/tokens.json
// (Direction C · "Card Table"). Keep in sync with that file.
import 'package:flutter/material.dart';

import '../model/game_kind.dart';

abstract final class Gn {
  // Colour · surfaces
  static const table = Color(0xFF110E22);
  static const sheet = Color(0xFF0A0818);
  static const surface1 = Color(0xFF1B1733);
  static const surface2 = Color(0xFF262046);
  static const border = Color(0xFF3B3466);
  static const lipDark = Color(0xFF0D0B1C);

  // Colour · text
  static const text1 = Color(0xFFF7F4FF);
  static const text2 = Color(0xFFBEB7DE);
  static const text3 = Color(0xFF948CBD);

  // Colour · cards
  static const card = Color(0xFFFFF8EC);
  static const cardPressed = Color(0xFFF0E5D2);
  static const cardRow = Color(0xFFF3E9D6);
  static const onCard = Color(0xFF16122B);
  static const onCardMuted = Color(0xFF5B5478);
  static const cardLip = Color(0xFFB9AE98);
  static const ink = Color(0xFF110E22);

  // Colour · brand and states
  static const spark = Color(0xFFFFD23F);
  static const correct = Color(0xFF3EE0A8);
  static const correctDeep = Color(0xFF17A777);
  static const warning = Color(0xFFFFB020);
  static const violation = Color(0xFFFF5A6E);
  static const violationDeep = Color(0xFFC93A4C);

  /// Background used during the last five seconds ("the table warms").
  static const warmTable = Color(0xFF2B2110);

  // Type
  static const display = 'Bricolage Grotesque';
  static const ui = 'Inter';

  // Radius
  static const rXs = 8.0, rSm = 12.0, rMd = 16.0, rLg = 20.0, rXl = 24.0, r2xl = 32.0;

  // Touch
  static const touchMin = 48.0;
  static const primaryButton = 60.0;
  static const termRow = 76.0;
  static const answerTile = 80.0;

  // Motion
  static const quick = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const spring = Duration(milliseconds: 280);
  static const reveal = Duration(milliseconds: 600);
  static const springCurve = Cubic(.34, 1.56, .64, 1);
  static const easeOut = Cubic(.2, .8, .2, 1);

  static TextStyle displayStyle(double size, {Color color = text1, double height = 1.05, double spacing = -0.02}) =>
      TextStyle(
        fontFamily: display,
        fontFamilyFallback: const [ui],
        fontWeight: FontWeight.w800,
        fontSize: size,
        height: height,
        letterSpacing: size * spacing,
        color: color,
      );

  static TextStyle uiStyle(double size, {Color color = text1, FontWeight weight = FontWeight.w600, double? height}) =>
      TextStyle(fontFamily: ui, fontWeight: weight, fontSize: size, color: color, height: height);

  static TextStyle eyebrow(Color color) =>
      TextStyle(fontFamily: ui, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.6, color: color);
}

class GamePalette {
  const GamePalette(this.accent, this.deep, this.soft);
  final Color accent;
  final Color deep;
  final Color soft;
  Color get onAccent => Gn.ink;
}

extension GameColors on GameKind {
  GamePalette get palette => switch (this) {
        GameKind.sprint => const GamePalette(Color(0xFFFFD23F), Color(0xFFC99A00), Color(0xFF3A3215)),
        GameKind.charades => const GamePalette(Color(0xFF3EE0A8), Color(0xFF17A777), Color(0xFF143A31)),
        GameKind.trivia => const GamePalette(Color(0xFF5B94FF), Color(0xFF2E63D1), Color(0xFF17254A)),
        GameKind.forbidden => const GamePalette(Color(0xFFFF7A52), Color(0xFFD9482A), Color(0xFF3D1E18)),
      };
}

enum TeamShape { circle, triangle, square, diamond, hex, star }

class TeamStyle {
  const TeamStyle(this.color, this.shape, this.defaultName);
  final Color color;
  final TeamShape shape;
  final String defaultName;
}

/// Team colours and shapes from tokens.json. Shapes pair with colour so teams
/// are never distinguished by colour alone.
const teamStyles = <TeamStyle>[
  TeamStyle(Color(0xFF2BB3A8), TeamShape.circle, 'Team A'),
  TeamStyle(Color(0xFF5CC8FF), TeamShape.triangle, 'Team B'),
  TeamStyle(Color(0xFFFF7AB6), TeamShape.square, 'Team C'),
  TeamStyle(Color(0xFFB4E33D), TeamShape.diamond, 'Team D'),
  TeamStyle(Color(0xFFB89CFF), TeamShape.hex, 'Team E'),
  TeamStyle(Color(0xFFC9A27E), TeamShape.star, 'Team F'),
];

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Gn.table,
    fontFamily: Gn.ui,
    colorScheme: const ColorScheme.dark(
      primary: Gn.spark,
      onPrimary: Gn.ink,
      surface: Gn.surface1,
      onSurface: Gn.text1,
      error: Gn.violation,
    ),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: Gn.spark, selectionColor: Color(0x55FFD23F)),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    useMaterial3: true,
  );
}
