// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

abstract final class WebPushService {
  static bool get isSupported =>
      html.window.navigator.serviceWorker != null &&
      const String.fromEnvironment('VAPID_PUBLIC_KEY').isNotEmpty;

  static Future<bool> subscribeAndRegister({
    required String participantId,
    required Future<void> Function(Map<String, dynamic> subscription) register,
  }) async {
    final vapidKey = const String.fromEnvironment('VAPID_PUBLIC_KEY');
    if (vapidKey.isEmpty) return false;

    final permission = await html.Notification.requestPermission();
    if (permission != 'granted') return false;

    final registration = await html.window.navigator.serviceWorker!.ready;
    final subscription = await registration.pushManager!.subscribe(
      {'userVisibleOnly': true, 'applicationServerKey': vapidKey},
    );

    await register({
      'endpoint': subscription.endpoint ?? '',
    });
    return true;
  }

  static Future<void> unsubscribe() async {
    final registration = await html.window.navigator.serviceWorker?.ready;
    final sub = await registration?.pushManager?.getSubscription();
    await sub?.unsubscribe();
  }
}
