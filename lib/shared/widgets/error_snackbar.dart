import 'package:flutter/material.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/monitoring/error_reporter.dart';

/// Mostra errore user-friendly e opzionalmente lo invia a Sentry.
Future<void> showUserError(
  BuildContext context,
  Object error, {
  StackTrace? stackTrace,
  Map<String, String>? tags,
}) async {
  await ErrorReporter.capture(error, stackTrace: stackTrace, tags: tags);
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(userFacingMessage(error, l10n: context.l10n))),
  );
}
