abstract final class WebPushService {
  static bool get isSupported => false;

  static Future<bool> subscribeAndRegister({
    required String participantId,
    required Future<void> Function(Map<String, dynamic> subscription) register,
  }) async {
    return false;
  }

  static Future<void> unsubscribe() async {}
}
