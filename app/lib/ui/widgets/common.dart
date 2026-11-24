// Shared components from design/design-system/DS-Components.png and
// DS-Gameplay.png (GnButton, chips, score strip, timers).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import 'glyphs.dart';

/// Pressable button with the design system's solid "lip" under-shadow and
/// 3 px travel on press.
class GnButton extends StatefulWidget {
  const GnButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Gn.card,
    this.lip = Gn.cardLip,
    this.foreground = Gn.ink,
    this.icon,
    this.height = Gn.primaryButton,
    this.radius = Gn.rLg,
    this.fontSize = 20,
    this.outline = false,
    this.semanticLabel,
    this.child,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color lip;
  final Color foreground;
  final IconData? icon;
  final double height;
  final double radius;
  final double fontSize;
  final bool outline;
  final String? semanticLabel;
  final Widget? child;
  final bool expand;

  @override
  State<GnButton> createState() => _GnButtonState();
}

class _GnButtonState extends State<GnButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final lipH = widget.outline ? 0.0 : (_down ? 2.0 : 5.0);
    final bg = widget.outline ? Colors.transparent : (enabled ? widget.color : Gn.surface2);
    final fg = enabled ? widget.foreground : Gn.text3;
    final content = widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[Icon(widget.icon, color: fg, size: widget.fontSize + 2), const SizedBox(width: 8)],
            Flexible(
              child: Text(widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: widget.outline
                      ? Gn.uiStyle(widget.fontSize - 3, color: fg, weight: FontWeight.w700)
                      : Gn.displayStyle(widget.fontSize, color: fg, height: 1.1, spacing: 0)),
            ),
          ],
        );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onPressed == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onPressed!();
              },
        child: SizedBox(
          height: widget.height + 5,
          width: widget.expand ? double.infinity : null,
          child: Stack(children: [
            if (!widget.outline && enabled)
              Positioned.fill(
                top: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: widget.lip, borderRadius: BorderRadius.circular(widget.radius)),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              left: 0,
              right: 0,
              top: 5 - lipH,
              height: widget.height,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: widget.outline ? Border.all(color: Gn.border, width: 2) : null,
                ),
                child: content,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// 48 px square icon button (surface-2), e.g. pause / back / sound.
class IconSquare extends StatelessWidget {
  const IconSquare({super.key, required this.icon, required this.onTap, required this.label, this.color = Gn.surface2});
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: Gn.touchMin,
            height: Gn.touchMin,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Gn.rMd)),
            child: Icon(icon, color: Gn.text1, size: 22),
          ),
        ),
      );
}

/// Rounded pill / chip.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    this.bg = Gn.surface2,
    this.fg = Gn.text1,
    this.icon,
    this.leading,
    this.height = 30,
    this.fontSize = 13,
  });
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final Widget? leading;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          if (icon != null) ...[Icon(icon, size: fontSize + 2, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Gn.uiStyle(fontSize, color: fg, weight: FontWeight.w700)),
          ),
        ]),
      );
}

/// Game chip: soft game colour, accent text and glyph (e.g. "▤ 30-Second Sprint").
class GameChip extends StatelessWidget {
  const GameChip(this.game, {super.key});
  final GameKind game;
  @override
  Widget build(BuildContext context) {
    final pal = game.palette;
    return Pill(
      text: game.title,
      bg: pal.soft,
      fg: pal.accent,
      leading: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: pal.accent, borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: GameGlyph(game, size: 12, color: Gn.ink, cut: pal.accent),
      ),
    );
  }
}

/// Live score strip: one pill per team, the active team outlined in its colour.
class ScoreStrip extends StatelessWidget {
  const ScoreStrip({super.key, required this.teams, required this.scores, this.active});
  final List<Team> teams;
  final List<int> scores;
  final int? active;

  @override
  Widget build(BuildContext context) {
    final compact = teams.length > 3;
    return Row(children: [
      for (var i = 0; i < teams.length; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          flex: i == active && compact ? 2 : 1,
          child: Semantics(
            label: '${teams[i].name}: ${scores[i]} points${i == active ? ', playing now' : ''}',
            excludeSemantics: true,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Gn.surface1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: i == active ? teamStyles[teams[i].paletteIndex].color : Gn.surface1, width: 2),
              ),
              child: Row(children: [
                TeamMark(teams[i].paletteIndex, size: 16),
                if (!compact || i == active) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(teams[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Gn.uiStyle(13, color: Gn.text2, weight: FontWeight.w700)),
                  ),
                ] else
                  const Spacer(),
                Text('${scores[i]}', style: Gn.displayStyle(19, spacing: 0)),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }
}

/// Team badge: shape + name (+ optional subtitle).
class TeamBadge extends StatelessWidget {
  const TeamBadge(this.team, {super.key, this.subtitle, this.size = 15});
  final Team team;
  final String? subtitle;
  final double size;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            TeamMark(team.paletteIndex, size: size + 1),
            const SizedBox(width: 8),
            Flexible(
              child: Text(team.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: Gn.uiStyle(size, weight: FontWeight.w700)),
            ),
          ]),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle!, style: Gn.uiStyle(12.5, color: Gn.text3, weight: FontWeight.w600)),
            ),
        ],
      );
}

