import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app.dart';
import '../../model/cards.dart';
import '../../model/game_kind.dart';
import '../../services/local_referee.dart';
import '../../session/session.dart';
import '../../theme/tokens.dart';
import '../widgets/common.dart';

class HostPairingScreen extends StatefulWidget {
  const HostPairingScreen({super.key});

  @override
  State<HostPairingScreen> createState() => _HostPairingScreenState();
}

class _HostPairingScreenState extends State<HostPairingScreen> {
  late final LocalRefereeService _service = AppScope.read(context).referee;

  @override
  void initState() {
    super.initState();
    _service.addListener(_changed);
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final pairing = _service.pairing;
    final connected = _service.isHostConnected;
    final game = scope.controller.session?.game;
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            title: 'Pair a referee',
            onBack: () async {
              await _service.takeOverClassic();
              if (mounted) scope.nav.session();
            },
          ),
          const SizedBox(height: 8),
          Text('Connect a second phone', style: Gn.displayStyle(30)),
          const SizedBox(height: 6),
          Text(
            'Both phones must use the same Wi-Fi or hotspot. Internet is not required.',
            style: Gn.uiStyle(15, color: Gn.text2, weight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Gn.surface1,
                      borderRadius: BorderRadius.circular(Gn.rXl),
                    ),
                    child: Column(
                      children: [
                        if (pairing != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.white,
                            child: QrImageView(
                              data: pairing.json,
                              size: 196,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                            ),
                          )
                        else
                          const SizedBox(
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              connected
                                  ? Icons.wifi_rounded
                                  : Icons.wifi_find_rounded,
                              color: connected ? Gn.correct : Gn.warning,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              connected
                                  ? 'Referee connected'
                                  : 'Waiting for referee',
                              style: Gn.uiStyle(16, weight: FontWeight.w800),
                            ),
                          ],
                        ),
                        if (game != null) ...[
                          const SizedBox(height: 8),
                          GameChip(game),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Manual pairing', style: Gn.displayStyle(20)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'If scanning is unavailable, enter these exact details on the referee phone:',
                    style: Gn.uiStyle(
                      14,
                      color: Gn.text2,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (pairing != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Gn.surface1,
                        borderRadius: BorderRadius.circular(Gn.rMd),
                      ),
                      child: SelectableText(
                        pairing.json,
                        style: Gn.uiStyle(
                          12,
                          color: Gn.text1,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'The pairing token is temporary and is invalidated when this session ends.',
                    style: TextStyle(color: Gn.text3, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GnButton(
            label: connected ? 'Continue to handover' : 'Waiting for referee…',
            icon: Icons.chevron_right_rounded,
            onPressed: connected ? scope.nav.session : null,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await _service.takeOverClassic();
              if (mounted) scope.nav.session();
            },
            child: const Text('Cancel and continue in Classic Mode'),
          ),
        ],
      ),
    );
  }
}

class JoinRefereeScreen extends StatefulWidget {
  const JoinRefereeScreen({super.key});

  @override
  State<JoinRefereeScreen> createState() => _JoinRefereeScreenState();
}

class _JoinRefereeScreenState extends State<JoinRefereeScreen> {
  final _pairingText = TextEditingController();
  late final LocalRefereeService _service = AppScope.read(context).referee;
  bool _scanning = false;
  bool _connecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service.addListener(_changed);
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    _pairingText.dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    if (_service.status == RefereeConnectionStatus.connected) {
      AppScope.of(context).nav.referee();
    } else {
      setState(() {});
    }
  }

