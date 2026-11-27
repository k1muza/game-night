import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';

/// Rules from the design's "How to play" boards (SP1, CH1, TR1, FW1), adapted
/// to one shared phone.
const Map<GameKind, List<(String, String)>> rules = {
  GameKind.sprint: [
    ('One talks, the rest guess', 'Pick a clue-giver. Only they see the card.'),
    (
      'Five terms, 30 seconds',
      'Describe them in any order. Tap each one your team says — tap again to undo.',
    ),
    (
      'No cheating words',
      'Don’t say the word, rhyme it, spell it, translate it or point.',
    ),
    (
      'Score',
      '+1 per term. Clear all five and the turn ends early. Every team gets equal turns.',
    ),
  ],
  GameKind.charades: [
    (
      'Act it out, don’t say it',
      'One actor. No talking, no sounds, no lip-syncing.',
    ),
    ('60 seconds, many prompts', 'Get through as many as your team can guess.'),
    ('Pass freely', 'Stuck? Passing costs nothing — the next prompt is ready.'),
    (
      'Score',
      '+1 per prompt guessed. Classic signals (‘film’, ‘syllables’) are allowed.',
    ),
  ],
  GameKind.trivia: [
    ('Huddle up', 'Your team reads the question together and argues it out.'),
    (
      'Pick, then lock in',
      'Tap an answer, then Lock in. Only a locked answer counts — beat the clock!',
    ),
    (
      'Beat the clock',
      '30 seconds per question (adjustable from 20–40), five questions per turn.',
    ),
    (
      'Score',
      '+1 per correct answer. No penalty for wrong ones. Every team gets the same difficulty mix.',
    ),
  ],
  GameKind.forbidden: [
    (
      'Describe the big word',
      'Get your team to say the word at the top of the card.',
    ),
    (
      'Five words are off-limits',
      'Plus the target itself, any part of it, rhymes and spelling.',
    ),
    (
      'The other team is listening',
      'One opponent watches over your shoulder and taps BUZZ for a slip: −1.',
    ),
    (
      'Score',
      '+1 per word guessed. Passes are free. Turn scores can go below zero.',
    ),
  ],
};

const Map<GameKind, String> tips = {
  GameKind.sprint:
      'Whole card too hard? Skip it once per turn — before you tick any term.',
  GameKind.charades:
      'Acting with both hands? Give the phone to a teammate to tap Got it.',
  GameKind.trivia: 'Read the explanation — it might come up again tonight.',
  GameKind.forbidden:
      'Keep it verbal — no gestures. That’s what Charades is for.',
};

