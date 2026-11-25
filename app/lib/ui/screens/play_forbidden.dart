// Forbidden Words, single-phone "over the shoulder" layout (design FW5,
// FW10): the opposing referee reaches the BUZZ strip at the top; the
// clue-giver's thumb has Pass / Got it at the bottom.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'rapid.dart';

class ForbiddenPlayScreen extends StatelessWidget {
  const ForbiddenPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    final refereeConnected = AppScope.of(context).referee.isHostConnected;
    final lib = c.library;
    return RapidPlay(
      buzzCount: true,
      labelOf: (id) => lib.forbidden[id]!.target,
      top: _BuzzStrip(
        remote: refereeConnected,
        onBuzz: refereeConnected || c.session!.turn!.cardId == null
            ? null
            : () => c.mark(Outcome.violation),
      ),
      cardBuilder: (context, id) => ForbiddenCardView(
        target: lib.forbidden[id]!.target,
        clues: lib.forbidden[id]!.clues,
        tilt: id.hashCode.isEven ? -1.0 : 0.8,
      ),
    );
  }
}

class _BuzzStrip extends StatefulWidget {
  const _BuzzStrip({required this.onBuzz, this.remote = false});
  final VoidCallback? onBuzz;
  final bool remote;
  @override
  State<_BuzzStrip> createState() => _BuzzStripState();
}

class _BuzzStripState extends State<_BuzzStrip> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.onBuzz != null,
    label: widget.remote
        ? 'Referee connected and monitoring'
        : 'Buzz: forbidden word said, minus one point',
    excludeSemantics: true,
    onTap: widget.onBuzz,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onBuzz == null
          ? null
          : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onBuzz,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        height: 58,
        margin: EdgeInsets.only(top: _down ? 3 : 0, bottom: _down ? 0 : 3),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Gn.violation,
          borderRadius: BorderRadius.circular(Gn.rLg),
          boxShadow: [
            BoxShadow(
              color: Gn.violationDeep,
              offset: Offset(0, _down ? 1 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Gn.ink, size: 26),
            const SizedBox(width: 10),
            Text(
              widget.remote ? 'REFEREE CONNECTED' : 'BUZZ',
              style: Gn.displayStyle(
                widget.remote ? 16 : 24,
                color: Gn.ink,
                spacing: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.remote
                    ? 'Remote referee is monitoring'
                    : 'Local referee: forbidden word said · −1',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Gn.uiStyle(
                  12.5,
                  color: Gn.ink,
                  weight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ForbiddenCardView extends StatelessWidget {
  const ForbiddenCardView({
    super.key,
    required this.target,
    required this.clues,
    this.tilt = -1,
  });
  final String target;
  final List<String> clues;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final pal = GameKind.forbidden.palette;
    return LayoutBuilder(
      builder: (context, box) {
        final roomy = box.maxHeight > 420;
        final rowH = roomy ? 40.0 : 33.0;
        // Last-resort guard for very short screens: scale the whole card rather
        // than clip or reflow it.
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: box.maxWidth, child: _card(rowH, roomy, pal)),
        );
      },
    );
  }

  Widget _card(double rowH, bool roomy, GamePalette pal) {
    return Transform.rotate(
      angle: tilt * pi / 180,
      child: Semantics(
        label: 'Get them to say: $target. Don’t say: ${clues.join(', ')}',
        excludeSemantics: true,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Gn.card,
            borderRadius: BorderRadius.circular(Gn.r2xl),
            boxShadow: const [
              BoxShadow(color: Gn.cardLip, offset: Offset(0, 8)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: pal.accent,
                padding: EdgeInsets.fromLTRB(
                  22,
                  roomy ? 16 : 12,
                  22,
                  roomy ? 16 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GameGlyph(
                          GameKind.forbidden,
                          size: 16,
                          color: Gn.ink,
                          cut: pal.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Get them to say',
                          style: Gn.uiStyle(
                            13,
                            color: Gn.ink,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    FitText(
                      target,
                      maxLines: 2,
                      minSize: 26,
                      style: Gn.displayStyle(
                        roomy ? 52 : 42,
                        color: Gn.ink,
                        height: 1.0,
                        spacing: -0.03,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  roomy ? 12 : 8,
                  16,
                  roomy ? 16 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'DON’T SAY',
                        style: Gn.eyebrow(
                          pal.deep,
                        ).copyWith(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    for (final clue in clues) ...[
                      Container(
                        height: rowH,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Gn.cardRow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close_rounded,
                              color: pal.deep,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FitText(
                                clue,
                                maxLines: 1,
                                minSize: 12,
                                style: Gn.uiStyle(
                                  18,
                                  color: Gn.ink,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
