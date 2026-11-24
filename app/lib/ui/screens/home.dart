// Home (design S03 / S04): a table with four decks on it, not a dashboard.
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'sheets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Home is built as a const widget, so it must listen to the controller itself
  // (e.g. the Resume card has to disappear after Discard).
  late final _controller = context.getInheritedWidgetOfExactType<AppScope>()!.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = scope.controller;
    final resumable = c.hasUnfinished;
    return PageFrame(
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 52,
              child: Row(children: [
                const Expanded(
                  child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Wordmark(size: 32)),
                ),
                const FullscreenButton(),
                const SizedBox(width: 8),
                IconSquare(
                  icon: scope.fx.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  label: scope.fx.muted ? 'Sound off. Turn sound on' : 'Sound on. Turn sound off',
                  onTap: () => setState(() {
                    scope.fx.muted = !scope.fx.muted;
                    scope.store.setFlag('muted', scope.fx.muted);
                  }),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            if (resumable) ...[
              const _ResumeCard(),
              const SizedBox(height: 22),
              const Eyebrow('Or start fresh'),
            ] else ...[
              Text('Who’s playing tonight?', style: Gn.displayStyle(30)),
              const SizedBox(height: 6),
              Text('Pick a game. One phone, passed around the room.',
                  style: Gn.uiStyle(15, color: Gn.text2, weight: FontWeight.w500)),
            ],
            const SizedBox(height: 16),
          ]),
        ),
        SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.84,
          children: [
            for (final (i, g) in GameKind.values.indexed)
              _GameTile(game: g, tilt: const [-1.2, 1.0, 0.8, -1.0][i], onTap: () => scope.nav.setup(g)),
          ],
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('No sign-up · No internet needed once loaded',
                  textAlign: TextAlign.center, style: Gn.uiStyle(13, color: Gn.text3)),
              const SizedBox(height: 4),
              Text('Card decks are candidate drafts for private playtesting.',
                  textAlign: TextAlign.center, style: Gn.uiStyle(12, color: Gn.text3, weight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _GameTile extends StatefulWidget {
  const _GameTile({required this.game, required this.tilt, required this.onTap});
  final GameKind game;
  final double tilt;
  final VoidCallback onTap;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final pal = g.palette;
    final count = AppScope.of(context).controller.library.count(g);
    return Semantics(
      button: true,
      label: '${g.title}. ${g.tagline}',
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: Transform.rotate(
          angle: widget.tilt * pi / 180,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 70),
            margin: EdgeInsets.only(top: _down ? 3 : 0, bottom: _down ? 0 : 3),
            decoration: BoxDecoration(
              color: pal.accent,
              borderRadius: BorderRadius.circular(Gn.rXl),
              boxShadow: [BoxShadow(color: pal.deep, offset: Offset(0, _down ? 2 : 5))],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GlyphTile(g, size: 42),
              const Spacer(),
              Text(g.title, style: Gn.displayStyle(20, color: Gn.ink, height: 1.0)),
              const SizedBox(height: 5),
              Text(g.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Gn.uiStyle(12, color: Gn.ink.withValues(alpha: 0.8), weight: FontWeight.w600, height: 1.2)),
              const SizedBox(height: 4),
              Text('${g.defaultSeconds}s${g.perQuestionTimer ? ' each' : ''} · $count cards',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Gn.uiStyle(11.5, color: Gn.ink.withValues(alpha: 0.7), weight: FontWeight.w800)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Session recovery (design S04).
class _ResumeCard extends StatelessWidget {
  const _ResumeCard();

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final c = scope.controller;
    final s = c.session!;
    final mins = ((c.now() - s.updatedAt) / 60000).floor();
    final ago = mins < 1 ? 'just now' : (mins < 60 ? '$mins min ago' : '${mins ~/ 60} h ago');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Gn.surface1,
        borderRadius: BorderRadius.circular(Gn.rXl),
        border: Border.all(color: Gn.spark, width: 2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GameChip(s.game),
          const Spacer(),
          Text(ago, style: Gn.uiStyle(13, color: Gn.text3)),
        ]),
        const SizedBox(height: 12),
        Text('Your game is still on', style: Gn.displayStyle(23)),
        const SizedBox(height: 4),
        Text(resumeSummary(s), style: Gn.uiStyle(14, color: Gn.text2, weight: FontWeight.w500)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            flex: 3,
            child: GnButton(
              label: 'Resume',
              icon: Icons.play_arrow_rounded,
              height: 54,
              fontSize: 19,
              onPressed: () {
                restoreFullscreen(scope);
                scope.nav.session();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GnButton(
              label: 'Discard',
              outline: true,
              foreground: Gn.text1,
              height: 54,
              onPressed: () async {
                if (await confirm(context,
                    title: 'Discard this game?',
                    body: 'Scores and progress for this ${s.game.title} game will be lost.',
                    yes: 'Discard game',
                    danger: true)) {
                  c.discard();
                }
              },
            ),
          ),
        ]),
      ]),
    );
  }
}

String resumeSummary(Session s) {
  final st = standingsFor(s.scores);
  final lead = st.first;
  final scoreLine = st.length > 1 && st[0].score == st[1].score
      ? 'level at ${st[0].score}–${st[1].score}'
      : '${s.teams[lead.team].name} lead ${st[0].score}–${st[1].score}';
  final where = s.phase == Phase.playing ? 'turn in progress' : 'round ${s.round} of ${s.config.rounds}';
  return '${where[0].toUpperCase()}${where.substring(1)} · $scoreLine';
}
