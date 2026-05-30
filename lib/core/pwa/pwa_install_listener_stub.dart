import 'package:flutter/foundation.dart';

/// Stub PWA install (mobile/desktop native).
class PwaInstallListener {
  PwaInstallListener._();
  static final PwaInstallListener instance = PwaInstallListener._();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);

  void init() {}

  Future<void> promptInstall() async {}
}
