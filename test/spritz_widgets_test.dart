import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spritz_planning/l10n/app_localizations.dart';

import 'package:spritz_planning/core/constants/deck_values.dart';
import 'package:spritz_planning/shared/widgets/spritz_card.dart';

Widget _l10nApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('it'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DeckValues', () {
    test('defaultDeck contains Fibonacci values', () {
      expect(DeckValues.defaultDeck, contains('8'));
      expect(DeckValues.defaultDeck, contains('?'));
      expect(DeckValues.defaultDeck, contains('☕'));
    });

    testWidgets('label returns Italian names', (tester) async {
      await tester.pumpWidget(
        _l10nApp(
          Builder(
            builder: (context) {
              expect(DeckValues.label(context, '0'), 'Acqua');
              expect(DeckValues.label(context, '½'), 'Mezzo');
              expect(DeckValues.label(context, '5'), 'Spritz 5');
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });

  group('SpritzCard', () {
    testWidgets('shows value and responds to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpritzCard(
              value: '5',
              selected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      await tester.tap(find.text('5'));
      expect(tapped, isTrue);
    });

    testWidgets('disabled card does not respond to tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpritzCard(
              value: '3',
              selected: false,
              disabled: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('3'));
      expect(tapped, isFalse);
    });
  });
}
