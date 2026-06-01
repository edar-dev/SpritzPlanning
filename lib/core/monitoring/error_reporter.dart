import 'package:postgrest/postgrest.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';
import 'sentry_scope.dart';

/// Invio errori e breadcrumb a Sentry (no-op se DSN assente).
abstract final class ErrorReporter {
  static Future<void> capture(
    Object error, {
    StackTrace? stackTrace,
    Map<String, String>? tags,
    String? roomPhase,
    bool? isFacilitator,
  }) async {
    if (!SentryConfig.isConfigured) return;

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        tags?.forEach(scope.setTag);
        if (roomPhase != null || isFacilitator != null) {
          SentryScope.applyRoomContext(
            scope,
            roomPhase: roomPhase,
            isFacilitator: isFacilitator ?? false,
          );
        }
      },
    );
  }

  static void breadcrumbRpcFailure(String functionName, Object error) {
    if (!SentryConfig.isConfigured) return;
    final code = error is PostgrestException ? error.code : 'unknown';
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'rpc_failed:$functionName',
        category: 'rpc',
        level: SentryLevel.warning,
        data: {'code': code ?? 'unknown'},
      ),
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
