// Widget-level journeys with a fake clock: no real waiting, deterministic.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_night/app.dart';
import 'package:game_night/model/game_kind.dart';
import 'package:game_night/services/fx.dart';
import 'package:game_night/services/local_referee_types.dart';
import 'package:game_night/session/session.dart';
import 'package:game_night/ui/screens/local_referee.dart';
import 'package:game_night/ui/widgets/common.dart';

import 'helpers.dart';

class AppHarness {
  AppHarness() {
    h.store.flags.addAll({
      for (final g in GameKind.values) 'rules.${g.name}': true,
    });
  }
  final h = Harness();
  final fx = SilentFx();

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      GameNightApp(controller: h.controller, fx: fx, store: h.store),
    );
    await t.pump();
  }

  /// Advances both the fake wall clock and Flutter's fake time.
  Future<void> advance(WidgetTester t, Duration d) async {
    const step = Duration(milliseconds: 100);
    var left = d;
    while (left > Duration.zero) {
      final s = left < step ? left : step;
      h.clock.advance(s);
      await t.pump(s);
      left -= s;
    }
  }

  Future<void> startViaHandover(WidgetTester t) async {
    await t.pump(
      const Duration(milliseconds: 800),
    ); // screens ignore taps briefly (InputGuard)
    await t.tap(find.textContaining(RegExp(r'^Start the (clock|questions)$')));
    await advance(t, const Duration(milliseconds: 2100)); // 3-2-1
    expect(h.s.phase, Phase.playing);
  }
}

