import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'model/game_kind.dart';
import 'services/fx.dart';
import 'services/local_referee.dart';
import 'session/session.dart';
import 'session/session_controller.dart';
import 'session/store.dart';
import 'theme/tokens.dart';
import 'ui/screens/final_results.dart';
import 'ui/screens/handover.dart';
import 'ui/screens/home.dart';
import 'ui/screens/local_referee.dart';
import 'ui/screens/play_charades.dart';
import 'ui/screens/play_forbidden.dart';
import 'ui/screens/play_sprint.dart';
import 'ui/screens/play_trivia.dart';
import 'ui/screens/setup.dart';
import 'ui/screens/turn_results.dart';
import 'ui/widgets/common.dart';

/// Gives every screen access to the controller, effects and settings store.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.controller,
    required this.fx,
    required this.store,
    required this.referee,
    required this.nav,
    required super.child,
  });
  final SessionController controller;
  final Fx fx;
  final SessionStore store;
  final LocalRefereeService referee;
  final AppNav nav;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  static AppScope read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope old) => false;
}

enum AppRoute { home, setup, hostPairing, joinReferee, referee, session }

/// Small top-level navigation for game and pairing flows.
class AppNav extends ChangeNotifier {
  AppRoute route = AppRoute.home;
  GameKind setupGame = GameKind.sprint;

  void home() => _go(AppRoute.home);
  void setup(GameKind g) {
    setupGame = g;
    _go(AppRoute.setup);
  }

  void session() => _go(AppRoute.session);
  void hostPairing() => _go(AppRoute.hostPairing);
  void joinReferee() => _go(AppRoute.joinReferee);
  void referee() => _go(AppRoute.referee);

  void _go(AppRoute r) {
    route = r;
    notifyListeners();
  }
}

class GameNightApp extends StatefulWidget {
  const GameNightApp({
    super.key,
    required this.controller,
    required this.fx,
    required this.store,
    this.referee,
  });
  final SessionController controller;
  final Fx fx;
  final SessionStore store;
  final LocalRefereeService? referee;

  @override
  State<GameNightApp> createState() => _GameNightAppState();
}

