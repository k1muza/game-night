// Shared rapid-fire layout for Charades and Forbidden Words: bar timer, the
// game's own card, feedback banner with undo, and oversized thumb pads.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import 'sheets.dart';

class RapidPlay extends StatefulWidget {
  const RapidPlay({
    super.key,
    required this.cardBuilder,
    required this.labelOf,
    this.buzzCount = false,
  });

  /// Builds the game's card for a card ID.
  final Widget Function(BuildContext context, String cardId) cardBuilder;
  final String Function(String cardId) labelOf;

  /// Show the Tabuu violation total in Referee Mode only.
  final bool buzzCount;

  @override
  State<RapidPlay> createState() => _RapidPlayState();
}

class _RapidPlayState extends State<RapidPlay> {
  int _seenEvents = 0;
  DateTime? _bannerAt;
  Outcome _lastOutcome = Outcome.correct;

  @override
  void initState() {
    super.initState();
    _seenEvents = context
        .getInheritedWidgetOfExactType<AppScope>()!
        .controller
        .session!
        .turn!
        .events
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    final scope = AppScope.of(context);
    return TurnClock(
      builder: (context, rem, total) {
        final s = c.session!;
        final t = s.turn!;
        final pal = s.game.palette;
        if (t.events.length != _seenEvents) {
          if (t.events.length > _seenEvents) {
            _bannerAt = DateTime.now();
            _lastOutcome = t.events.last.outcome;
          } else {
            _bannerAt = null;
          }
          _seenEvents = t.events.length;
        }
        final showBanner =
            _bannerAt != null &&
            DateTime.now().difference(_bannerAt!) <
                const Duration(seconds: 4) &&
            t.events.isNotEmpty;
        final warn = rem <= 5000 && !t.paused;
        final reduce = MediaQuery.of(context).disableAnimations;
        final tall = MediaQuery.of(context).size.height >= 720;
        final canHostScore =
            s.phase == Phase.playing &&
            t.cardId != null &&
            !t.paused &&
            t.deadlineMs != null &&
            c.remainingMs() > 0 &&
            (s.config.mode != PlayMode.referee ||
                scope.referee.isHostConnected);

        return Stack(
          children: [
            PageFrame(
              background: warn ? Gn.warmTable : Gn.table,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const PauseButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BarTimer(
                          remainingMs: rem,
                          totalMs: total,
                          color: pal.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TeamBadge(s.activeTeam)),
                      if (s.config.mode == PlayMode.referee) ...[
                        const SizedBox(width: 6),
                        RefereeLiveIndicator(status: scope.referee.status),
                        const SizedBox(width: 6),
                      ],
                      Pill(
                        text: '${t.count(Outcome.correct)} got',
                        icon: Icons.check_rounded,
                        fg: Gn.correct,
                        height: 28,
                      ),
                      if (widget.buzzCount &&
                          s.config.mode == PlayMode.referee) ...[
                        const SizedBox(width: 6),
                        Semantics(
                          label: '${t.count(Outcome.violation)} buzzed',
                          child: ExcludeSemantics(
                            child: Pill(
                              text: '${t.count(Outcome.violation)}',
                              icon: Icons.warning_amber_rounded,
                              fg: Gn.violation,
                              height: 28,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Pill(
                        text: '${t.count(Outcome.pass)}',
                        icon: Icons.keyboard_double_arrow_right_rounded,
                        fg: Gn.text2,
                        height: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Feedback + Undo above the card (design FW7), well away from the
                  // thumb on Got it, so an undo can't happen by accident.
                  SizedBox(
                    height: 42,
                    child: AnimatedSwitcher(
                      duration: Gn.quick,
                      child: showBanner
                          ? _Banner(
                              key: ValueKey(t.events.length),
                              event: t.events.last,
                              label: widget.labelOf(t.events.last.cardId),
                              onUndo: c.canUndoLast
                                  ? () => c.undoLast(
                                      expectedCardInstanceId:
                                          t.events.last.cardInstanceId,
                                    )
                                  : null,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: t.cardId == null
                        ? _DeckEmptyCard(
                            onReshuffle: c.reshuffle,
                            onEnd: () => c.finishTurn(expectedTurnId: t.turnId),
                          )
                        : AnimatedSwitcher(
                            duration: reduce
                                ? Duration.zero
                                : const Duration(milliseconds: 260),
                            reverseDuration: reduce
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            switchInCurve: Gn.easeOut,
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.center,
                              children: [...previous, ?current],
                            ),
                            transitionBuilder: (child, anim) {
                              final incoming = child.key == ValueKey(t.cardId);
                              return incoming
                                  ? _dealIn(child, anim)
                                  : _flyOut(child, anim, _lastOutcome);
                            },
                            child: KeyedSubtree(
                              key: ValueKey(t.cardId),
                              // Inset so the tilted card's corners stay inside the screen.
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Center(
                                  child: widget.cardBuilder(context, t.cardId!),
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: tall ? 118 : 92,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _Pad(
                            label: 'Pass',
                            semantic: 'Pass',
                            icon: Icons.keyboard_double_arrow_right_rounded,
                            color: Gn.surface2,
                            lip: Gn.lipDark,
                            fg: Gn.text1,
                            onTap: t.cardId == null || !canHostScore
                                ? null
                                : () => c.mark(
                                    Outcome.pass,
                                    expectedCardInstanceId: t.cardInstanceId,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          // Design CH5: Skip : Got it ≈ 1 : 1.5
                          child: _Pad(
                            label: 'Got it',
                            semantic: 'Correct, got it',
                            icon: Icons.check_rounded,
                            color: Gn.correct,
                            lip: Gn.correctDeep,
                            fg: Gn.ink,
                            big: true,
                            onTap: t.cardId == null || !canHostScore
                                ? null
                                : () => c.mark(
                                    Outcome.correct,
                                    expectedCardInstanceId: t.cardInstanceId,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (t.paused) const PausedOverlay(),
          ],
        );
      },
    );
  }

  Widget _dealIn(Widget child, Animation<double> a) => FadeTransition(
    opacity: a,
    child: ScaleTransition(
      scale: Tween(
        begin: 0.92,
        end: 1.0,
      ).animate(CurvedAnimation(parent: a, curve: Gn.springCurve)),
      child: child,
    ),
  );

  Widget _flyOut(Widget child, Animation<double> a, Outcome o) =>
      AnimatedBuilder(
        animation: a,
        child: child,
        builder: (context, child) {
          final p = 1 - a.value; // 0 → 1 as the card leaves
          final w = MediaQuery.of(context).size.width;
          final (dx, dy, rot) = switch (o) {
            Outcome.correct => (w * 0.9 * p, -30 * p, 0.22 * p),
            Outcome.pass => (-w * 0.9 * p, -20 * p, -0.18 * p),
            _ => (sin(p * pi * 6) * 14 * (1 - p), 220 * p * p, 0.0),
          };
          return Opacity(
            opacity: (1 - p).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(dx, dy),
              child: Transform.rotate(angle: rot, child: child),
            ),
          );
        },
      );
}

class _Banner extends StatelessWidget {
  const _Banner({
    super.key,
    required this.event,
    required this.label,
    required this.onUndo,
  });
  final TurnEvent event;
  final String label;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, text) = switch (event.outcome) {
      Outcome.correct => (
        Gn.correct,
        Gn.ink,
        Icons.check_rounded,
        '$label  +1',
      ),
      Outcome.violation => (
        Gn.violation,
        Gn.ink,
        Icons.warning_amber_rounded,
        'Buzzed: $label  −1',
      ),
      _ => (
        Gn.surface2,
        Gn.text1,
        Icons.keyboard_double_arrow_right_rounded,
        'Passed: $label',
      ),
    };
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Gn.uiStyle(14, color: fg, weight: FontWeight.w800),
            ),
          ),
          Semantics(
            button: true,
            label: 'Undo',
            excludeSemantics: true,
            onTap: onUndo,
            enabled: onUndo != null,
            child: GestureDetector(
              onTap: onUndo,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(
                      Icons.undo_rounded,
                      size: 16,
                      color: onUndo == null ? Gn.text3 : fg,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Undo',
                      style: Gn.uiStyle(
                        14,
                        color: onUndo == null ? Gn.text3 : fg,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Oversized Got it / Pass pad (design CH5, FW5).
class _Pad extends StatefulWidget {
  const _Pad({
    required this.label,
    required this.semantic,
    required this.icon,
    required this.color,
    required this.lip,
    required this.fg,
    required this.onTap,
    this.big = false,
  });
  final String label;
  final String semantic;
  final IconData icon;
  final Color color, lip, fg;
  final VoidCallback? onTap;
  final bool big;

  @override
  State<_Pad> createState() => _PadState();
}

class _PadState extends State<_Pad> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semantic,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            margin: EdgeInsets.only(top: _down ? 4 : 0, bottom: _down ? 2 : 6),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(color: widget.lip, offset: Offset(0, _down ? 2 : 6)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.fg, size: widget.big ? 34 : 28),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: Gn.displayStyle(
                    widget.big ? 26 : 21,
                    color: widget.fg,
                    spacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckEmptyCard extends StatelessWidget {
  const _DeckEmptyCard({required this.onReshuffle, required this.onEnd});
  final VoidCallback onReshuffle;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Gn.surface1,
        borderRadius: BorderRadius.circular(Gn.r2xl),
        border: Border.all(color: Gn.border, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.style_outlined, size: 48, color: Gn.text3),
          const SizedBox(height: 10),
          Text(
            'That deck is empty',
            textAlign: TextAlign.center,
            style: Gn.displayStyle(24, spacing: 0),
          ),
          const SizedBox(height: 6),
          Text(
            'Every card has been played. Reshuffle earlier cards back in, or end this turn.',
            textAlign: TextAlign.center,
            style: Gn.uiStyle(14, color: Gn.text2, weight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          GnButton(
            label: 'Reshuffle',
            icon: Icons.refresh_rounded,
            height: 52,
            fontSize: 18,
            onPressed: onReshuffle,
          ),
          const SizedBox(height: 8),
          GnButton(
            label: 'End turn',
            outline: true,
            foreground: Gn.text1,
            height: 50,
            onPressed: onEnd,
          ),
        ],
      ),
    ),
  );
}
