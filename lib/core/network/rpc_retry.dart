import 'dart:async';
import 'dart:io';

import 'package:postgrest/postgrest.dart';

/// Retries transient RPC/network failures (not business 4xx errors).
Future<T> withRpcRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 2,
}) async {
  Object? lastError;
  StackTrace? lastStack;

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e, st) {
      lastError = e;
      lastStack = st;
      if (!_isRetryable(e) || attempt >= maxAttempts) {
        Error.throwWithStackTrace(e, st);
      }
      await Future<void>.delayed(Duration(milliseconds: 200 * attempt));
    }
  }

  // Unreachable — satisfies analyzer.
  Error.throwWithStackTrace(lastError!, lastStack!);
}

bool _isRetryable(Object error) {
  if (error is TimeoutException || error is SocketException) {
    return true;
  }
  if (error is PostgrestException) {
    final code = int.tryParse(error.code ?? '');
    if (code != null && code >= 500) return true;
    final message = error.message.toLowerCase();
    if (message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network')) {
      return true;
    }
    return false;
  }
  return false;
}
