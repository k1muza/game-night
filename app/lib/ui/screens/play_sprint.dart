// 30-Second Sprint active clue-giver (design SP2, L04): the five term rows
// are the controls — one forgiving tap per term, tap again to undo.
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/cards.dart';
import '../../model/game_kind.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import 'sheets.dart';

class SprintPlayScreen extends StatelessWidget {
  const SprintPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    return TurnClock(builder: (context, rem, total) {
      final s = c.session!;
      final t = s.turn!;
      final card = c.library.sprint[t.cardId]!;
      final warn = rem <= 5000 && !t.paused;
      final pal = GameKind.sprint.palette;
      return Stack(children: [
        PageFrame(
          background: warn ? Gn.warmTable : Gn.table,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const PauseButton(),
              const SizedBox(width: 12),
              Expanded(child: TeamBadge(s.activeTeam, subtitle: 'Clue-giver is describing')),
              RingTimer(remainingMs: rem, totalMs: total, color: pal.accent, size: 66),
            ]),
            const SizedBox(height: 14),
            Expanded(
              child: LayoutBuilder(builder: (context, box) {
                const gap = 10.0;
                final rowH = ((box.maxHeight - 4 * gap) / 5).clamp(52.0, 84.0);
                return Column(children: [
                  for (var i = 0; i < 5; i++) ...[
                    if (i > 0) const SizedBox(height: gap),
                    SizedBox(
                      height: rowH,
                      child: _TermRow(
                        term: card.terms[i],
                        marked: t.marked.contains(i),
                        onTap: () => c.toggleTerm(i),
                      ),
                    ),
                  ],
                ]);
              }),
            ),
            const SizedBox(height: 14),
            _Progress(got: t.marked.length, warn: warn),
            const SizedBox(height: 8),
            // Skip sits below the progress strip, away from the term rows, and
            // disappears once used or once a term is ticked.
            SizedBox(
              height: 44,
              child: c.canSkipSprintCard
                  ? GnButton(
                      label: 'Skip this card (once per turn)',
                      semanticLabel: 'Skip this card for a new one. Once per turn.',
                      icon: Icons.keyboard_double_arrow_right_rounded,
                      outline: true,
                      foreground: Gn.text2,
                      height: 39,
                      fontSize: 17,
                      onPressed: c.skipSprintCard,
                    )
                  : Center(
                      child: Text(
                        warn ? 'Last 5 seconds!' : 'Tap a term when your team says it · tap again to undo',
                        textAlign: TextAlign.center,
                        style: Gn.uiStyle(13, color: warn ? Gn.warning : Gn.text3, weight: FontWeight.w700),
                      ),
                    ),
            ),
          ]),
        ),
        if (t.paused) const PausedOverlay(),
      ]);
    });
  }
}

class _TermRow extends StatefulWidget {
  const _TermRow({required this.term, required this.marked, required this.onTap});
  final SprintTerm term;
  final bool marked;
  final VoidCallback onTap;

  @override
  State<_TermRow> createState() => _TermRowState();
}

class _TermRowState extends State<_TermRow> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.marked;
    final pal = GameKind.sprint.palette;
    final bg = m ? pal.accent : (_down ? Gn.cardPressed : Gn.card);
    final lip = m ? pal.deep : Gn.cardLip;
    final term = widget.term;
    return Semantics(
      button: true,
      toggled: m,
      label: '${term.text}${term.context != null ? ' (${term.context})' : ''}',
      hint: m ? 'Guessed. Tap to undo' : 'Tap when guessed',
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          margin: EdgeInsets.only(top: _down ? 2 : 0, bottom: _down ? 0 : 2),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: lip, offset: Offset(0, _down ? 2 : 4))],
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: Gn.quick,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: m ? Gn.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Gn.ink, width: 3),
              ),
              child: m ? Icon(Icons.check_rounded, color: pal.accent, size: 22) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Flexible(
                  child: FitText(
                    term.text,
                    maxLines: 2,
                    minSize: 15,
                    style: Gn.displayStyle(25, color: Gn.ink, height: 1.05).copyWith(
                      decoration: m ? TextDecoration.lineThrough : null,
                      decorationThickness: 3,
                      decorationColor: Gn.ink,
                    ),
                  ),
                ),
                if (term.context != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.info_outline_rounded, size: 13, color: Gn.ink.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(term.context!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Gn.uiStyle(12, color: Gn.onCardMuted, weight: FontWeight.w700)),
                      ),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.got, required this.warn});
  final int got;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final pal = GameKind.sprint.palette;
    return Semantics(
      label: '$got of 5 guessed',
      excludeSemantics: true,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Gn.surface1, borderRadius: BorderRadius.circular(Gn.rMd)),
        child: Row(children: [
          for (var i = 0; i < 5; i++)
            AnimatedContainer(
              duration: Gn.quick,
              margin: const EdgeInsets.only(right: 6),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: i < got ? pal.accent : Gn.surface2,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          const Spacer(),
          Text('$got', style: Gn.displayStyle(28, spacing: 0)),
          Text(' / 5', style: Gn.uiStyle(16, color: Gn.text3, weight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
