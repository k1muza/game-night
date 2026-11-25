import '../session/session_controller.dart';
import 'local_referee_types.dart';
import 'local_referee_stub.dart'
    if (dart.library.io) 'local_referee_io.dart'
    as platform;

export 'local_referee_types.dart';

LocalRefereeService createLocalRefereeService(SessionController controller) =>
    platform.createLocalRefereeService(controller);