  Future<void> _connect(String value) async {
    setState(() {
      _connecting = true;
      _error = null;
      _scanning = false;
    });
    try {
      final text = value.trim();
      final normalized = text.startsWith('{')
          ? text
          : Uri.decodeComponent(text);
      jsonDecode(normalized);
      await _service.connect(normalized);
    } catch (error) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = 'Could not connect: $error';
        });
      }
    }
  }

  void _barcodeDetected(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value != null && value.startsWith('{')) _connect(value);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(title: 'Join as Referee', onBack: scope.nav.home),
          if (!scope.referee.supported)
            const Expanded(
              child: Center(
                child: Text(
                  'Local referee pairing is supported in the Android and iOS app.',
                ),
              ),
            )
          else ...[
            Text('Connect to the host phone', style: Gn.displayStyle(28)),
            const SizedBox(height: 6),
            Text(
              'Join the same Wi-Fi or hotspot as the host. Pairing works without internet.',
              style: Gn.uiStyle(14, color: Gn.text2, weight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (_scanning)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Gn.rXl),
                  child: MobileScanner(onDetect: _barcodeDetected),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    GnButton(
                      label: 'Scan host QR code',
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: () => setState(() => _scanning = true),
                    ),
                    const SizedBox(height: 18),
                    const Eyebrow('Manual pairing'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pairingText,
                      minLines: 5,
                      maxLines: 7,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Gn.surface1,
                        hintText: 'Paste pairing details from the host phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Gn.rMd),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GnButton(
                      label: _connecting ? 'Connecting…' : 'Connect manually',
                      icon: Icons.link_rounded,
                      onPressed: _connecting || _pairingText.text.trim().isEmpty
                          ? null
                          : () => _connect(_pairingText.text),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style: Gn.uiStyle(
                          13,
                          color: Gn.violation,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (_service.status ==
                        RefereeConnectionStatus.reconnecting) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Connection interrupted. Trying to reconnect…',
                      ),
                    ],
                  ],
                ),
              ),
            if (_scanning)
              TextButton(
                onPressed: () => setState(() => _scanning = false),
                child: const Text('Enter details manually'),
              ),
          ],
        ],
      ),
    );
  }
}

class RefereeGameScreen extends StatefulWidget {
  const RefereeGameScreen({super.key});

  @override
  State<RefereeGameScreen> createState() => _RefereeGameScreenState();
}