class _GameNightAppState extends State<GameNightApp>
    with WidgetsBindingObserver {
  final nav = AppNav();
  late final LocalRefereeService referee =
      widget.referee ?? createLocalRefereeService(widget.controller);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    widget.fx.muted = widget.store.flag('muted');
    widget.fx.hapticsEnabled = !widget.store.flag('hapticsDisabled');
    final phase = widget.controller.session?.phase;
    // A refresh mid-turn (or on the final screen) drops you straight back in;
    // otherwise Home shows a prominent Resume card.
    if (phase == Phase.playing || phase == Phase.gameResults)
      nav.route = AppRoute.session;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.tick();
      widget.fx.keepAwake(widget.controller.session?.phase == Phase.playing);
    } else if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      widget.controller.store.saveSession(widget.controller.session);
      referee.pauseForBackground();
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden ||
          state == AppLifecycleState.detached) {
        widget.fx.keepAwake(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      fx: widget.fx,
      store: widget.store,
      referee: referee,
      nav: nav,
      child: MaterialApp(
        title: 'Game Night',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (context, child) {
          // Keep layouts intact while still honouring larger text settings.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
            ),
            child: child!,
          );
        },
        home: _Shell(
          nav: nav,
          controller: widget.controller,
          fx: widget.fx,
          referee: referee,
        ),
      ),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({
    required this.nav,
    required this.controller,
    required this.fx,
    required this.referee,
  });
  final AppNav nav;
  final SessionController controller;
  final Fx fx;
  final LocalRefereeService referee;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  _Snapshot? _prev;

  /// History length at which a turn ended *live* (not via restore), so the
  /// "Time!" splash is shown only to people who just played.
  int? liveEndedAt;

  @override
  void initState() {
    super.initState();
    _prev = _Snapshot.of(widget.controller.session);
    widget.controller.addListener(_onChange);
    widget.referee.addListener(_rebuild);
    widget.nav.addListener(_rebuild);
    _syncWakeLock();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    widget.referee.removeListener(_rebuild);
    widget.nav.removeListener(_rebuild);
    widget.fx.keepAwake(false);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _repairRefereePairing() async {
    try {
      await widget.referee.startHost();
      if (mounted) widget.nav.hostPairing();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not restart pairing: $error')),
        );
      }
    }
  }

  void _syncWakeLock() => widget.fx.keepAwake(
    widget.controller.session?.phase == Phase.playing &&
        widget.nav.route == AppRoute.session,
  );

  void _onChange() {
    final s = widget.controller.session;
    final now = _Snapshot.of(s);
    final prev = _prev;
    _prev = now;
    if (s != null &&
        prev != null &&
        prev.sessionCreatedAt == now.sessionCreatedAt)
      _cues(prev, now, s);
    _syncWakeLock();
    setState(() {});
  }

  void _cues(_Snapshot a, _Snapshot b, Session s) {
    final fx = widget.fx;
    if (a.phase == Phase.playing &&
        (b.phase == Phase.turnResults || b.phase == Phase.turnReview)) {
      liveEndedAt = s.history.length;
      switch (s.turn?.ended) {
        case EndReason.time:
          fx.play(Cue.timeUp);
          fx.vibrate([300, 120, 300]);
        case EndReason.allFound:
          fx.play(Cue.allFive);
          fx.vibrate([60, 60, 60, 60, 160]);
        default:
          break;
      }
      return;
    }
    if (b.phase != Phase.playing) return;
    if (b.marked > a.marked) fx.play(Cue.correct);
    if (b.events > a.events && s.turn!.events.isNotEmpty) {
      final last = s.turn!.events.last;
      switch (last.outcome) {
        case Outcome.correct:
          fx.play(s.game == GameKind.trivia ? Cue.reveal : Cue.correct);
        case Outcome.pass:
          fx.play(Cue.pass);
        case Outcome.violation:
          fx.play(Cue.buzz);
          fx.vibrate([180]);
        case Outcome.wrong:
          fx.play(Cue.wrong);
        case Outcome.timeout:
          fx.play(Cue.timeUp);
          fx.vibrate([250]);
        case Outcome.disqualified:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final s = c.session;
    final route = (widget.nav.route == AppRoute.session && s == null)
        ? AppRoute.home
        : widget.nav.route;
    final Widget screen = switch (route) {
      AppRoute.home => const HomeScreen(),
      AppRoute.setup => SetupScreen(game: widget.nav.setupGame),
      AppRoute.hostPairing => const HostPairingScreen(),
      AppRoute.joinReferee => const JoinRefereeScreen(),
      AppRoute.referee => const RefereeGameScreen(),
      AppRoute.session => switch (s!.phase) {
        Phase.ready => HandoverScreen(
          key: ValueKey('ready-${s.history.length}'),
        ),
        Phase.playing => switch (s.game) {
          GameKind.sprint => const SprintPlayScreen(),
          GameKind.charades => const CharadesPlayScreen(),
          GameKind.trivia => const TriviaPlayScreen(),
          GameKind.forbidden => const ForbiddenPlayScreen(),
        },
        Phase.turnReview => const RefereeHostReviewScreen(),
        Phase.turnResults => TurnEndFlow(
          key: ValueKey('end-${s.history.length}'),
          showSplash: liveEndedAt == s.history.length,
        ),
        Phase.gameResults => const FinalResultsScreen(),
      },
    };
    final key = route == AppRoute.session
        ? 'session-${s!.phase.name}-${s.history.length}'
        : route.name;
    final remoteSession =
        s?.config.mode == PlayMode.referee && route == AppRoute.session;
    final needsFallback =
        remoteSession &&
        s?.phase != Phase.gameResults &&
        !widget.referee.isHostConnected;
    return PopScope(
      canPop: route == AppRoute.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (s?.phase == Phase.playing) c.pause();
          widget.nav.home();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : Gn.quick,
              // Guard screens whose main button sits where the previous screen's
              // did. Play screens aren't guarded: the 3-2-1 countdown already
              // separates them, and the first guess can come instantly.
              child: route == AppRoute.session && s!.phase != Phase.playing
                  ? InputGuard(key: ValueKey(key), child: screen)
                  : KeyedSubtree(key: ValueKey(key), child: screen),
            ),
            if (needsFallback)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Gn.surface1,
                      borderRadius: BorderRadius.circular(Gn.rLg),
                      border: Border.all(color: Gn.warning, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Gn.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Referee disconnected. The turn is paused.',
                                style: Gn.uiStyle(
                                  13,
                                  color: Gn.text1,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _repairRefereePairing,
                              child: const Text('Re-pair'),
                            ),
                            TextButton(
                              onPressed: widget.referee.takeOverClassic,
                              child: const Text('Continue in Classic'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Snapshot {
  _Snapshot(this.phase, this.events, this.marked, this.sessionCreatedAt);
  final Phase? phase;
  final int events;
  final int marked;
  final int? sessionCreatedAt;

  static _Snapshot of(Session? s) => _Snapshot(
    s?.phase,
    s?.turn?.events.length ?? 0,
    s?.turn?.marked.length ?? 0,
    s?.createdAt,
  );
}

/// Rebuilds every frame while a turn's clock runs, settles expiry via
/// [SessionController.tick], and plays the 1 Hz warning tick in the last 5 s.
class TurnClock extends StatefulWidget {
  const TurnClock({super.key, required this.builder});
  final Widget Function(BuildContext context, int remainingMs, int totalMs)
  builder;

  @override
  State<TurnClock> createState() => _TurnClockState();
}

class _TurnClockState extends State<TurnClock>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final AppScope _scope = context
      .getInheritedWidgetOfExactType<AppScope>()!;
  int _lastSecond = -1;
  int _lastRem = -1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _scope.controller.addListener(_onControllerChange);
    _syncTicker();
  }

  /// The ticker only runs while the clock is actually counting down, so a
  /// paused phone or a Trivia explanation doesn't repaint every frame.
  bool get _counting {
    final t = _scope.controller.session?.turn;
    return t != null && !t.paused && t.deadlineMs != null;
  }

  void _syncTicker() {
    if (_counting && !_ticker.isActive) _ticker.start();
    if (!_counting && _ticker.isActive) _ticker.stop();
  }

  void _onControllerChange() {
    if (!mounted) return;
    _syncTicker();
    setState(() {});
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    final c = _scope.controller;
    c.tick();
    if (!mounted) return;
    final rem = c.remainingMs();
    final sec = (rem / 1000).ceil();
    if (sec != _lastSecond) {
      if (_lastSecond != -1 && sec >= 1 && sec <= 5 && _counting) {
        _scope.fx.play(Cue.tick);
        _scope.fx.vibrate([40]);
      }
      _lastSecond = sec;
    }
    // Repaint at most every ~50 ms of clock change; plenty for a smooth bar.
    if ((rem - _lastRem).abs() >= 50 || rem == 0) {
      _lastRem = rem;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scope.controller.removeListener(_onControllerChange);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context).controller;
    return widget.builder(context, c.remainingMs(), c.durationMs);
  }
}
