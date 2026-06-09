import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgrest/postgrest.dart';
import 'package:spritz_planning/core/errors/user_facing_error.dart';
import 'package:spritz_planning/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mapKnownRpcMessage', () {
    final cases = <({String input, String? itContains, String? enContains})>[
      (
        input: 'Nickname già presente in questo locale',
        itContains: 'nickname',
        enContains: 'nickname',
      ),
      (
        input: 'Locale non trovato',
        itContains: 'codice',
        enContains: 'code',
      ),
      (
        input: 'Solo il barman può rivelare i voti',
        itContains: 'barman',
        enContains: 'barman',
      ),
      (
        input: 'Valore voto non valido',
        itContains: 'dose',
        enContains: 'dose',
      ),
      (
        input: 'PIN non valido',
        itContains: 'PIN',
        enContains: 'PIN',
      ),
      (
        input: 'Gli osservatori non possono votare',
        itContains: 'osserv',
        enContains: 'observ',
      ),
      (
        input: 'Votazione non attiva',
        itContains: 'votazione',
        enContains: 'Voting',
      ),
      (
        input: 'Voti già rivelati',
        itContains: 'rivelati',
        enContains: 'revealed',
      ),
      (
        input: 'Troppe richieste',
        itContains: 'richieste',
        enContains: 'requests',
      ),
    ];

    for (final c in cases) {
      test('maps "${c.input}"', () async {
        final l10nIt = await AppLocalizations.delegate.load(const Locale('it'));
        final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));

        final it = mapKnownRpcMessage(c.input, l10nIt)!;
        final en = mapKnownRpcMessage(c.input, l10nEn)!;

        expect(it.toLowerCase(), contains(c.itContains!.toLowerCase()));
        expect(en.toLowerCase(), contains(c.enContains!.toLowerCase()));
        expect(it, isNot(contains('EXCEPTION')));
        expect(en, isNot(contains('EXCEPTION')));
      });
    }
  });

  group('userFacingMessage', () {
    test('Postgrest unknown message falls back to generic', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('it'));
      final msg = userFacingMessage(
        const PostgrestException(message: 'PGRST internal xyz', code: '500'),
        l10n: l10n,
      );
      expect(msg, l10n.genericError);
    });

    test('Postgrest mapped message is localized', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('it'));
      final msg = userFacingMessage(
        const PostgrestException(message: 'Valore voto non valido'),
        l10n: l10n,
      );
      expect(msg, l10n.errorInvalidVote);
    });

    test('raw SQL-like text is not shown', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final msg = userFacingMessage(
        Exception('PGRST301 postgres timeout'),
        l10n: l10n,
      );
      expect(msg, l10n.genericError);
    });
  });
}
