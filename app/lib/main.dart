import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'model/cards.dart';
import 'services/fx.dart';
import 'services/local_referee.dart';
import 'session/session.dart';
import 'session/session_controller.dart';
import 'session/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Expose the accessibility tree to screen readers (and browser tests) from
    // the start instead of waiting for the hidden "enable accessibility" button.
    SemanticsBinding.instance.ensureSemantics();
  }
  final results = await Future.wait([
    ContentLibrary.load(rootBundle),
    PrefsSessionStore.open(),
  ]);
  final library = results[0] as ContentLibrary;
  final store = results[1] as PrefsSessionStore;
  final controller = SessionController(library: library, store: store)
    ..restore();
  // A process restart invalidates the ephemeral pairing token and embedded
  // server. Preserve the session but resume it safely as a local game.
  if (controller.session?.config.mode == PlayMode.referee) {
    controller.switchToClassic();
  }
  runApp(
    GameNightApp(
      controller: controller,
      fx: Fx(),
      store: store,
      referee: createLocalRefereeService(controller),
    ),
  );
}