/// Circular ring timer (Sprint, Trivia). The number grows in the last 5 s so
/// urgency is never carried by colour alone.
class RingTimer extends StatelessWidget {
  const RingTimer({super.key, required this.remainingMs, required this.totalMs, required this.color, this.size = 64});
  final int remainingMs;
  final int totalMs;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final secs = (remainingMs / 1000).ceil();
    final warn = secs <= 5;
    final frac = totalMs == 0 ? 0.0 : (remainingMs / totalMs).clamp(0.0, 1.0);
    final c = warn ? Gn.warning : color;
    return Semantics(
      liveRegion: secs <= 5,
      label: '$secs seconds left',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(frac, c),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Gn.quick,
              style: Gn.displayStyle(warn ? size * 0.5 : size * 0.4, color: warn ? c : Gn.text1, spacing: 0),
              child: Text('$secs'),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.frac, this.color);
  final double frac;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width * 0.1;
    final rect = (Offset.zero & size).deflate(sw / 2);
    canvas.drawArc(rect, 0, 2 * pi, false,
        Paint()
          ..color = Gn.surface2
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);
    canvas.drawArc(rect, -pi / 2, 2 * pi * frac, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = sw);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.frac != frac || o.color != color;
}

/// Bar timer (Charades, Forbidden Words): the card stays dominant.
class BarTimer extends StatelessWidget {
  const BarTimer({super.key, required this.remainingMs, required this.totalMs, required this.color});
  final int remainingMs;
  final int totalMs;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final secs = (remainingMs / 1000).ceil();
    final warn = secs <= 5;
    final frac = totalMs == 0 ? 0.0 : (remainingMs / totalMs).clamp(0.0, 1.0);
    final c = warn ? Gn.warning : color;
    return Semantics(
      liveRegion: secs <= 5,
      label: '$secs seconds left',
      excludeSemantics: true,
      child: Row(children: [
        Expanded(
          child: Container(
            height: 14,
            decoration: BoxDecoration(color: Gn.surface2, borderRadius: BorderRadius.circular(999)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: max(frac, 0.04),
              child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999))),
            ),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text('$secs',
              textAlign: TextAlign.right,
              style: Gn.displayStyle(warn ? 36 : 30, color: warn ? c : Gn.text1, spacing: 0)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ),
      ]),
    );
  }
}

/// Text that shrinks (down to [minSize]) until it fits [maxLines] in the
/// available width — for long terms, prompts and questions.
class FitText extends StatelessWidget {
  const FitText(this.text, {super.key, required this.style, this.maxLines = 2, this.minSize = 14, this.align = TextAlign.left, this.maxHeight});
  final String text;
  final TextStyle style;
  final int maxLines;
  final double minSize;
  final TextAlign align;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final scaler = MediaQuery.textScalerOf(context);
      var size = style.fontSize!;
      final limitH = maxHeight ?? (c.maxHeight.isFinite ? c.maxHeight : double.infinity);
      while (size > minSize) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: style.copyWith(fontSize: size, letterSpacing: (style.letterSpacing ?? 0) * size / style.fontSize!)),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout(maxWidth: c.maxWidth);
        final fits = !tp.didExceedMaxLines && tp.height <= limitH && !_breaksWord(tp, c.maxWidth);
        tp.dispose();
        if (fits) break;
        size -= 1;
      }
      return Text(text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: style.copyWith(fontSize: size, letterSpacing: (style.letterSpacing ?? 0) * size / style.fontSize!));
    });
  }

  /// True when a single word is wider than the line (it would be split mid-word).
  bool _breaksWord(TextPainter tp, double maxWidth) {
    for (final w in text.split(RegExp(r'\s+'))) {
      final wp = TextPainter(
          text: TextSpan(text: w, style: tp.text!.style), textDirection: TextDirection.ltr, textScaler: tp.textScaler)
        ..layout();
      final wide = wp.width > maxWidth;
      wp.dispose();
      if (wide) return true;
    }
    return false;
  }
}

/// Lower-case wordmark with the spark as the dot of the i.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 30, this.color = Gn.text1});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Gn.displayStyle(size, color: color, spacing: -0.045, height: 1.1);
    // Measure where the dotless ı sits so the spark can replace its dot.
    final before = TextPainter(text: TextSpan(text: 'game n', style: style), textDirection: TextDirection.ltr)..layout();
    final iW = (TextPainter(text: TextSpan(text: 'ı', style: style), textDirection: TextDirection.ltr)..layout()).width;
    return Semantics(
      label: 'game night',
      excludeSemantics: true,
      child: Stack(clipBehavior: Clip.none, children: [
        Text('game nıght', style: style),
        Positioned(
          left: before.width + iW / 2 - size * 0.17,
          top: size * 0.02,
          child: Spark(size: size * 0.34),
        ),
      ]),
    );
  }
}

/// Section label ("STANDINGS", "TEAMS").
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = Gn.text3});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: Gn.eyebrow(color));
}

/// Ignores taps for [duration] after it first appears. Primary buttons sit in
/// the same place screen after screen, so without this a frantic double-tap
/// would skip a reveal or start the next team's clock before the phone has
/// changed hands. Give it a new key to re-arm it.
class InputGuard extends StatefulWidget {
  const InputGuard({super.key, required this.child, this.duration = const Duration(milliseconds: 700)});
  final Widget child;
  final Duration duration;

  @override
  State<InputGuard> createState() => _InputGuardState();
}

class _InputGuardState extends State<InputGuard> {
  bool _armed = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _armed = false);
    });
  }

  @override
  Widget build(BuildContext context) => AbsorbPointer(absorbing: _armed, child: widget.child);
}

/// Max-width, safe-area page frame with the design's 20 px side gutter.
class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child, this.background, this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16)});
  final Widget child;
  final Color? background;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Gn.base,
      color: background ?? Gn.table,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
