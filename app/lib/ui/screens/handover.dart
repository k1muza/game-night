// Turn handover (design L01) + 3-2-1 countdown (L03). No card data is built
// on this screen: hidden information can't leak while the phone changes hands.
import 'dart:math';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../services/fx.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'sheets.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});
  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  int? _count;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _begin() {
    final scope = AppScope.of(context);
    scope.fx.unlock();
    restoreFullscreen(scope);
    scope.fx.play(Cue.tick);
    setState(() => _count = 3);
    _timer = Timer.periodic(const Duration(milliseconds: 650), (t) {
      if (!mounted) return t.cancel();
      if (_count! > 1) {
        setState(() => _count = _count! - 1);
        scope.fx.play(Cue.tick);
      } else {
        t.cancel();
        scope.fx.play(Cue.start);
        scope.controller.startTurn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = scope.controller;
    final s = c.session!;
    if (_count != null) return _Countdown(game: s.game, count: _count!);

    final team = s.activeTeam;
    final st = teamStyles[team.paletteIndex];
    final pal = s.game.palette;
    final (title, body) = handoverCopy(s);
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                IconSquare(
                  icon: Icons.menu_rounded,
                  label: 'Game menu',
                  onTap: () => showGameMenu(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GameChip(s.game),
                  ),
                ),
                Text(
                  'Round ${s.round} of ${s.config.rounds}',
                  style: Gn.uiStyle(
                    13,
                    color: Gn.text3,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final compact = box.maxHeight < 420;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!compact) ...[
                          Transform.rotate(
                            angle: -5 * pi / 180,
                            child: Container(
                              width: 124,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Gn.card,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Gn.cardLip,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: ShapeIcon(
                                st.shape,
                                color: st.color,
                                size: 68,
                                stroke: Gn.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                        Text(
                          teamTurnLabel(team),
                          textAlign: TextAlign.center,
                          style: Gn.eyebrow(st.color),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Gn.displayStyle(compact ? 28 : 34),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: Gn.uiStyle(
                            16,
                            color: Gn.text2,
                            weight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        if (s.game.hiddenCard) ...[
                          const SizedBox(height: 14),
                          Pill(
                            text: 'Card stays hidden until you start',
                            icon: Icons.visibility_off_rounded,
                            fg: Gn.text2,
                            height: 34,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ScoreStrip(teams: s.teams, scores: s.scores, active: s.teamIndex),
          const SizedBox(height: 12),
          if (c.canStartTurn)
            GnButton(
              label: s.game == GameKind.trivia
                  ? 'Start the questions'
                  : 'Start the clock',
              icon: Icons.play_arrow_rounded,
              color: pal.accent,
              lip: pal.deep,
              onPressed: _begin,
            )
          else if (s.config.mode == PlayMode.referee &&
              !scope.referee.isHostConnected)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Reconnect the referee or continue in Classic Mode to start the turn.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Gn.text2),
              ),
            )
          else
            _DeckEmpty(onReshuffle: c.reshuffle),
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                s.game.hiddenCard
                    ? 'Everyone else: eyes off the screen'
                    : 'Same difficulty mix for every team',
                style: Gn.uiStyle(13, color: Gn.text3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

(String, String) handoverCopy(Session s) {
  final team = s.activeTeam.name;
  final secs = s.config.effectiveSeconds;
  return switch (s.game) {
    GameKind.sprint => (
      'Pass the phone to your clue-giver',
      '$team guess. Five terms, $secs seconds. Everyone else: listen for slips.',
    ),
    GameKind.charades => (
      'Pass the phone to your actor',
      '$team guess. No talking, no sounds — act out as many prompts as you can in $secs seconds.',
    ),
    GameKind.forbidden => (
      'Pass the phone to your clue-giver',
      '$team guess. One player from another team watches over the shoulder and taps BUZZ for a forbidden word.',
    ),
    GameKind.trivia => (
      'Huddle up, $team',
      '${s.config.questionsPerTurn} questions, $secs seconds each. Talk it out, then lock in one answer.',
    ),
  };
}

class _DeckEmpty extends StatelessWidget {
  const _DeckEmpty({required this.onReshuffle});
  final VoidCallback onReshuffle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'That deck is empty',
        textAlign: TextAlign.center,
        style: Gn.displayStyle(22, spacing: 0),
      ),
      const SizedBox(height: 4),
      Text(
        'Every card has been played this game. Reshuffle to reuse cards, or end the game.',
        textAlign: TextAlign.center,
        style: Gn.uiStyle(14, color: Gn.text2, weight: FontWeight.w500),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: GnButton(
              label: 'End game',
              outline: true,
              foreground: Gn.text1,
              height: 54,
              onPressed: AppScope.of(context).controller.endGame,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GnButton(
              label: 'Reshuffle',
              icon: Icons.refresh_rounded,
              height: 54,
              fontSize: 18,
              onPressed: onReshuffle,
            ),
          ),
        ],
      ),
    ],
  );
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.game, required this.count});
  final GameKind game;
  final int count;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final pal = game.palette;
    return PageFrame(
      background: pal.soft,
      child: Semantics(
        liveRegion: true,
        label: 'Starting in $count',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: reduce ? Duration.zero : Gn.spring,
              switchInCurve: Gn.springCurve,
              transitionBuilder: (child, a) => ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0).animate(a),
                child: child,
              ),
              child: Transform.rotate(
                key: ValueKey(count),
                angle: (count.isEven ? 4 : -4) * pi / 180,
                child: Container(
                  width: 200,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Gn.card,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: const [
                      BoxShadow(color: Gn.cardLip, offset: Offset(0, 8)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: Gn.displayStyle(150, color: Gn.ink, height: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text('Get ready…', style: Gn.displayStyle(28, color: pal.accent)),
          ],
        ),
      ),
    );
  }
}
