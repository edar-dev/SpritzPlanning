import 'package:postgrest/postgrest.dart';

import '../constants/app_strings.dart';

/// Messaggio localizzato per l'utente, senza stack trace.
String userFacingMessage(Object error) {
  if (error is PostgrestException) {
    final message = error.message.trim();
    if (message.isNotEmpty) return message;
    return AppStrings.genericError;
  }

  final text = error.toString().trim();
  if (text.startsWith('Exception: ')) {
    final inner = text.substring('Exception: '.length).trim();
    if (inner.isNotEmpty) return inner;
  }

  if (text.startsWith('Instance of ')) {
    return AppStrings.genericError;
  }

  if (text.isNotEmpty &&
      !text.contains('StackTrace') &&
      text.length < 200) {
    return text;
  }

  return AppStrings.genericError;
}
