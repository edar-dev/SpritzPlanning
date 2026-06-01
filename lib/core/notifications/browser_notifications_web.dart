// Web-only implementation loaded via conditional export.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

enum BrowserNotificationPermission { denied, granted, defaultState }

BrowserNotificationPermission _mapPermission(String? value) {
  return switch (value) {
    'granted' => BrowserNotificationPermission.granted,
    'denied' => BrowserNotificationPermission.denied,
    _ => BrowserNotificationPermission.defaultState,
  };
}

Future<BrowserNotificationPermission> requestBrowserNotificationPermission() async {
  final permission = await html.Notification.requestPermission();
  return _mapPermission(permission);
}

void showBrowserNotification({required String title, String? body}) {
  if (html.document.hidden != true) return;
  if (html.Notification.permission != 'granted') return;
  html.Notification(title, body: body);
}

bool get isDocumentHidden => html.document.hidden ?? false;
