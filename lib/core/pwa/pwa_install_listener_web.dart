import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/foundation.dart';

/// Web: intercetta `beforeinstallprompt` per installazione PWA.
class PwaInstallListener {
  PwaInstallListener._();
  static final PwaInstallListener instance = PwaInstallListener._();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);
  Object? _deferredPrompt;

  void init() {
    html.window.addEventListener('beforeinstallprompt', (html.Event event) {
      event.preventDefault();
      _deferredPrompt = event;
      canInstall.value = true;
    });

    html.window.addEventListener('appinstalled', (_) {
      _deferredPrompt = null;
      canInstall.value = false;
    });
  }

  Future<void> promptInstall() async {
    final prompt = _deferredPrompt;
    if (prompt == null) return;

    await js_util.promiseToFuture<void>(
      js_util.callMethod(prompt, 'prompt', []),
    );
    await js_util.promiseToFuture<Object?>(
      js_util.callMethod(prompt, 'userChoice', []),
    );

    _deferredPrompt = null;
    canInstall.value = false;
  }
}
