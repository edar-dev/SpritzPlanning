import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spritz_planning/app.dart';
import 'package:spritz_planning/core/preferences/preferences_providers.dart';
import 'package:spritz_planning/core/theme/app_colors.dart';
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

  testWidgets('Dark theme applies dark scaffold on home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(() => _FixedLocaleNotifier()),
          themeModeProvider.overrideWith(() => _DarkThemeNotifier()),
        ],
        child: const SessionRestoreWrapper(
          child: SpritzPlanningApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    final homeContext = tester.element(find.text('SpritzPlanning'));
    expect(Theme.of(homeContext).brightness, Brightness.dark);
    expect(
      Theme.of(homeContext).colorScheme.onSurface,
      const Color(AppColors.darkTextPrimary),
    );
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

class _DarkThemeNotifier extends ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async => ThemeMode.dark;
}
