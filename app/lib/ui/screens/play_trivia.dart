// Trivia Challenge (design TR3–TR8): question, four shape-lettered answers,
// select → lock in, then a reveal that teaches. Answers are never shown
// before lock-in or timeout.
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'sheets.dart';

const _letters = ['A', 'B', 'C', 'D'];
const _shapes = [TeamShape.triangle, TeamShape.diamond, TeamShape.circle, TeamShape.square];

enum TileState { idle, selected, correct, yourWrongPick, other }

class TriviaPlayScreen extends StatelessWidget {
  const TriviaPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    return TurnClock(builder: (context, rem, total) {
      final s = c.session!;
      final t = s.turn!;
      final q = c.library.trivia[t.cardId]!;
      final pal = GameKind.trivia.palette;
      final revealed = t.revealed;
      final ev = revealed ? t.events.last : null;
      final options = q.options;
      final isLast = t.qIndex + 1 >= t.slots.length;

      TileState stateOf(int display) {
        final opt = t.optionOrder[display];
        if (!revealed) return t.selected == display ? TileState.selected : TileState.idle;
        if (opt == 0) return TileState.correct;
        if (ev!.choice == opt) return TileState.yourWrongPick;
        return TileState.other;
      }

      return Stack(children: [
        PageFrame(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 64,
              child: Row(children: [
                if (revealed)
                  IconSquare(icon: Icons.menu_rounded, label: 'Game menu', onTap: () => showGameMenu(context))
                else
                  const PauseButton(),
                const SizedBox(width: 10),
                Pill(text: 'Q ${t.qIndex + 1} / ${t.slots.length}', height: 32),
                const SizedBox(width: 6),
                Flexible(child: Pill(text: q.difficulty.label, bg: pal.soft, fg: pal.accent, height: 32)),
                const Spacer(),
                if (!revealed)
                  RingTimer(remainingMs: rem, totalMs: total, color: pal.accent, size: 60)
                else
                  Pill(
                    text: ev!.outcome == Outcome.correct ? '+1' : '+0',
                    bg: ev.outcome == Outcome.correct ? Gn.correct : Gn.surface2,
                    fg: ev.outcome == Outcome.correct ? Gn.ink : Gn.text2,
                    height: 36,
                    fontSize: 16,
                  ),
              ]),
            ),
            const SizedBox(height: 6),
            Row(children: [
              TeamBadge(s.activeTeam, size: 14),
              const SizedBox(width: 8),
              Semantics(
                label: '${c.turnScore} correct this turn',
                excludeSemantics: true,
                child: Pill(text: '${c.turnScore}', icon: Icons.check_rounded, fg: Gn.correct, height: 26),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Gn.uiStyle(12.5, color: pal.accent, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (revealed) ...[
                    _RevealTitle(outcome: ev!.outcome),
                    const SizedBox(height: 6),
                    Text(q.question, style: Gn.displayStyle(19, color: Gn.text2, height: 1.15, spacing: -0.01)),
                  ] else
                    Semantics(
                      header: true,
                      child: Text(
                        q.question,
                        style: Gn.displayStyle(q.question.length > 120 ? 22 : (q.question.length > 70 ? 25 : 29),
                            height: 1.1),
                      ),
                    ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < 4; i++) ...[
                    _AnswerTile(
                      letter: _letters[i],
                      shape: _shapes[i],
                      text: options[t.optionOrder[i]],
                      state: stateOf(i),
                      // After the reveal only the answer (and a wrong pick) stay full
                      // size, so the explanation fits without scrolling on small phones.
                      compact: revealed && stateOf(i) == TileState.other,
                      onTap: revealed ? null : () => c.selectOption(i),
                    ),
                    SizedBox(height: revealed ? 8 : 10),
                  ],
                  if (revealed) _Explanation(text: q.explanation, outcome: ev!.outcome, answer: q.answer),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            if (!revealed) ...[
              GnButton(
                label: t.selected == null ? 'Lock in' : 'Lock in  ${options[t.optionOrder[t.selected!]]}',
                semanticLabel: t.selected == null ? 'Lock in' : 'Lock in ${options[t.optionOrder[t.selected!]]}',
                icon: Icons.lock_rounded,
                color: pal.accent,
                lip: pal.deep,
                fontSize: 19,
                onPressed: t.selected == null ? null : c.lockAnswer,
                // Design TR4: "Lock in ◆ Zambezi" — the shape the team can shout.
                child: t.selected == null
                    ? null
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.lock_rounded, color: Gn.ink, size: 21),
                        const SizedBox(width: 8),
                        Text('Lock in', style: Gn.displayStyle(19, color: Gn.ink, spacing: 0)),
                        const SizedBox(width: 10),
                        ShapeIcon(_shapes[t.selected!], color: Gn.ink, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(options[t.optionOrder[t.selected!]],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Gn.displayStyle(19, color: Gn.ink, spacing: 0)),
                        ),
                      ]),
              ),
              SizedBox(
                height: 26,
                child: Center(
                  child: Text(
                    t.selected == null ? 'Pick an answer first' : 'Tap another answer to change',
                    style: Gn.uiStyle(13, color: Gn.text3),
                  ),
                ),
              ),
            ] else ...[
              // Re-armed per question: a late Lock in tap can't skip the reveal.
              InputGuard(
                key: ValueKey('reveal-${t.qIndex}'),
                duration: const Duration(milliseconds: 900),
                child: GnButton(
                  label: isLast ? 'See turn results' : 'Next question',
                  icon: Icons.chevron_right_rounded,
                  onPressed: c.nextQuestion,
                ),
              ),
              const SizedBox(height: 26),
            ],
          ]),
        ),
        if (t.paused) const PausedOverlay(),
      ]);
    });
  }
}

