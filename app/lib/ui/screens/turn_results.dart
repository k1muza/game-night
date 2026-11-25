// End of a turn: the full-bleed "Time!" / "All five!" moment (design L05,
// SP6, CH11, FW11) followed by turn results and standings (L07, CH13, FW13).
import 'package:flutter/material.dart';

import '../../app.dart';
import '../../model/game_kind.dart';
import '../../session/session.dart';
import '../../session/session_controller.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';
import '../widgets/glyphs.dart';
import 'sheets.dart';

class TurnEndFlow extends StatefulWidget {
  const TurnEndFlow({super.key, required this.showSplash});

  /// Only when the turn ended live (not after a refresh) and by the clock or
  /// by clearing a Sprint card.
  final bool showSplash;

  @override
  State<TurnEndFlow> createState() => _TurnEndFlowState();
}

class _TurnEndFlowState extends State<TurnEndFlow> {
  late bool _splash;
  bool _inputLocked = true;

  @override
  void initState() {
    super.initState();
    final reason = context
        .getInheritedWidgetOfExactType<AppScope>()!
        .controller
        .session!
        .turn
        ?.ended;
    _splash =
        widget.showSplash &&
        (reason == EndReason.time || reason == EndReason.allFound);
    // Stop late taps from the clue-giver landing on the next button.
    Future.delayed(
      const Duration(milliseconds: SessionController.lateTapGuardMs),
      () {
        if (mounted) setState(() => _inputLocked = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).controller.session!;
    if (_splash) {
      return _Splash(
        session: s,
        onNext: _inputLocked ? null : () => setState(() => _splash = false),
      );
    }
    return const TurnResultsScreen();
  }
}

class _Splash extends StatelessWidget {
  const _Splash({required this.session, required this.onNext});
  final Session session;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final rec = session.history.last;
    final allFive = session.turn?.ended == EndReason.allFound;
    final bg = allFive ? GameKind.sprint.palette.accent : Gn.violation;
    final got = rec.count(Outcome.correct);
    final passed = rec.count(Outcome.pass);
    final buzz = rec.count(Outcome.violation);
    final summary = switch (session.game) {
      GameKind.sprint => (
        '$got',
        '/ 5 terms · ${rec.count(Outcome.disqualified)} disqualified',
      ),
      GameKind.charades => ('$got', 'guessed · $passed passed'),
      GameKind.forbidden => (
        '${rec.points >= 0 ? '+' : '−'}${rec.points.abs()}',
        '$got got · $buzz buzz · $passed pass',
      ),
      GameKind.trivia => ('$got', 'correct'),
    };
    return PageFrame(
      background: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (allFive) ...[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Spark(size: 22, color: Gn.ink),
                        Spark(size: 34, color: Gn.ink),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FittedBox(
                      child: Text(
                        'All five!',
                        style: Gn.displayStyle(78, color: Gn.ink),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${session.activeTeam.name} cleared the card. The turn ends now — equal chances for every team.',
                      textAlign: TextAlign.center,
                      style: Gn.uiStyle(
                        17,
                        color: Gn.ink,
                        weight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Gn.ink,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: GameKind.sprint.palette.accent,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: Gn.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.timer_rounded,
                        color: Gn.violation,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      child: Text(
                        'Time!',
                        style: Gn.displayStyle(92, color: Gn.ink, height: 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phone down, hands up.',
                      style: Gn.uiStyle(
                        19,
                        color: Gn.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Gn.ink,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            summary.$1,
                            style: Gn.displayStyle(40, spacing: 0),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            summary.$2,
                            style: Gn.uiStyle(
                              16,
                              color: Gn.text2,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          GnButton(
            label: 'See the scores',
            icon: Icons.chevron_right_rounded,
            color: Gn.ink,
            lip: Colors.black.withValues(alpha: 0.35),
            foreground: Gn.text1,
            onPressed: onNext,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class TurnResultsScreen extends StatelessWidget {
  const TurnResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    final s = c.session!;
    final rec = s.history.last;
    final team = s.teams[rec.team];
    final pal = s.game.palette;
    final nextIdx = c.nextTeamIndex;
    final standings = c.standings;
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                IconSquare(
                  icon: Icons.menu_rounded,
                  label: 'Game menu',
                  onTap: () => showGameMenu(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GameChip(s.game),
                  ),
                ),
                Text(
                  'Round ${rec.round} of ${s.config.rounds}',
                  style: Gn.uiStyle(
                    13,
                    color: Gn.text3,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                Center(child: TeamBadge(team, size: 17)),
                const SizedBox(height: 4),
                Semantics(
                  label: '${team.name} scored ${rec.points} this turn',
                  excludeSemantics: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spark(
                        size: 30,
                        color: rec.points > 0 ? pal.accent : Gn.text3,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${rec.points >= 0 ? '+' : '−'}${rec.points.abs()}',
                        style: Gn.displayStyle(
                          88,
                          color: rec.points < 0 ? Gn.violation : pal.accent,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  headline(s, rec),
                  textAlign: TextAlign.center,
                  style: Gn.uiStyle(16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: _summaryPills(s.game, rec),
                ),
                const SizedBox(height: 20),
                Eyebrow('Standings after ${team.name}’s turn'),
                const SizedBox(height: 10),
                for (final st in standings) ...[
                  StandingRow(
                    standing: st,
                    team: s.teams[st.team],
                    delta: st.team == rec.team ? rec.points : null,
                    leader: st.rank == 1,
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                _TurnCards(session: s, record: rec),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Gn.surface1,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  nextIdx == null ? 'Last turn played' : 'Up next',
                  style: Gn.uiStyle(13, color: Gn.text3),
                ),
                const SizedBox(width: 10),
                if (nextIdx != null)
                  Expanded(child: TeamBadge(s.teams[nextIdx], size: 14))
                else
                  const Spacer(),
                if (nextIdx != null && nextIdx == 0)
                  Text(
                    'Round ${s.round + 1}',
                    style: Gn.uiStyle(
                      13,
                      color: Gn.text3,
                      weight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GnButton(
            label: nextIdx == null ? 'See final results' : 'Next team',
            icon: Icons.chevron_right_rounded,
            onPressed: c.nextTurn,
          ),
        ],
      ),
    );
  }

  List<Widget> _summaryPills(GameKind g, TurnRecord r) {
    final got = r.count(Outcome.correct);
    return [
      Pill(
        text: g == GameKind.sprint
            ? '$got / 5 terms'
            : (g == GameKind.trivia ? '$got correct' : '$got got'),
        icon: Icons.check_rounded,
        fg: Gn.correct,
      ),
      if (g == GameKind.charades || g == GameKind.forbidden)
        Pill(
          text: '${r.count(Outcome.pass)} passed',
          icon: Icons.keyboard_double_arrow_right_rounded,
          fg: Gn.text2,
        ),
      if (g == GameKind.forbidden)
        Pill(
          text: '${r.count(Outcome.violation)} buzzed',
          icon: Icons.warning_amber_rounded,
          fg: Gn.violation,
        ),
      if (g == GameKind.trivia) ...[
        Pill(
          text: '${r.count(Outcome.wrong)} wrong',
          icon: Icons.close_rounded,
          fg: Gn.text2,
        ),
        if (r.count(Outcome.timeout) > 0)
          Pill(
            text: '${r.count(Outcome.timeout)} timed out',
            icon: Icons.timer_off_rounded,
            fg: Gn.warning,
          ),
      ],
      if (g == GameKind.sprint && r.count(Outcome.disqualified) > 0)
        Pill(
          text: '${r.count(Outcome.disqualified)} disqualified',
          icon: Icons.block_rounded,
          fg: Gn.violation,
        ),
    ];
  }
}

/// "Team A take the lead!" etc.
String headline(Session s, TurnRecord rec) {
  final name = s.teams[rec.team].name;
  final scores = s.scores;
  final before = List.of(scores)..[rec.team] -= rec.points;
  int leaderOf(List<int> sc) {
    final top = sc.reduce((a, b) => a > b ? a : b);
    return sc.where((x) => x == top).length > 1 ? -1 : sc.indexOf(top);
  }

  final now = leaderOf(scores), was = leaderOf(before);
  if (rec.points < 0) return 'Ouch — the buzzer bit $name.';
  if (now == rec.team && was != rec.team) return '$name take the lead!';
  if (now == rec.team) return '$name extend their lead.';
  if (now == -1) return 'All square at the top!';
  if (rec.points == 0) return 'Tough one for $name.';
  return '${s.teams[now].name} still lead by ${scores[now] - scores[rec.team]}.';
}

class StandingRow extends StatelessWidget {
  const StandingRow({
    super.key,
    required this.standing,
    required this.team,
    this.delta,
    this.leader = false,
  });
  final Standing standing;
  final Team team;
  final int? delta;
  final bool leader;

  @override
  Widget build(BuildContext context) {
    final fg = leader ? Gn.ink : Gn.text1;
    final rank = standing.tied ? '=${standing.rank}' : '${standing.rank}';
    return Semantics(
      label:
          'Rank $rank, ${team.name}, ${standing.score} points${standing.tied ? ', tied' : ''}',
      excludeSemantics: true,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: leader ? Gn.card : Gn.surface1,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                rank,
                style: Gn.displayStyle(
                  20,
                  color: leader ? Gn.ink : Gn.text3,
                  spacing: 0,
                ),
              ),
            ),
            TeamMark(
              team.paletteIndex,
              size: 20,
              stroke: leader ? Gn.ink : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Gn.uiStyle(16, color: fg, weight: FontWeight.w700),
              ),
            ),
            if (delta != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${delta! >= 0 ? '+' : '−'}${delta!.abs()}',
                  style: Gn.uiStyle(
                    13,
                    color: delta! < 0
                        ? Gn.violation
                        : (leader ? Gn.correctDeep : Gn.correct),
                    weight: FontWeight.w800,
                  ),
                ),
              ),
            Text(
              '${standing.score}',
              style: Gn.displayStyle(26, color: fg, spacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}

/// What happened this turn — every card with its outcome. Collapsed by default.
class _TurnCards extends StatefulWidget {
  const _TurnCards({required this.session, required this.record});
  final Session session;
  final TurnRecord record;
  @override
  State<_TurnCards> createState() => _TurnCardsState();
}

class _TurnCardsState extends State<_TurnCards> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final lib = AppScope.of(context).controller.library;
    final g = widget.session.game;
    final events = widget.record.events;
    if (events.isEmpty) return const SizedBox.shrink();
    String label(TurnEvent e) => switch (g) {
      GameKind.sprint => lib.sprint[e.cardId]!.terms[e.term!].text,
      GameKind.trivia => lib.trivia[e.cardId]!.answer,
      _ => lib.labelOf(g, e.cardId),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: 'This turn’s cards',
          excludeSemantics: true,
          onTap: () => setState(() => _open = !_open),
          child: GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  Eyebrow(
                    g == GameKind.trivia
                        ? 'This turn’s answers'
                        : 'This turn’s cards',
                  ),
                  const Spacer(),
                  Icon(
                    _open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Gn.text3,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open)
          for (final e in events) ...[
            _EventRow(outcome: e.outcome, text: label(e)),
            const SizedBox(height: 6),
          ],
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.outcome, required this.text});
  final Outcome outcome;
  final String text;
  @override
  Widget build(BuildContext context) {
    final (icon, chip, right) = switch (outcome) {
      Outcome.correct => (Icons.check_rounded, Gn.correct, '+1'),
      Outcome.violation => (Icons.warning_amber_rounded, Gn.violation, '−1'),
      Outcome.pass => (
        Icons.keyboard_double_arrow_right_rounded,
        Gn.surface2,
        'passed',
      ),
      Outcome.wrong => (Icons.close_rounded, Gn.surface2, 'wrong'),
      Outcome.timeout => (Icons.timer_off_rounded, Gn.surface2, 'no answer'),
      Outcome.disqualified => (
        Icons.block_rounded,
        Gn.violation,
        'disqualified',
      ),
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Gn.surface1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: chip,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 18,
              color: chip == Gn.surface2 ? Gn.text2 : Gn.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Gn.displayStyle(17, spacing: 0, height: 1.15),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            right,
            style: Gn.uiStyle(13, color: Gn.text3, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
