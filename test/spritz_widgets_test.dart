import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spritz_planning/core/constants/app_strings.dart';
import 'package:spritz_planning/core/constants/deck_values.dart';
import 'package:spritz_planning/shared/widgets/spritz_card.dart';

void main() {
  group('DeckValues', () {
    test('contains all Fibonacci values', () {
      expect(DeckValues.values, contains('8'));
      expect(DeckValues.values, contains('?'));
      expect(DeckValues.values, contains('☕'));
    });

    test('label returns Italian names', () {
      expect(DeckValues.label('0'), 'Acqua');
      expect(DeckValues.label('½'), 'Mezzo');
      expect(DeckValues.label('5'), 'Spritz 5');
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

  group('AppStrings', () {
    test('uses Italian bar terminology', () {
      expect(AppStrings.openLocale, 'Apri un locale');
      expect(AppStrings.servizio, 'Servizio!');
      expect(AppStrings.barman, 'Barman');
    });
  });
}
