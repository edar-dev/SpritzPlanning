import 'package:flutter_test/flutter_test.dart';
import 'package:postgrest/postgrest.dart';
import 'package:spritz_planning/core/errors/user_facing_error.dart';

void main() {
  test('userFacingMessage returns PostgrestException message', () {
    const error = PostgrestException(message: 'Locale non trovato', code: '400');
    expect(userFacingMessage(error), 'Locale non trovato');
  });

  test('userFacingMessage strips Exception prefix', () {
    expect(
      userFacingMessage(Exception('Nickname troppo corto')),
      'Nickname troppo corto',
    );
  });

  test('userFacingMessage maps rate limit', () {
    const error = PostgrestException(
      message: 'Rate limit exceeded',
      code: '429',
    );
    expect(
      userFacingMessage(error),
      contains('Troppe richieste'),
    );
  });

  test('userFacingMessage falls back to generic', () {
    expect(
      userFacingMessage(Object()),
      'Qualcosa è andato storto al bancone',
    );
  });
}