Future<void> showHowToPlay(BuildContext context, GameKind game) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Gn.table,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconSquare(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: () => Navigator.pop(ctx),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'How to play',
                        style: Gn.displayStyle(22, spacing: 0),
                      ),
                    ),
                  ),
                  GameChip(game),
                ],
              ),
              const SizedBox(height: 16),
              for (final (i, (title, body)) in rules[game]!.indexed) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Gn.surface1,
                    borderRadius: BorderRadius.circular(Gn.rMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: game.palette.accent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: Gn.displayStyle(17, color: Gn.ink, spacing: 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Gn.uiStyle(16, weight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              body,
                              style: Gn.uiStyle(
                                14,
                                color: Gn.text2,
                                weight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Spark(size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tips[game]!,
                      style: Gn.uiStyle(14, color: Gn.text2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GnButton(
                label: 'Got it',
                icon: Icons.check_rounded,
                color: game.palette.accent,
                lip: game.palette.deep,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showAboutDiagnostics(BuildContext context) async {
  final scope = AppScope.of(context);
  final info = await PackageInfo.fromPlatform();
  final manifest = scope.controller.library.manifest;
  final games = manifest?['games'] as Map<String, dynamic>? ?? {};
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Gn.table,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'About & diagnostics',
                style: Gn.displayStyle(24, spacing: 0),
              ),
              const SizedBox(height: 16),
              _DiagnosticRow(
                'App version',
                '${info.version} (${info.buildNumber})',
              ),
              _DiagnosticRow(
                'Content library',
                manifest?['contentLibraryVersion']?.toString() ?? 'Unknown',
              ),
              _DiagnosticRow(
                'Platform',
                kIsWeb ? 'Web' : defaultTargetPlatform.name,
              ),
              for (final entry in games.entries)
                _DiagnosticRow(
                  '${entry.key}: ${entry.value['cards']} cards',
                  (entry.value['runtimeFingerprint'] as String?)?.substring(
                        0,
                        12,
                      ) ??
                      'Unknown',
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Gn.uiStyle(14, weight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Gn.uiStyle(13, color: Gn.text2),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String yes,
  String no = 'Cancel',
  bool danger = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => Dialog(
      backgroundColor: Gn.surface1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Gn.rXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Gn.displayStyle(24, spacing: 0)),
            const SizedBox(height: 8),
            Text(
              body,
              style: Gn.uiStyle(
                15,
                color: Gn.text2,
                weight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GnButton(
                    label: no,
                    outline: true,
                    height: 54,
                    foreground: Gn.text1,
                    onPressed: () => Navigator.pop(ctx, false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GnButton(
                    label: yes,
                    height: 54,
                    fontSize: 18,
                    color: danger ? Gn.violation : Gn.card,
                    lip: danger ? Gn.violationDeep : Gn.cardLip,
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return r ?? false;
}

/// Bottom-sheet menu available between turns.
Future<void> showGameMenu(BuildContext context) {
  final scope = AppScope.of(context);
  final s = scope.controller.session!;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Gn.table,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Game menu',
                        style: Gn.displayStyle(24, spacing: 0),
                      ),
                    ),
                    GameChip(s.game),
                  ],
                ),
                const SizedBox(height: 16),
                _MenuRow(
                  icon: Icons.help_outline_rounded,
                  label: 'How to play',
                  onTap: () {
                    Navigator.pop(ctx);
                    showHowToPlay(context, s.game);
                  },
                ),
                _MenuRow(
                  icon: scope.fx.muted
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  label: scope.fx.muted ? 'Sound is off' : 'Sound is on',
                  onTap: () {
                    scope.fx.muted = !scope.fx.muted;
                    scope.store.setFlag('muted', scope.fx.muted);
                    setSheet(() {});
                  },
                ),
                _MenuRow(
                  icon: scope.fx.hapticsEnabled
                      ? Icons.vibration_rounded
                      : Icons.mobile_off_rounded,
                  label: scope.fx.hapticsEnabled
                      ? 'Haptics are on'
                      : 'Haptics are off',
                  onTap: () {
                    scope.fx.hapticsEnabled = !scope.fx.hapticsEnabled;
                    scope.store.setFlag(
                      'hapticsDisabled',
                      !scope.fx.hapticsEnabled,
                    );
                    setSheet(() {});
                  },
                ),
                _MenuRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About & diagnostics',
                  onTap: () {
                    Navigator.pop(ctx);
                    showAboutDiagnostics(context);
                  },
                ),
                _MenuRow(
                  icon: Icons.shuffle_rounded,
                  label: 'Shuffle deck',
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (await confirm(
                      context,
                      title: 'Shuffle this deck?',
                      body:
                          'The persistent card queue will be randomly reordered. It will continue from the shuffled order.',
                      yes: 'Shuffle',
                    )) {
                      scope.controller.reshuffle();
                    }
                  },
                ),
                if (scope.fx.fullscreenSupported)
                  _MenuRow(
                    icon: scope.fx.fullscreen.value
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    label: scope.fx.fullscreen.value
                        ? 'Exit full screen'
                        : 'Full screen',
                    onTap: () {
                      setFullscreenPreference(
                        scope,
                        !scope.fx.fullscreen.value,
                      );
                      Navigator.pop(ctx);
                    },
                  ),
                _MenuRow(
                  icon: Icons.home_rounded,
                  label: 'Home (your game is saved)',
                  onTap: () {
                    Navigator.pop(ctx);
                    scope.nav.home();
                  },
                ),
                _MenuRow(
                  icon: Icons.flag_rounded,
                  label: 'End game and see results',
                  color: Gn.violation,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (await confirm(
                      context,
                      title: 'End the game now?',
                      body:
                          'Scores so far become the final standings. Teams may not have had equal turns.',
                      yes: 'End game',
                      danger: true,
                    )) {
                      scope.controller.endGame();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Gn.text1,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Gn.surface1,
            borderRadius: BorderRadius.circular(Gn.rMd),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: Gn.uiStyle(16, color: color, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shown over a play screen while the clock is paused. Covers the card, so a
/// paused phone left on the table doesn't leak the prompt.
class PausedOverlay extends StatelessWidget {
  const PausedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = scope.controller;
    final s = c.session!;
    final secs = (c.remainingMs() / 1000).ceil();
    return Positioned.fill(
      child: Container(
        color: Gn.sheet, // fully opaque: the card must not show through
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Icon(
                        Icons.pause_circle_filled_rounded,
                        size: 64,
                        color: s.game.palette.accent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Paused',
                      textAlign: TextAlign.center,
                      style: Gn.displayStyle(36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The clock stopped at $secs s. The card is hidden until you resume.',
                      textAlign: TextAlign.center,
                      style: Gn.uiStyle(
                        16,
                        color: Gn.text2,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GnButton(
                      label: 'Resume',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () => c.resume(expectedTurnId: s.turn?.turnId),
                    ),
                    const SizedBox(height: 10),
                    GnButton(
                      label: 'End this turn now',
                      outline: true,
                      foreground: Gn.text1,
                      height: 54,
                      onPressed: () async {
                        if (await confirm(
                          context,
                          title: 'End this turn?',
                          body:
                              'Points scored so far count. The remaining time is lost.',
                          yes: 'End turn',
                        )) {
                          c.finishTurn(expectedTurnId: s.turn?.turnId);
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => showHowToPlay(context, s.game),
                          child: Text(
                            'How to play',
                            style: Gn.uiStyle(
                              15,
                              color: Gn.text2,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: scope.nav.home,
                          child: Text(
                            'Home (game saved)',
                            style: Gn.uiStyle(
                              15,
                              color: Gn.text2,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header shared by play screens: pause button + clock (+ optional extras).
class PauseButton extends StatelessWidget {
  const PauseButton({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).controller;
    final turnId = controller.session?.turn?.turnId;
    return IconSquare(
      icon: Icons.pause_rounded,
      label: 'Pause',
      onTap: () => controller.pause(expectedTurnId: turnId),
    );
  }
}

String teamTurnLabel(Team t) => '${t.name.toUpperCase()}’S TURN';

/// Turns fullscreen on or off and remembers the choice.
void setFullscreenPreference(AppScope scope, bool on) {
  scope.store.setFlag('fullscreen', on);
  scope.fx.setFullscreen(on);
}

/// Browsers drop fullscreen on reload or the Android back gesture, and only
/// allow it again from a tap. Called from the main Start/Resume taps so a
/// player who chose fullscreen gets it back without hunting for the toggle.
void restoreFullscreen(AppScope scope) {
  if (scope.store.flag('fullscreen') && !scope.fx.fullscreen.value)
    scope.fx.setFullscreen(true);
}

/// Icon button reflecting the live fullscreen state; hidden where unsupported.
class FullscreenButton extends StatelessWidget {
  const FullscreenButton({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    if (!scope.fx.fullscreenSupported) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: scope.fx.fullscreen,
      builder: (context, on, _) => IconSquare(
        icon: on ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
        label: on ? 'Exit full screen' : 'Full screen',
        onTap: () => setFullscreenPreference(scope, !on),
      ),
    );
  }
}
