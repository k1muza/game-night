import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'fx.dart';

class PlatformFx implements Fx {
  PlatformFx() {
    for (final player in _players.values) {
      player.setReleaseMode(ReleaseMode.stop);
    }
  }

  final Map<Cue, AudioPlayer> _players = {
    for (final cue in Cue.values) cue: AudioPlayer(),
  };

  @override
  bool muted = false;

  @override
  bool hapticsEnabled = true;

  @override
  void unlock() {}

  @override
  void play(Cue cue) {
    if (muted) return;
    final name = switch (cue) {
      Cue.tick => 'tick',
      Cue.correct => 'correct',
      Cue.pass => 'pass',
      Cue.buzz => 'buzz',
      Cue.timeUp => 'timeUp',
      Cue.allFive => 'allFive',
      Cue.reveal => 'reveal',
      Cue.wrong => 'wrong',
      Cue.start => 'start',
    };
    _players[cue]?.stop();
    _players[cue]?.play(AssetSource('audio/$name.wav'), volume: 0.8);
  }

  @override
  void vibrate(List<int> pattern) {
    if (!hapticsEnabled) return;
    if (pattern.length >= 3) {
      HapticFeedback.heavyImpact();
    } else if (pattern.length == 1) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
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