class _RefereeGameScreenState extends State<RefereeGameScreen> {
  late final LocalRefereeService _service = AppScope.read(context).referee;
  Timer? _timer;
  Map<String, dynamic>? _lastSnapshot;
  DateTime _snapshotAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _lastSnapshot = _service.snapshot;
    _service.addListener(_changed);
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && _service.snapshot != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    _timer?.cancel();
    super.dispose();
  }

  void _changed() {
    final current = _service.snapshot;
    if (!identical(current, _lastSnapshot)) {
      _lastSnapshot = current;
      _snapshotAt = DateTime.now();
    }
    if (mounted) setState(() {});
  }

  int _remaining(Map<String, dynamic> state) {
    final remaining = state['remainingMs'];
    if (remaining is! int || state['paused'] == true) {
      return remaining is int ? remaining : 0;
    }
    return (remaining - DateTime.now().difference(_snapshotAt).inMilliseconds)
        .clamp(0, 1 << 31);
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final state = _service.snapshot;
    if (state == null) {
      return PageFrame(
        child: Column(
          children: [
            _PageHeader(
              title: 'Referee',
              onBack: () async {
                await _service.stop();
                if (mounted) scope.nav.home();
              },
            ),
            const Expanded(
              child: Center(
                child: Text('Waiting for the host to synchronise the game…'),
              ),
            ),
          ],
        ),
      );
    }
    final game = GameKind.values.byName(state['game'] as String);
    final phase = state['phase'] as String;
    final team = (state['team'] as Map).cast<String, dynamic>();
    final remaining = _remaining(state);
    return PageFrame(
      background: remaining <= 5000 && remaining > 0 ? Gn.warmTable : Gn.table,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('REFEREE', style: Gn.eyebrow(game.palette.accent)),
              ),
              _ConnectionPill(status: _service.status),
              const SizedBox(width: 8),
              IconSquare(
                icon: Icons.close_rounded,
                label: 'Leave referee session',
                onTap: () async {
                  await _service.stop();
                  if (mounted) scope.nav.home();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          TeamBadge(Team(team['name'] as String, team['paletteIndex'] as int)),
          const SizedBox(height: 12),
          if (phase == Phase.playing.name) ...[
            Row(
              children: [
                Expanded(
                  child: BarTimer(
                    remainingMs: remaining,
                    totalMs: state['durationMs'] as int,
                    color: game.palette.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(remaining / 1000).ceil()}s',
                  style: Gn.displayStyle(
                    28,
                    color: remaining <= 5000 ? Gn.warning : Gn.text1,
                    spacing: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _activeCard(game, state)),
            if (state['paused'] == true)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Pill(
                  text: 'Host paused the turn',
                  icon: Icons.pause_rounded,
                  fg: Gn.warning,
                ),
              ),
            if (_service.lastActionMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _service.lastActionMessage!,
                  textAlign: TextAlign.center,
                  style: Gn.uiStyle(
                    13,
                    color: _service.lastActionAccepted == false
                        ? Gn.violation
                        : Gn.text2,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
          ] else if (phase == Phase.turnReview.name ||
              phase == Phase.turnResults.name)
            Expanded(child: _turnReview(game, state))
          else if (phase == Phase.gameResults.name)
            const Expanded(
              child: Center(
                child: Text('The host ended the local referee session.'),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      size: 52,
                      color: Gn.text3,
                    ),
                    const SizedBox(height: 12),
                    Text('Waiting for the host', style: Gn.displayStyle(25)),
                    const SizedBox(height: 6),
                    Text(
                      'The next card stays hidden until the host starts the turn.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _activeCard(GameKind game, Map<String, dynamic> state) {
    final card = (state['card'] as Map?)?.cast<String, dynamic>();
    if (card == null) {
      return const Center(child: Text('Waiting for the active card…'));
    }
    if (game == GameKind.sprint) {
      final terms = (card['terms'] as List).cast<Map>();
      final marked = (state['marked'] as List).cast<int>().toSet();
      final disqualified = (state['disqualified'] as List).cast<int>().toSet();
      return ListView(
        children: [
          for (var i = 0; i < terms.length; i++) ...[
            _SprintRefereeTerm(
              term: terms[i].cast<String, dynamic>(),
              index: i,
              marked: marked.contains(i),
              disqualified: disqualified.contains(i),
              enabled: _service.status == RefereeConnectionStatus.connected,
              onAction: (action) => _service.sendAction(action, term: i),
            ),
            const SizedBox(height: 9),
          ],
        ],
      );
    }
    final clues = (card['clues'] as List).cast<String>();
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Gn.card,
                  borderRadius: BorderRadius.circular(Gn.r2xl),
                  boxShadow: const [
                    BoxShadow(color: Gn.cardLip, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Eyebrow('Get them to say'),
                    const SizedBox(height: 6),
                    FitText(
                      card['target'] as String,
                      maxLines: 3,
                      minSize: 28,
                      style: Gn.displayStyle(54, color: Gn.ink),
                    ),
                    const SizedBox(height: 20),
                    const Eyebrow('Don’t say'),
                    const SizedBox(height: 8),
                    for (final clue in clues)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          clue,
                          style: Gn.displayStyle(22, color: Gn.ink),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GnButton(
          label: 'BUZZ',
          icon: Icons.warning_amber_rounded,
          color: Gn.violation,
          lip: Gn.violationDeep,
          height: 88,
          fontSize: 30,
          onPressed: _service.status == RefereeConnectionStatus.connected
              ? () => _service.sendAction('buzz')
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap when a forbidden clue is spoken · −1 point',
          textAlign: TextAlign.center,
          style: Gn.uiStyle(13, color: Gn.text2),
        ),
      ],
    );
  }

  Widget _turnReview(GameKind game, Map<String, dynamic> state) {
    final review = (state['review'] as Map?)?.cast<String, dynamic>();
    if (review == null) return const Center(child: Text('Turn finished.'));
    final points = review['points'] as int;
    final awaitingConfirmation = state['phase'] == Phase.turnReview.name;
    final correctionRequested = state['correctionRequested'] == true;
    final card = (state['card'] as Map?)?.cast<String, dynamic>();
    return ListView(
      children: [
        const Icon(Icons.fact_check_outlined, size: 52, color: Gn.correct),
        const SizedBox(height: 12),
        Text(
          'Turn review',
          textAlign: TextAlign.center,
          style: Gn.displayStyle(30),
        ),
        const SizedBox(height: 12),
        Text(
          '${points >= 0 ? '+' : '−'}${points.abs()} points',
          textAlign: TextAlign.center,
          style: Gn.displayStyle(
            48,
            color: points < 0 ? Gn.violation : game.palette.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          game == GameKind.sprint
              ? '${review['correct']} correct · ${review['disqualified']} disqualified · ${review['passed']} unanswered'
              : '${review['correct']} got · ${review['passed']} passed · ${review['buzzed']} buzzed',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (awaitingConfirmation && !correctionRequested)
          GnButton(
            label: _service.lastActionMessage == 'Sending…'
                ? 'Requesting review…'
                : 'Request a correction',
            icon: Icons.flag_outlined,
            outline: true,
            foreground: Gn.text1,
            onPressed: _service.status == RefereeConnectionStatus.connected
                ? () => _service.sendAction('request_correction')
                : null,
          ),
        if (awaitingConfirmation && correctionRequested) ...[
          const Pill(
            text: 'Correction requested',
            icon: Icons.info_outline_rounded,
            fg: Gn.warning,
          ),
          const SizedBox(height: 8),
          if (game == GameKind.sprint && card != null)
            for (var i = 0; i < (card['terms'] as List).length; i++) ...[
              _SprintRefereeTerm(
                term: (card['terms'] as List)[i].cast<String, dynamic>(),
                index: i,
                marked: (state['marked'] as List).contains(i),
                disqualified: (state['disqualified'] as List).contains(i),
                enabled: _service.status == RefereeConnectionStatus.connected,
                onAction: (action) => _service.sendAction(switch (action) {
                  'mark_term_correct' => 'review_term_correct',
                  'disqualify_term' => 'review_term_disqualified',
                  _ => 'review_term_pending',
                }, term: i),
              ),
              const SizedBox(height: 8),
            ],
          if (game == GameKind.forbidden)
            for (var i = 0; i < (review['events'] as List).length; i++)
              _TabuuCorrectionSuggestion(
                event: (review['events'] as List)[i].cast<String, dynamic>(),
                enabled: _service.status == RefereeConnectionStatus.connected,
                onAction: (action) => _service.sendAction(action, term: i),
              ),
        ],
        const SizedBox(height: 12),
        Text(
          awaitingConfirmation
              ? 'The host reviews changes and confirms the final score.'
              : 'The host has confirmed the turn result.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SprintRefereeTerm extends StatelessWidget {
  const _SprintRefereeTerm({
    required this.term,
    required this.index,
    required this.marked,
    required this.disqualified,
    required this.enabled,
    required this.onAction,
  });

  final Map<String, dynamic> term;
  final int index;
  final bool marked;
  final bool disqualified;
  final bool enabled;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final bg = marked ? GameKind.sprint.palette.accent : Gn.card;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Gn.rLg),
        boxShadow: const [BoxShadow(color: Gn.cardLip, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            term['text'] as String,
            style: Gn.displayStyle(23, color: Gn.ink, height: 1.05),
          ),
          if (term['context'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                term['context'] as String,
                style: Gn.uiStyle(
                  12,
                  color: Gn.onCardMuted,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _DecisionButton(
                  label: marked ? 'Correct ✓' : 'Correct',
                  icon: Icons.check_rounded,
                  active: marked,
                  enabled: enabled,
                  onTap: () => onAction(
                    marked ? 'mark_term_pending' : 'mark_term_correct',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DecisionButton(
                  label: disqualified ? 'Reinstate' : 'Disqualify',
                  icon: disqualified ? Icons.undo_rounded : Icons.block_rounded,
                  active: disqualified,
                  enabled: enabled,
                  onTap: () => onAction(
                    disqualified ? 'mark_term_pending' : 'disqualify_term',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: enabled ? onTap : null,
    icon: Icon(icon, size: 18),
    label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    style: OutlinedButton.styleFrom(
      foregroundColor: active ? Gn.ink : Gn.text1,
      backgroundColor: active ? Gn.correct : Gn.surface1,
      minimumSize: const Size(0, 46),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    ),
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: Row(
      children: [
        IconSquare(
          icon: Icons.chevron_left_rounded,
          label: 'Back',
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: Gn.displayStyle(23, spacing: 0))),
      ],
    ),
  );
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.status});
  final RefereeConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      RefereeConnectionStatus.connected => (
        'Connected',
        Gn.correct,
        Icons.wifi_rounded,
      ),
      RefereeConnectionStatus.reconnecting => (
        'Reconnecting',
        Gn.warning,
        Icons.wifi_find_rounded,
      ),
      RefereeConnectionStatus.connecting => (
        'Connecting',
        Gn.warning,
        Icons.wifi_find_rounded,
      ),
      _ => ('Disconnected', Gn.violation, Icons.wifi_off_rounded),
    };
    return Pill(text: label, icon: icon, fg: color, height: 32);
  }
}

class RefereeHostReviewScreen extends StatelessWidget {
  const RefereeHostReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.controller;
    final session = controller.session!;
    final record = session.history.last;
    final connected = scope.referee.isHostConnected;
    final library = controller.library;
    return PageFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TURN REVIEW',
                  style: Gn.eyebrow(session.game.palette.accent),
                ),
              ),
              Pill(
                text: connected ? 'Referee connected' : 'Referee disconnected',
                icon: connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                fg: connected ? Gn.correct : Gn.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TeamBadge(session.teams[record.team]),
          const SizedBox(height: 8),
          Text(
            '${record.points >= 0 ? '+' : '−'}${record.points.abs()} points',
            textAlign: TextAlign.center,
            style: Gn.displayStyle(
              56,
              color: record.points < 0
                  ? Gn.violation
                  : session.game.palette.accent,
            ),
          ),
          if (scope.referee.correctionRequested)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Pill(
                text: 'Referee requested a correction',
                icon: Icons.flag_rounded,
                fg: Gn.warning,
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                if (session.game == GameKind.sprint)
                  for (var i = 0; i < 5; i++)
                    _HostSprintReviewTerm(
                      term: library.sprint[session.turn!.cardId]!.terms[i],
                      outcome: record.events
                          .firstWhere((event) => event.term == i)
                          .outcome,
                      onChanged: (outcome) =>
                          controller.reviewSprintTerm(i, outcome),
                    )
                else
                  for (var i = 0; i < record.events.length; i++) ...[
                    _HostTabuuReviewEvent(
                      label: library.forbidden[record.events[i].cardId]!.target,
                      outcome: record.events[i].outcome,
                      enabled: scope.referee.correctionRequested,
                      onChanged: (outcome) =>
                          controller.reviewTabuuEvent(i, outcome),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score is held until you confirm the review.',
            textAlign: TextAlign.center,
            style: Gn.uiStyle(13, color: Gn.text2, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          GnButton(
            label: 'Confirm turn result',
            icon: Icons.check_rounded,
            color: session.game.palette.accent,
            lip: session.game.palette.deep,
            onPressed: controller.confirmReview,
          ),
        ],
      ),
    );
  }
}

class _HostSprintReviewTerm extends StatelessWidget {
  const _HostSprintReviewTerm({
    required this.term,
    required this.outcome,
    required this.onChanged,
  });

  final SprintTerm term;
  final Outcome outcome;
  final ValueChanged<Outcome> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(term.text, style: Gn.displayStyle(20)),
        if (term.context != null)
          Text(term.context!, style: Gn.uiStyle(12, color: Gn.text2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: [
            _ReviewButton(
              label: 'Correct',
              selected: outcome == Outcome.correct,
              onTap: () => onChanged(Outcome.correct),
            ),
            _ReviewButton(
              label: 'Disqualify',
              selected: outcome == Outcome.disqualified,
              onTap: () => onChanged(Outcome.disqualified),
            ),
            _ReviewButton(
              label: 'Unanswered',
              selected: outcome == Outcome.pass,
              onTap: () => onChanged(Outcome.pass),
            ),
          ],
        ),
      ],
    ),
  );
}

class _HostTabuuReviewEvent extends StatelessWidget {
  const _HostTabuuReviewEvent({
    required this.label,
    required this.outcome,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final Outcome outcome;
  final bool enabled;
  final ValueChanged<Outcome> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Gn.displayStyle(19)),
        if (enabled) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              _ReviewButton(
                label: 'Got it',
                selected: outcome == Outcome.correct,
                onTap: () => onChanged(Outcome.correct),
              ),
              _ReviewButton(
                label: 'Pass',
                selected: outcome == Outcome.pass,
                onTap: () => onChanged(Outcome.pass),
              ),
              _ReviewButton(
                label: 'Buzz',
                selected: outcome == Outcome.violation,
                onTap: () => onChanged(Outcome.violation),
              ),
            ],
          ),
        ] else
          Text(
            'Result: ${outcome.name}',
            style: Gn.uiStyle(13, color: Gn.text2),
          ),
      ],
    ),
  );
}

class _ReviewButton extends StatelessWidget {
  const _ReviewButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: selected ? Gn.ink : Gn.text1,
      backgroundColor: selected ? Gn.correct : null,
      minimumSize: const Size(0, 40),
    ),
    child: Text(label),
  );
}

class _TabuuCorrectionSuggestion extends StatelessWidget {
  const _TabuuCorrectionSuggestion({
    required this.event,
    required this.enabled,
    required this.onAction,
  });

  final Map<String, dynamic> event;
  final bool enabled;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Gn.surface1,
      borderRadius: BorderRadius.circular(Gn.rMd),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(event['label'] as String, style: Gn.displayStyle(19)),
        Text(
          'Recorded: ${event['outcome']}',
          style: Gn.uiStyle(12, color: Gn.text2),
        ),
        if (enabled)
          Wrap(
            spacing: 6,
            children: [
              _ReviewButton(
                label: 'Got it',
                selected: false,
                onTap: () => onAction('review_tabuu_correct'),
              ),
              _ReviewButton(
                label: 'Pass',
                selected: false,
                onTap: () => onAction('review_tabuu_pass'),
              ),
              _ReviewButton(
                label: 'Buzz',
                selected: false,
                onTap: () => onAction('review_tabuu_buzz'),
              ),
            ],
          ),
      ],
    ),
  );
}