class _RevealTitle extends StatelessWidget {
  const _RevealTitle({required this.outcome});
  final Outcome outcome;
  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (outcome) {
      Outcome.correct => ('You got it!', Gn.correct),
      Outcome.wrong => ('So close!', Gn.text1),
      _ => ('Time’s up!', Gn.warning),
    };
    return Semantics(
      liveRegion: true,
      child: Row(children: [
        if (outcome == Outcome.correct) ...[const Spark(size: 24, color: Gn.correct), const SizedBox(width: 8)],
        if (outcome == Outcome.timeout) ...[const Icon(Icons.timer_off_rounded, color: Gn.warning, size: 26), const SizedBox(width: 8)],
        Text(text, style: Gn.displayStyle(32, color: color)),
      ]),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.letter, required this.shape, required this.text, required this.state, this.onTap, this.compact = false});
  final bool compact;
  final String letter;
  final TeamShape shape;
  final String text;
  final TileState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pal = GameKind.trivia.palette;
    final (bg, border, fg, chipShape) = switch (state) {
      TileState.idle => (Gn.surface1, Gn.border, Gn.text1, Gn.text1),
      TileState.selected => (Gn.card, Gn.card, Gn.ink, Gn.text1),
      TileState.correct => (Gn.correct, Gn.correct, Gn.ink, Gn.correct),
      TileState.yourWrongPick => (Gn.surface1, Gn.violation, Gn.text1, Gn.text1),
      TileState.other => (Gn.surface1, Gn.surface2, Gn.text3, Gn.text3),
    };
    final tag = switch (state) {
      TileState.selected => const _Tag('Selected', Gn.ink, Gn.card, null),
      TileState.correct => const _Tag('Answer', Gn.card, Gn.ink, Icons.check_rounded),
      TileState.yourWrongPick => const _Tag('Your pick', Gn.ink, Gn.violation, Icons.close_rounded),
      _ => null,
    };
    final label = '$letter: $text${switch (state) {
      TileState.selected => ', selected',
      TileState.correct => ', correct answer',
      TileState.yourWrongPick => ', your pick, wrong',
      _ => '',
    }}';
    return Semantics(
      button: onTap != null,
      selected: state == TileState.selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Gn.quick,
          constraints: BoxConstraints(minHeight: compact ? 48 : 72),
          padding: EdgeInsets.fromLTRB(12, compact ? 6 : 10, 12, compact ? 6 : 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 3),
          ),
          child: Row(children: [
            Container(
              width: compact ? 30 : 46,
              height: compact ? 30 : 46,
              decoration: BoxDecoration(
                color: state == TileState.idle || state == TileState.other || state == TileState.yourWrongPick
                    ? Gn.surface2
                    : Gn.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: ShapeIcon(shape, color: state == TileState.selected ? pal.accent : chipShape, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                if (!compact) Text(letter, style: Gn.uiStyle(11.5, color: fg.withValues(alpha: 0.75), weight: FontWeight.w800)),
                Text(
                  text,
                  style: Gn.displayStyle(compact ? 16 : (text.length > 40 ? 17 : (text.length > 22 ? 19 : 22)), color: fg, height: 1.1, spacing: -0.01)
                      .copyWith(
                    decoration: state == TileState.yourWrongPick ? TextDecoration.lineThrough : null,
                    decorationThickness: 2.5,
                    decorationColor: Gn.violation,
                  ),
                ),
              ]),
            ),
            if (tag != null) ...[const SizedBox(width: 8), tag],
          ]),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.fg, this.bg, this.icon);
  final String text;
  final Color fg, bg;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Pill(text: text, fg: fg, bg: bg, icon: icon, height: 28, fontSize: 12);
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.text, required this.outcome, required this.answer});
  final String text;
  final Outcome outcome;
  final String answer;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Gn.card, borderRadius: BorderRadius.circular(Gn.rLg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DID YOU KNOW?', style: Gn.eyebrow(GameKind.trivia.palette.deep).copyWith(fontSize: 11.5)),
          const SizedBox(height: 6),
          Text(text, style: Gn.uiStyle(15.5, color: Gn.ink, weight: FontWeight.w600, height: 1.4)),
        ]),
      );
}
