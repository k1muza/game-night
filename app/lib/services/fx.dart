import 'package:flutter/foundation.dart';

import 'fx_stub.dart'
    if (dart.library.io) 'fx_native.dart'
    if (dart.library.js_interop) 'fx_web.dart'
    as impl;

enum Cue { tick, correct, pass, buzz, timeUp, allFive, reveal, wrong, start }

/// Sound, vibration and screen wake lock. All optional: every call is a no-op
/// where the platform doesn't support it (e.g. iOS has no vibration).
abstract class Fx {
  factory Fx() = impl.PlatformFx;

  bool get muted;
  set muted(bool v);
  bool get hapticsEnabled;
  set hapticsEnabled(bool v);

  /// Must be called from a user gesture before sounds can play on mobile browsers.
  void unlock();
  void play(Cue cue);
  void vibrate(List<int> pattern);
  void keepAwake(bool on);

  /// Fullscreen (web Fullscreen API). Not available on iPhone Safari.
  bool get fullscreenSupported;

  /// Live fullscreen state, including exits made by the browser or system.
  ValueListenable<bool> get fullscreen;

  /// Must be called from a user gesture.
  void setFullscreen(bool on);
}

/// Silent implementation for tests.
class SilentFx implements Fx {
  @override
  bool muted = false;
  @override
  bool hapticsEnabled = true;
  final List<Cue> played = [];
  bool awake = false;
  @override
  void unlock() {}
  @override
  void play(Cue cue) => played.add(cue);
  @override
  void vibrate(List<int> pattern) {}
  @override
  void keepAwake(bool on) => awake = on;
  @override
  bool fullscreenSupported = true;
  @override
  final ValueNotifier<bool> fullscreen = ValueNotifier(false);
  @override
  void setFullscreen(bool on) => fullscreen.value = on;
}
