import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:postgrest/postgrest.dart';
import 'package:spritz_planning/core/network/rpc_retry.dart';

void main() {
  test('withRpcRetry succeeds on first attempt', () async {
    var calls = 0;
    final result = await withRpcRetry(() async {
      calls++;
      return 'ok';
    });
    expect(result, 'ok');
    expect(calls, 1);
  });

  test('withRpcRetry retries on SocketException then succeeds', () async {
    var calls = 0;
    final result = await withRpcRetry(() async {
      calls++;
      if (calls == 1) throw const SocketException('connection reset');
      return 42;
    });
    expect(result, 42);
    expect(calls, 2);
  });

  test('withRpcRetry does not retry Postgrest 400', () async {
    var calls = 0;
    expect(
      () => withRpcRetry(() async {
        calls++;
        throw const PostgrestException(message: 'bad', code: '400');
      }),
      throwsA(isA<PostgrestException>()),
    );
    expect(calls, 1);
  });

  test('withRpcRetry retries Postgrest 500', () async {
    var calls = 0;
    await expectLater(
      withRpcRetry(() async {
        calls++;
        throw const PostgrestException(message: 'server', code: '500');
      }),
      throwsA(isA<PostgrestException>()),
    );
    expect(calls, 2);
  });
}
