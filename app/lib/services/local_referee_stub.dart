import '../session/session_controller.dart';
import 'local_referee_types.dart';

LocalRefereeService createLocalRefereeService(SessionController controller) =>
    _UnsupportedLocalRefereeService(controller);

class _UnsupportedLocalRefereeService extends LocalRefereeService {
  _UnsupportedLocalRefereeService(super.controller);

  @override
  bool get supported => false;
  @override
  bool get isHost => false;
  @override
  bool get isHostConnected => false;
  @override
  bool get correctionRequested => false;
  @override
  RefereeConnectionStatus get status => RefereeConnectionStatus.unsupported;
  @override
  PairingDetails? get pairing => null;
  @override
  Map<String, dynamic>? get snapshot => null;
  @override
  String? get lastActionMessage => null;
  @override
  bool? get lastActionAccepted => null;
  @override
  String? get connectionError => null;

  @override
  Future<PairingDetails> startHost() => Future.error(
    UnsupportedError(
      'Local referee networking is unavailable on this platform.',
    ),
  );
  @override
  Future<void> connect(String pairingJson) => Future.error(
    UnsupportedError(
      'Local referee networking is unavailable on this platform.',
    ),
  );
  @override
  Future<void> connectManual({
    required String host,
    required int port,
    required String pairingCode,
  }) => Future.error(
    UnsupportedError(
      'Local referee networking is unavailable on this platform.',
    ),
  );
  @override
  Future<void> retryConnection() => Future.error(
    UnsupportedError(
      'Local referee networking is unavailable on this platform.',
    ),
  );
  @override
  String sendAction(
    String action, {
    required RefereeActionContext context,
    int? term,
    String? messageId,
  }) => throw UnsupportedError(
    'Local referee networking is unavailable on this platform.',
  );
  @override
  Future<void> stop() async {}
  @override
  Future<void> takeOverClassic() async {
    controller.switchToClassic();
    if (controller.session?.turn?.paused == true) controller.resume();
  }

  @override
  void acknowledgeCorrection() {}

  @override
  void pauseForBackground() {}
  @override
  Future<void> resumeFromBackground() async {}
}
