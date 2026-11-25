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
  String sendAction(String action, {int? term, String? messageId}) =>
      throw UnsupportedError(
        'Local referee networking is unavailable on this platform.',
      );
  @override
  Future<void> stop() async {}
  @override
  Future<void> takeOverClassic() async {}
  @override
  void pauseForBackground() {}
}
