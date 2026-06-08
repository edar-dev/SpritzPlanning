enum BrowserNotificationPermission { denied, granted, defaultState }

Future<BrowserNotificationPermission> requestBrowserNotificationPermission() async {
  return BrowserNotificationPermission.denied;
}

void showBrowserNotification({required String title, String? body}) {}

void notifyVotingStarted({required String title, String? body}) {}

bool get isDocumentHidden => false;
