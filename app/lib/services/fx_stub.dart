import 'package:flutter/foundation.dart';

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
  @override
  bool get fullscreenSupported => false;
  @override
  final ValueNotifier<bool> fullscreen = ValueNotifier(false);
  @override
  void setFullscreen(bool on) {}
}
