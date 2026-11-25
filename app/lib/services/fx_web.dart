import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'package:web/web.dart' as web;

import 'fx.dart';

/// Web implementation: synthesised Web Audio cues (no audio files to cache),
/// navigator.vibrate and the Screen Wake Lock API.
class PlatformFx implements Fx {
  web.AudioContext? _ctx;
  web.WakeLockSentinel? _lock;
  bool _wantAwake = false;
  bool _listening = false;

  @override
  bool muted = false;
  @override
  bool hapticsEnabled = true;

  @override
  void unlock() {
    try {
      _ctx ??= web.AudioContext();
      if (_ctx!.state == 'suspended') _ctx!.resume();
    } catch (_) {}
  }

  void _tone(
    double freq,
    double start,
    double dur, {
    String type = 'sine',
    double gain = 0.18,
  }) {
    final ctx = _ctx;
    if (ctx == null) return;
    final t0 = ctx.currentTime + start;
    final osc = ctx.createOscillator()
      ..type = type
      ..frequency.value = freq;
    final g = ctx.createGain();
    g.gain
      ..setValueAtTime(0.0001, t0)
      ..exponentialRampToValueAtTime(gain, t0 + 0.012)
      ..exponentialRampToValueAtTime(0.0001, t0 + dur);
    osc.connect(g);
    g.connect(ctx.destination);
    osc.start(t0);
    osc.stop(t0 + dur + 0.02);
  }

  @override
  void play(Cue cue) {
    if (muted) return;
    try {
      unlock();
      switch (cue) {
        case Cue.tick:
          _tone(1046, 0, 0.06, gain: 0.12);
        case Cue.start:
          _tone(660, 0, 0.09);
          _tone(990, 0.08, 0.14);
        case Cue.correct:
          _tone(784, 0, 0.09);
          _tone(1175, 0.07, 0.16);
        case Cue.pass:
          _tone(330, 0, 0.1, gain: 0.12);
        case Cue.buzz:
          _tone(150, 0, 0.28, type: 'square', gain: 0.12);
        case Cue.wrong:
          _tone(311, 0, 0.12, type: 'triangle');
          _tone(233, 0.1, 0.2, type: 'triangle');
        case Cue.reveal:
          _tone(523, 0, 0.1);
          _tone(659, 0.08, 0.1);
          _tone(784, 0.16, 0.18);
        case Cue.timeUp:
          for (var i = 0; i < 3; i++) {
            _tone(220, i * 0.22, 0.18, type: 'square', gain: 0.14);
          }
        case Cue.allFive:
          for (final (i, f) in [523.0, 659.0, 784.0, 1046.0].indexed) {
            _tone(f, i * 0.09, 0.2);
          }
      }
    } catch (_) {}
  }

  @override
  void vibrate(List<int> pattern) {
    try {
      web.window.navigator.vibrate(pattern.map((e) => e.toJS).toList().toJS);
    } catch (_) {}
  }

  @override
  void keepAwake(bool on) {
    _wantAwake = on;
    if (!_listening) {
      _listening = true;
      // The browser drops the lock when the tab is hidden; re-acquire on return.
      web.document.addEventListener(
        'visibilitychange',
        ((web.Event _) {
          if (web.document.visibilityState == 'visible' && _wantAwake)
            _acquire();
        }).toJS,
      );
    }
    on ? _acquire() : _release();
  }

  Future<void> _acquire() async {
    if (_lock != null && !_lock!.released) return;
    try {
      final lock = await web.window.navigator.wakeLock.request('screen').toDart;
      // The turn may have ended while the request was pending.
      if (!_wantAwake) {
        lock.release();
        return;
      }
      _lock = lock;
    } catch (_) {}
  }

  ValueNotifier<bool>? _fullscreen;

  @override
  bool get fullscreenSupported {
    try {
      return web.document.fullscreenEnabled;
    } catch (_) {
      return false;
    }
  }

  @override
  ValueListenable<bool> get fullscreen {
    if (_fullscreen == null) {
      _fullscreen = ValueNotifier(web.document.fullscreenElement != null);
      // Track exits made by the browser (Esc, Android back) as well as ours.
      web.document.addEventListener(
        'fullscreenchange',
        ((web.Event _) =>
                _fullscreen!.value = web.document.fullscreenElement != null)
            .toJS,
      );
    }
    return _fullscreen!;
  }

  @override
  void setFullscreen(bool on) {
    try {
      final isOn = web.document.fullscreenElement != null;
      if (on && !isOn) {
        web.document.documentElement?.requestFullscreen().toDart.catchError(
          (_) => null,
        );
      } else if (!on && isOn) {
        web.document.exitFullscreen().toDart.catchError((_) => null);
      }
    } catch (_) {}
  }

  void _release() {
    final l = _lock;
    _lock = null;
    try {
      l?.release();
    } catch (_) {}
  }
}
