import 'fx.dart';

class PlatformFx implements Fx {
  @override
  bool muted = false;
  @override
  void unlock() {}
  @override
  void play(Cue cue) {}
  @override
  void vibrate(List<int> pattern) {}
  @override
  void keepAwake(bool on) {}
}
