import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../config/sentry_config.dart';

/// Safe Sentry scope helpers — no PII (no room codes, nicknames, IDs).
abstract final class SentryScope {
  static String get platformTag {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  static void applyRoomContext(
    Scope scope, {
    String? roomPhase,
    required bool isFacilitator,
  }) {
    if (roomPhase != null) {
      scope.setTag('room_phase', roomPhase);
    }
    scope.setTag('is_facilitator', isFacilitator.toString());
    scope.setTag('platform', platformTag);
    if (SentryConfig.gitSha.isNotEmpty) {
      scope.setTag('git_sha', SentryConfig.gitSha);
    }
  }
}
