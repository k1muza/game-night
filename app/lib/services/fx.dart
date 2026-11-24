import 'fx_stub.dart' if (dart.library.js_interop) 'fx_web.dart' as impl;

enum Cue { tick, correct, pass, buzz, timeUp, allFive, reveal, wrong, start }

/// Sound, vibration and screen wake lock. All optional: every call is a no-op
/// where the platform doesn't support it (e.g. iOS has no vibration).
abstract class Fx {
  factory Fx() = impl.PlatformFx;

  bool get muted;
  set muted(bool v);

  /// Must be called from a user gesture before sounds can play on mobile browsers.
  void unlock();
  void play(Cue cue);
  void vibrate(List<int> pattern);
  void keepAwake(bool on);
}

/// Silent implementation for tests.
class SilentFx implements Fx {
  @override
  bool muted = false;
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
}
