// Victory moment + final standings (design L10, L11 and the per-game winner
// variants). The winner card takes the game's accent.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'turn_results.dart';

class FinalResultsScreen extends StatefulWidget {
  const FinalResultsScreen({super.key});
  @override
  State<FinalResultsScreen> createState() => _FinalResultsScreenState();
}

class _FinalResultsScreenState extends State<FinalResultsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _confetti =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.of(context).disableAnimations && !_confetti.isAnimating && _confetti.value == 0) {
      _confetti.forward();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = scope.controller;
    final s = c.session!;
    final winners = c.winners;
    final pal = s.game.palette;
    final tie = winners.length > 1;
    final st = c.standings;
    final margin = st.length > 1 ? st[0].score - st.firstWhere((x) => x.score < st[0].score, orElse: () => st[0]).score : 0;
    final title = tie ? 'It’s a tie!' : '${s.teams[winners.first].name} win!';
    final sub = tie
        ? '${winners.map((i) => s.teams[i].name).join(' & ')} share the win on ${st[0].score}.'
        : 'By $margin point${margin == 1 ? '' : 's'} — ${s.game.title}, ${s.config.rounds} round${s.config.rounds == 1 ? '' : 's'}.';

    return Stack(children: [
      PageFrame(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.only(top: 12), children: [
              Center(child: Spark(size: 30, color: pal.accent)),
              const SizedBox(height: 10),
              Text('GAME NIGHT CHAMPIONS', textAlign: TextAlign.center, style: Gn.eyebrow(Gn.spark)),
              const SizedBox(height: 18),
              Center(
                child: Transform.rotate(
                  angle: -4 * pi / 180,
                  child: Container(
                    width: 168,
                    height: 206,
                    decoration: BoxDecoration(
                      color: Gn.card,
                      borderRadius: BorderRadius.circular(Gn.r2xl),
                      border: Border(top: BorderSide(color: pal.accent, width: 8)),
                      boxShadow: const [BoxShadow(color: Gn.cardLip, offset: Offset(0, 9))],
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Wrap(spacing: 6, children: [
                        for (final w in winners.take(3)) TeamMark(s.teams[w].paletteIndex, size: tie ? 52 : 84, stroke: Gn.ink),
                      ]),
                      const SizedBox(height: 10),
                      Text('${st[0].score}', style: Gn.displayStyle(48, color: Gn.ink, spacing: 0)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                liveRegion: true,
                child: Text(title, textAlign: TextAlign.center, style: Gn.displayStyle(38)),
              ),
              const SizedBox(height: 6),
              Text(sub, textAlign: TextAlign.center, style: Gn.uiStyle(15, color: Gn.text2, weight: FontWeight.w500)),
              if (s.endedEarly) ...[
                const SizedBox(height: 10),
                Text(
                    c.unequalTurns
                        ? 'Game ended early — not every team had the same number of turns.'
                        : 'Game ended early, after ${s.history.length ~/ s.teams.length} of ${s.config.rounds} rounds.',
                    textAlign: TextAlign.center, style: Gn.uiStyle(13, color: Gn.warning, weight: FontWeight.w600)),
              ],
              const SizedBox(height: 22),
              const Eyebrow('Final standings'),
              const SizedBox(height: 10),
              for (final x in st) ...[
                StandingRow(standing: x, team: s.teams[x.team], leader: x.rank == 1),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
            ]),
          ),
          const SizedBox(height: 8),
          GnButton(label: 'Rematch', icon: Icons.refresh_rounded, onPressed: c.rematch),
          const SizedBox(height: 10),
          GnButton(
            label: 'Choose another game',
            outline: true,
            foreground: Gn.text1,
            height: 54,
            onPressed: () {
              c.discard();
              scope.nav.home();
            },
          ),
        ]),
      ),
      IgnorePointer(
        child: AnimatedBuilder(
          animation: _confetti,
          builder: (context, _) => _confetti.value == 0 || _confetti.value == 1
              ? const SizedBox.shrink()
              : CustomPaint(painter: _ConfettiPainter(_confetti.value), size: Size.infinite),
        ),
      ),
    ]);
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;
  static final _pieces = List.generate(70, (i) {
    final r = Random(i * 7919);
    return (r.nextDouble(), r.nextDouble() * 0.35, r.nextDouble() * 2 - 1, r.nextInt(4), r.nextDouble() * 6);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [for (final g in GameKind.values) g.palette.accent];
    for (final (x, delay, drift, ci, spin) in _pieces) {
      final p = ((t - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final pos = Offset(size.width * x + drift * 60 * p, -20 + (size.height + 40) * Curves.easeIn.transform(p));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(spin * p * 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -8, 8, 16), const Radius.circular(4)),
        Paint()..color = colors[ci].withValues(alpha: 1 - p * 0.3),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.t != t;
}
