import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:game_night/model/cards.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/session/session_controller.dart';
import 'package:game_night/session/store.dart';

ContentLibrary? _lib;

/// The real runtime decks produced by tool/build_content.dart.
ContentLibrary realLibrary() => _lib ??= ContentLibrary.fromJson(
      sprint: File('assets/decks/sprint.json').readAsStringSync(),
      charades: File('assets/decks/charades.json').readAsStringSync(),
      trivia: File('assets/decks/trivia.json').readAsStringSync(),
      forbidden: File('assets/decks/forbidden.json').readAsStringSync(),
    );

class FakeClock {
  int ms = 1700000000000;
  int call() => ms;
  void advance(Duration d) => ms += d.inMilliseconds;
}

class Harness {
  Harness({ContentLibrary? library, MemorySessionStore? store, int seed = 7})
      : clock = FakeClock(),
        store = store ?? MemorySessionStore() {
    controller = SessionController(
        library: library ?? realLibrary(), store: this.store, now: clock.call, random: Random(seed));
  }

  final FakeClock clock;
  final MemorySessionStore store;
  late final SessionController controller;

  Session get s => controller.session!;

  void start(GameKind g, {int teams = 2, int rounds = 5, Difficulty? difficulty, int questions = 5, PlayMode mode = PlayMode.classic}) {
    controller.newSession(
      GameConfig(game: g, rounds: rounds, difficulty: difficulty, questionsPerTurn: questions, mode: mode),
      [for (var i = 0; i < teams; i++) Team('Team ${String.fromCharCode(65 + i)}', i)],
    );
  }

  /// A fresh controller over the same store and clock — simulates a page refresh.
  SessionController reload() {
    final c = SessionController(library: controller.library, store: store, now: clock.call, random: Random(99));
    c.restore();
    return c;
  }
}

/// Loads the real brand fonts so widget tests lay out text like the app does
/// (instead of the square "Ahem" test font).
Future<void> loadAppFonts() async {
  final families = {
    'Bricolage Grotesque': ['BricolageGrotesque-Bold', 'BricolageGrotesque-ExtraBold'],
    'Inter': ['Inter-Medium', 'Inter-SemiBold', 'Inter-Bold', 'Inter-ExtraBold'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(Future.value(ByteData.sublistView(File('assets/fonts/$f.ttf').readAsBytesSync())));
    }
    await loader.load();
  }
}
