import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';

/// Invio errori e breadcrumb a Sentry (no-op se DSN assente).
abstract final class ErrorReporter {
  static Future<void> capture(
    Object error, {
    StackTrace? stackTrace,
    Map<String, String>? tags,
  }) async {
    if (!SentryConfig.isConfigured) return;

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        tags?.forEach(scope.setTag);
      },
    );
  }

  static void breadcrumb(
    String message, {
    String category = 'app',
    SentryLevel level = SentryLevel.info,
  }) {
    if (!SentryConfig.isConfigured) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level,
      ),
    );
  }
}
