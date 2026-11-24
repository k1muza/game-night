// Charades active acting prompt (design CH5–CH7): the prompt is the whole
// screen; two oversized pads at the bottom edge.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'rapid.dart';

class CharadesPlayScreen extends StatelessWidget {
  const CharadesPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lib = AppScope.of(context).controller.library;
    return RapidPlay(
      labelOf: (id) => lib.charades[id]!.prompt,
      cardBuilder: (context, id) => CharadesCardView(
        prompt: lib.charades[id]!.prompt,
        category: lib.charades[id]!.category,
        difficulty: lib.charades[id]!.difficulty.label,
        tilt: id.hashCode.isEven ? -1.5 : 1.2,
      ),
    );
  }
}

class CharadesCardView extends StatelessWidget {
  const CharadesCardView({super.key, required this.prompt, required this.category, required this.difficulty, this.tilt = -1.5});
  final String prompt;
  final String category;
  final String difficulty;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final h = (box.maxHeight * 0.92).clamp(220.0, 400.0);
      return Transform.rotate(
        angle: tilt * pi / 180,
        child: Semantics(
          label: 'Act out: $prompt. Category: $category',
          excludeSemantics: true,
          child: Container(
            width: double.infinity,
            height: h,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            decoration: BoxDecoration(
              color: Gn.card,
              borderRadius: BorderRadius.circular(Gn.r2xl),
              boxShadow: const [BoxShadow(color: Gn.cardLip, offset: Offset(0, 8))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const GameGlyph(GameKind.charades, size: 18, color: Gn.ink),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('$category · $difficulty',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Gn.uiStyle(13, color: Gn.onCardMuted, weight: FontWeight.w700)),
                ),
              ]),
              const Spacer(),
              FitText(
                prompt,
                maxLines: 5,
                minSize: 24,
                maxHeight: h - 90,
                style: Gn.displayStyle(46, color: Gn.ink, height: 1.04, spacing: -0.03),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
