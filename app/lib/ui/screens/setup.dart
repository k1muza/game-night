// Game setup (prototype "Quick play" + S06 game details). Accept the defaults
// and start in one tap; everything else is optional and collapsed.
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/cards.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'sheets.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.game});
  final GameKind game;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final List<(int palette, TextEditingController name)> _teams = [];
  int _rounds = 5;
  late int _seconds = widget.game.defaultSeconds;
  int _questions = 5;
  Difficulty? _difficulty;
  PlayMode _mode = PlayMode.classic;

  @override
  void initState() {
    super.initState();
    _addTeam();
    _addTeam();
  }

  @override
  void dispose() {
    for (final t in _teams) {
      t.$2.dispose();
    }
    super.dispose();
  }

  void _addTeam() {
    final used = _teams.map((t) => t.$1).toSet();
    final p = List.generate(
      teamStyles.length,
      (i) => i,
    ).firstWhere((i) => !used.contains(i));
    _teams.add((p, TextEditingController()));
  }

  Future<void> _start() async {
    final scope = AppScope.of(context);
    final c = scope.controller;
    if (c.hasUnfinished) {
      final ok = await confirm(
        context,
        title: 'Start a new game?',
        body:
            'Your unfinished ${c.session!.game.title} game will be discarded.',
        yes: 'Start new',
        danger: true,
      );
      if (!ok || !mounted) return;
    }
    scope.fx.unlock();
    restoreFullscreen(scope);
    // Duplicate names would make the standings ambiguous: number repeats.
    final seen = <String, int>{};
    final teams = [
      for (final (p, ctrl) in _teams)
        () {
          final base = ctrl.text.trim().isEmpty
              ? teamStyles[p].defaultName
              : ctrl.text.trim();
          final n = seen.update(
            base.toLowerCase(),
            (v) => v + 1,
            ifAbsent: () => 1,
          );
          return Team(n == 1 ? base : '$base $n', p);
        }(),
    ];
    c.newSession(
      GameConfig(
        game: widget.game,
        rounds: _rounds,
        seconds: _seconds,
        questionsPerTurn: _questions,
        difficulty: _difficulty,
        mode: _mode,
      ),
      teams,
    );
    if (_mode == PlayMode.referee) {
      try {
        await scope.referee.startHost();
        if (mounted) scope.nav.hostPairing();
      } catch (error) {
        c.switchToClassic();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Local referee setup failed: $error. Continuing in Classic Mode.',
              ),
            ),
          );
          scope.nav.session();
        }
      }
    } else {
      scope.nav.session();
    }
  }

  Future<void> _showSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Gn.table,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final scope = AppScope.of(context);
        final g = widget.game;
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setSheet) => ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.92,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconSquare(
                          icon: Icons.close_rounded,
                          label: 'Close settings',
                          onTap: () => Navigator.pop(ctx),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Game setup',
                            style: Gn.displayStyle(22, spacing: 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Eyebrow('Rounds'),
                    const SizedBox(height: 8),
                    _Stepper(
                      label: 'Rounds per team',
                      value: _rounds,
                      min: 1,
                      max: 10,
                      onChanged: (v) => setState(() {
                        _rounds = v;
                        setSheet(() {});
                      }),
                    ),
                    if (g.perQuestionTimer) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Time per question',
                        style: Gn.uiStyle(
                          14,
                          color: Gn.text2,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Segmented(
                        options: [for (final s in g.timerOptions) ('${s}s', s)],
                        value: _seconds,
                        onChanged: (v) => setState(() {
                          _seconds = v;
                          setSheet(() {});
                        }),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        'Turn length',
                        style: Gn.uiStyle(
                          14,
                          color: Gn.text2,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Segmented(
                        options: [for (final s in g.timerOptions) ('${s}s', s)],
                        value: _seconds,
                        onChanged: (v) => setState(() {
                          _seconds = v;
                          setSheet(() {});
                        }),
                      ),
                    ],
                    if (g == GameKind.trivia) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Questions per turn',
                        style: Gn.uiStyle(
                          14,
                          color: Gn.text2,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Segmented(
                        options: const [('3', 3), ('5', 5), ('7', 7)],
                        value: _questions,
                        onChanged: (v) => setState(() {
                          _questions = v;
                          setSheet(() {});
                        }),
                      ),
                    ],
                    if (g.difficulties.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Cards',
                        style: Gn.uiStyle(
                          14,
                          color: Gn.text2,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ChoiceChip(
                            label: 'Mixed',
                            selected: _difficulty == null,
                            onTap: () => setState(() {
                              _difficulty = null;
                              setSheet(() {});
                            }),
                          ),
                          for (final d in g.difficulties)
                            _ChoiceChip(
                              label: d.label,
                              selected: _difficulty == d,
                              onTap: () => setState(() {
                                _difficulty = d;
                                setSheet(() {});
                              }),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Eyebrow('Play mode'),
                    const SizedBox(height: 8),
                    Text(
                      _mode == PlayMode.classic
                          ? 'Classic: one phone, no pairing or network.'
                          : 'Referee: two phones with independent scoring.',
                      style: Gn.uiStyle(
                        14,
                        color: Gn.text2,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Eyebrow('Feedback'),
                    const SizedBox(height: 8),
                    _SettingsSwitch(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound effects',
                      value: !scope.fx.muted,
                      onChanged: (v) {
                        scope.fx.muted = !v;
                        scope.store.setFlag('muted', scope.fx.muted);
                        setSheet(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    _SettingsSwitch(
                      icon: Icons.vibration_rounded,
                      label: 'Haptic feedback',
                      value: scope.fx.hapticsEnabled,
                      onChanged: (v) {
                        scope.fx.hapticsEnabled = v;
                        scope.store.setFlag('hapticsDisabled', !v);
                        setSheet(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    GnButton(
                      label: 'How to play',
                      icon: Icons.help_outline_rounded,
                      outline: true,
                      foreground: Gn.text1,
                      onPressed: () {
                        Navigator.pop(ctx);
                        showHowToPlay(context, g);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final pal = g.palette;
    final turns = _rounds * _teams.length;
    final perTurn = g == GameKind.trivia
        ? _questions * (_seconds * 0.7 + 12)
        : _seconds + 30;
    final minutes = (turns * perTurn / 60).round();
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                IconSquare(
                  icon: Icons.chevron_left_rounded,
                  label: 'Back',
                  onTap: AppScope.of(context).nav.home,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Game setup',
                      style: Gn.displayStyle(24, spacing: 0),
                    ),
                  ),
                ),
                IconSquare(
                  icon: Icons.settings_rounded,
                  label: 'Game setup settings',
                  onTap: () => _showSettings(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Hero(game: g),
                if (g == GameKind.sprint || g == GameKind.forbidden) ...[
                  const SizedBox(height: 14),
                  const Eyebrow('Play mode'),
                  const SizedBox(height: 7),
                  _Segmented<PlayMode>(
                    options: const [
                      ('Classic', PlayMode.classic),
                      ('Referee', PlayMode.referee),
                    ],
                    value: _mode,
                    onChanged: (v) {
                      if (v == PlayMode.referee &&
                          !AppScope.of(context).referee.supported) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Referee mode is only available in the Android and iOS app.',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _mode = v);
                    },
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _mode == PlayMode.classic
                        ? 'Classic: One phone.'
                        : 'Referee: Two phones with independent scoring.',
                    style: Gn.uiStyle(
                      13,
                      color: Gn.text3,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Eyebrow('Teams'),
                    const Spacer(),
                    Text(
                      'Names optional',
                      style: Gn.uiStyle(13, color: Gn.text3),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final (i, (p, ctrl)) in _teams.indexed) ...[
                  _TeamRow(
                    palette: p,
                    controller: ctrl,
                    onRemove: _teams.length > 2
                        ? () => setState(() {
                            _teams.removeAt(i).$2.dispose();
                          })
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
                if (_teams.length < 6)
                  _DashedButton(
                    label: 'Add a team',
                    onTap: () => setState(_addTeam),
                  ),
                const SizedBox(height: 14),
                Text(
                  '$_rounds rounds · $turns turns · about $minutes min',
                  style: Gn.uiStyle(
                    13,
                    color: Gn.text3,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GnButton(
            label: 'Start game',
            icon: Icons.play_arrow_rounded,
            color: pal.accent,
            lip: pal.deep,
            onPressed: _start,
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.game});
  final GameKind game;
  @override
  Widget build(BuildContext context) {
    final pal = game.palette;
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: pal.accent,
        borderRadius: BorderRadius.circular(Gn.r2xl - 4),
        boxShadow: [BoxShadow(color: pal.deep, offset: const Offset(0, 5))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GameMotif(game),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlyphTile(game, size: 38),
                const Spacer(),
                Text(
                  game.title,
                  style: Gn.displayStyle(34, color: Gn.ink, height: 1.0),
                ),
                const SizedBox(height: 6),
                Text(
                  game.tagline,
                  style: Gn.uiStyle(15, color: Gn.ink, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.palette,
    required this.controller,
    this.onRemove,
  });
  final int palette;
  final TextEditingController controller;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final st = teamStyles[palette];
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(
        color: Gn.surface1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          TeamMark(palette, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 18,
              textCapitalization: TextCapitalization.words,
              style: Gn.uiStyle(17, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: st.defaultName,
                hintStyle: Gn.uiStyle(
                  17,
                  color: Gn.text2,
                  weight: FontWeight.w700,
                ),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip:
                  'Remove ${controller.text.isEmpty ? st.defaultName : controller.text}',
              icon: const Icon(Icons.close_rounded, color: Gn.text3),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.edit_rounded, color: Gn.text3, size: 18),
            ),
        ],
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Gn.border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Gn.text2),
            const SizedBox(width: 6),
            Text(
              label,
              style: Gn.uiStyle(15, color: Gn.text2, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.only(left: 14, right: 8),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Gn.text2),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Gn.uiStyle(15, weight: FontWeight.w700)),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.only(left: 16, right: 6),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Text(label, style: Gn.uiStyle(16, weight: FontWeight.w700)),
        const Spacer(),
        _round(
          Icons.remove_rounded,
          'Fewer turns',
          value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 44,
          child: Semantics(
            value: '$value',
            label: label,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Gn.displayStyle(24, spacing: 0),
            ),
          ),
        ),
        _round(
          Icons.add_rounded,
          'More turns',
          value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    ),
  );

  Widget _round(IconData i, String label, VoidCallback? onTap) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Gn.surface2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          i,
          color: onTap == null ? Gn.text3.withValues(alpha: 0.4) : Gn.text1,
        ),
      ),
    ),
  );
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<(String, T)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Row(
      children: [
        for (final (label, v) in options)
          Expanded(
            child: Semantics(
              button: true,
              selected: v == value,
              label: label,
              excludeSemantics: true,
              onTap: () => onChanged(v),
              child: GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: Gn.quick,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: v == value ? Gn.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(Gn.rSm),
                  ),
                  child: Text(
                    label,
                    style: Gn.uiStyle(
                      15,
                      color: v == value ? Gn.ink : Gn.text2,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Gn.card : Gn.surface1,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: Gn.ink),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Gn.uiStyle(
                14,
                color: selected ? Gn.ink : Gn.text1,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
