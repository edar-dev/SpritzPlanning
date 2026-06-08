import 'package:postgrest/postgrest.dart';

import '../l10n/l10n_extensions.dart';

/// Messaggio localizzato per l'utente, senza stack trace.
String userFacingMessage(Object error, {AppLocalizations? l10n}) {
  final generic = l10n?.genericError ?? 'Qualcosa è andato storto al bancone';

  if (error is PostgrestException) {
    final message = error.message.trim();
    final mapped = mapKnownRpcMessage(message, l10n);
    if (mapped != null) return mapped;
    if (message.contains('Rate limit') || message.contains('rate limit')) {
      return l10n?.rateLimitError ??
          'Troppe richieste. Attendi un momento e riprova.';
    }
    if (message.isNotEmpty && !_looksLikeSqlError(message)) return message;
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
    final mapped = mapKnownRpcMessage(inner, l10n);
    if (mapped != null) return mapped;
    if (inner.isNotEmpty && !_looksLikeSqlError(inner)) return inner;
  }

  if (text.startsWith('Instance of ')) {
    return generic;
  }

  if (text.isNotEmpty &&
      !text.contains('StackTrace') &&
      text.length < 200 &&
      !_looksLikeSqlError(text)) {
    return text;
  }

  return generic;
}

/// Maps known Postgres RPC exception messages to localized copy (#125).
String? mapKnownRpcMessage(String message, AppLocalizations? l10n) {
  if (message.isEmpty) return null;

  if (message.contains('Nickname già presente')) {
    return l10n?.errorNicknameTaken ??
        'Questo nickname è già al bancone. Esci dall\'altra sessione o attendi ~2 min.';
  }
  if (message.contains('Locale non trovato')) {
    return l10n?.errorRoomNotFound ??
        'Locale chiuso. Chiedi un nuovo codice al barman.';
  }
  if (message.contains('Solo il barman') ||
      message.contains('Solo il barman può')) {
    return l10n?.errorNotFacilitator ??
        'Solo il barman può fare questa azione.';
  }
  if (message.contains('Valore voto non valido')) {
    return l10n?.errorInvalidVote ??
        'Quella dose non è nel menu della stanza.';
  }
  if (message.contains('PIN non valido')) {
    return l10n?.errorInvalidPin ?? 'PIN non valido per questo locale.';
  }
  if (message.contains('Gli osservatori non possono votare')) {
    return l10n?.observerCannotVote;
  }
  if (message.contains('Votazione non attiva')) {
    return l10n?.errorVotingNotActive ??
        'La votazione non è attiva in questo momento.';
  }
  if (message.contains('Voti già rivelati')) {
    return l10n?.errorVotesAlreadyRevealed ??
        'I voti sono già stati rivelati.';
  }
  if (message.contains('Troppe richieste') ||
      message.contains('Troppi locali creati')) {
    return l10n?.rateLimitError;
  }

  return null;
}

bool _looksLikeSqlError(String message) {
  final lower = message.toLowerCase();
  return lower.contains('pgrst') ||
      lower.contains('postgres') ||
      lower.contains('sqlstate') ||
      lower.startsWith('raise exception');
}