Future<void> tapText(WidgetTester t, String text) async {
  await t.tap(find.text(text).last);
  await t.pump(
    const Duration(milliseconds: 800),
  ); // let the next screen's tap guard lapse
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('referee live indicator respects rebuilds and reduced motion', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RefereeLiveIndicator(status: RefereeConnectionStatus.connected),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 100));
    expect(find.byType(RefereeLiveIndicator), findsOneWidget);

    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RefereeLiveIndicator(status: RefereeConnectionStatus.connected),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 100));
    expect(find.text('Referee'), findsOneWidget);

    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: RefereeLiveIndicator(status: RefereeConnectionStatus.connected),
        ),
      ),
    );
    await t.pump();
    expect(find.text('Referee'), findsOneWidget);
  });

  testWidgets('setup uses compact play mode and settings sheet', (t) async {
    final a = AppHarness();
    await a.pump(t);

    await t.tap(find.text('30-Second Sprint'));
    await t.pump(const Duration(milliseconds: 400));

    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Referee'), findsOneWidget);
    expect(find.text('Classic: One phone.'), findsOneWidget);

    await t.tap(find.byIcon(Icons.settings_rounded));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Rounds per team'), findsOneWidget);
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Sound effects'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
  });

  testWidgets('referee pairing and game screens initialize from AppScope', (
    t,
  ) async {
    final a = AppHarness();
    await a.pump(t);
    final nav = t.widget<AppScope>(find.byType(AppScope)).nav;

    nav.hostPairing();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(HostPairingScreen), findsOneWidget);

    nav.joinReferee();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(JoinRefereeScreen), findsOneWidget);

    nav.referee();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.byType(RefereeGameScreen), findsOneWidget);
    expect(
      find.text('Waiting for the host to synchronise the game…'),
      findsOneWidget,
    );
  });

  testWidgets('Home → setup with defaults → handover hides the card → play', (
    t,
  ) async {
    final a = AppHarness();
    await a.pump(t);
    expect(find.text('Who’s playing tonight?'), findsOneWidget);
    expect(
      find.text('No sign-up · No internet needed once loaded'),
      findsNothing,
    );
    expect(
      find.text('Card decks are candidate drafts for private playtesting.'),
      findsNothing,
    );
    await t.tap(find.text('30-Second Sprint'));
    await t.pump(const Duration(milliseconds: 400));
    await tapText(t, 'Start game');
    expect(a.h.s.teams.map((x) => x.name), ['Team A', 'Team B']);
    expect(a.h.s.config.rounds, 5);
    expect(a.h.s.phase, Phase.ready);

    // Concealment: the first card in the deck is not rendered during handover.
    final next = a.h.controller.library.sprint[a.h.s.queues['main']!.first]!;
    for (final term in next.terms) {
      expect(find.text(term.text), findsNothing);
    }
    expect(find.text('Pass the phone to your clue-giver'), findsOneWidget);
    expect(
      a.h.controller.remainingMs(),
      0,
      reason: 'clock not running during handover',
    );

    await a.startViaHandover(t);
    expect(find.text(next.terms.first.text), findsOneWidget);
    expect(a.fx.awake, isTrue, reason: 'wake lock held during play');
  });

  testWidgets(
    'Sprint: timer expiry shows Time!, posts score once, then rotates team',
    (t) async {
      final a = AppHarness();
      a.h.start(GameKind.sprint);
      await a.pump(t);
      await tapText(t, 'Resume');
      await a.startViaHandover(t);
      final card = a.h.controller.library.sprint[a.h.s.turn!.cardId]!;
      await t.tap(find.text(card.terms[2].text));
      await t.pump();
      // The 3-2-1 countdown overshoots by up to one 100 ms step; land just past the deadline.
      await a.advance(
        t,
        Duration(milliseconds: a.h.controller.remainingMs() + 100),
      );
      expect(find.text('Time!'), findsOneWidget);
      expect(a.h.s.scores, [1, 0]);
      expect(a.fx.played, contains(Cue.timeUp));
      expect(
        a.fx.awake,
        isFalse,
        reason: 'wake lock released when the turn ends',
      );
      // Late taps after expiry change nothing.
      await t.tap(find.text('See the scores'), warnIfMissed: false);
      await t.pump();
      expect(
        find.text('Time!'),
        findsOneWidget,
        reason: 'button locked briefly against late taps',
      );
      await a.advance(t, const Duration(seconds: 1));
      await tapText(t, 'See the scores');
      expect(find.text('Team A take the lead!'), findsOneWidget);
      await tapText(t, 'Next team');
      expect(find.text('TEAM B’S TURN'), findsOneWidget);
      expect(a.h.s.scores, [1, 0]);
      await t.pump(
        const Duration(seconds: 1),
      ); // let the tap guard's timer finish
    },
  );

  testWidgets(
    'a double-tap cannot skip results or start the next team\'s clock (regression)',
    (t) async {
      final a = AppHarness();
      a.h.start(GameKind.charades);
      a.h.controller.startTurn();
      await a.pump(t);
      a.h.controller.finishTurn(); // → turn results
      await t.pump(const Duration(milliseconds: 50));
      // Frantic taps where the previous screen's button was.
      await t.tap(find.text('Next team'), warnIfMissed: false);
      await t.pump(const Duration(milliseconds: 100));
      await t.tap(find.text('Next team'), warnIfMissed: false);
      expect(
        a.h.s.phase,
        Phase.turnResults,
        reason: 'results stay up long enough to be read',
      );
      await t.pump(const Duration(milliseconds: 800));
      await t.tap(find.text('Next team'));
      await t.pump(const Duration(milliseconds: 100));
      expect(a.h.s.phase, Phase.ready);
      await t.tap(
        find.text('Start the clock'),
        warnIfMissed: false,
      ); // the double-tap's second half
      await t.pump(const Duration(seconds: 3));
      expect(
        a.h.s.phase,
        Phase.ready,
        reason: 'next team\'s clock not started by a stray tap',
      );
    },
  );

  testWidgets('Discard from Home removes the Resume card (regression)', (
    t,
  ) async {
    final a = AppHarness();
    a.h.start(GameKind.charades);
    await a.pump(t);
    expect(find.text('Your game is still on'), findsOneWidget);
    await tapText(t, 'Discard');
    await tapText(t, 'Discard game');
    expect(find.text('Your game is still on'), findsNothing);
    expect(find.text('Who’s playing tonight?'), findsOneWidget);
  });

  testWidgets('Refresh mid-turn reopens the game with the same deadline', (
    t,
  ) async {
    final a = AppHarness();
    a.h.start(GameKind.forbidden);
    a.h.controller.startTurn();
    a.h.controller.mark(Outcome.correct);
    a.h.clock.advance(const Duration(seconds: 15));
    final restored = a.h.reload();
    await t.pumpWidget(
      GameNightApp(controller: restored, fx: a.fx, store: a.h.store),
    );
    await t.pump();
    expect(
      find.text('45'),
      findsOneWidget,
      reason: 'bar timer shows the true remaining time',
    );
    expect(find.textContaining('Get them to say'), findsWidgets);
  });

  testWidgets('Trivia: question → lock in → reveal with explanation', (
    t,
  ) async {
    final a = AppHarness();
    a.h.start(GameKind.trivia);
    await a.pump(t);
    await tapText(t, 'Resume');
    await a.startViaHandover(t);
    final q = a.h.controller.library.trivia[a.h.s.turn!.cardId]!;
    expect(
      find.text(q.explanation),
      findsNothing,
      reason: 'no reveal before lock-in',
    );
    await t.tap(find.text(q.answer));
    await t.pump();
    await t.tap(find.textContaining('Lock in'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('You got it!'), findsOneWidget);
    expect(find.text(q.explanation), findsOneWidget);
    expect(a.h.controller.turnScore, 1);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('Paused overlay hides the card', (t) async {
    final a = AppHarness();
    a.h.start(GameKind.charades);
    a.h.controller.startTurn();
    final prompt = a.h.controller.library.charades[a.h.s.turn!.cardId]!.prompt;
    await a.pump(t);
    expect(find.text(prompt), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Pause'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsOneWidget);
    expect(a.h.s.turn!.paused, isTrue);
  });
}
