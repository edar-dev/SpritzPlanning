import 'package:postgrest/postgrest.dart';

import '../l10n/l10n_extensions.dart';

/// Messaggio localizzato per l'utente, senza stack trace.
String userFacingMessage(Object error, {AppLocalizations? l10n}) {
  final generic = l10n?.genericError ?? 'Qualcosa è andato storto al bancone';

  if (error is PostgrestException) {
    final message = error.message.trim();
    if (message.contains('Rate limit') || message.contains('rate limit')) {
      return l10n?.rateLimitError ??
          'Troppe richieste. Attendi un momento e riprova.';
    }
    if (message.isNotEmpty) return message;
    final code = error.code;
    if (code == '429') {
      return l10n?.rateLimitError ??
          'Troppe richieste. Attendi un momento e riprova.';
    }
    return generic;
  }

  final text = error.toString().trim();
  if (text.startsWith('Exception: ')) {
    final inner = text.substring('Exception: '.length).trim();
    if (inner.isNotEmpty) return inner;
  }

  if (text.startsWith('Instance of ')) {
    return generic;
  }

  if (text.isNotEmpty &&
      !text.contains('StackTrace') &&
      text.length < 200) {
    return text;
  }

  return generic;
}
