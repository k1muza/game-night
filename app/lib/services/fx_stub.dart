import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'fx.dart';

class PlatformFx implements Fx {
  @override
  bool muted = false;
  @override
  bool hapticsEnabled = true;
  @override
  void unlock() {}
  @override
  void play(Cue cue) {
    if (muted) return;
    final sound = switch (cue) {
      Cue.correct || Cue.allFive || Cue.reveal => SystemSoundType.click,
      Cue.wrong || Cue.pass || Cue.buzz => SystemSoundType.alert,
      Cue.tick || Cue.start || Cue.timeUp => SystemSoundType.click,
    };
    SystemSound.play(sound);
  }

  @override
  void vibrate(List<int> pattern) {
    HapticFeedback.heavyImpact();
  }

  @override
  void keepAwake(bool on) {
    WakelockPlus.toggle(enable: on);
  }

  @override
  bool fullscreenSupported = false;

  @override
  final ValueNotifier<bool> fullscreen = ValueNotifier(false);

  @override
  void setFullscreen(bool on) {}
}
