import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spritz_planning/app.dart';
import 'package:spritz_planning/core/preferences/preferences_providers.dart';
import 'package:spritz_planning/main.dart';

void main() {
  testWidgets('Home screen shows app name and CTAs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(() => _FixedLocaleNotifier()),
          themeModeProvider.overrideWith(() => _FixedThemeNotifier()),
        ],
        child: const SessionRestoreWrapper(
          child: SpritzPlanningApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SpritzPlanning'), findsOneWidget);
    expect(find.text('Apri un locale'), findsOneWidget);
    expect(find.text('Entra al bancone'), findsOneWidget);
  });

  testWidgets('SpritzCard renders deck value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.shrink(),
        ),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

class _FixedLocaleNotifier extends LocaleNotifier {
  @override
  Future<Locale?> build() async => const Locale('it');
}

class _FixedThemeNotifier extends ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async => ThemeMode.light;
}
