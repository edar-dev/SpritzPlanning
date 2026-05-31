import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'core/l10n/l10n_extensions.dart';
import 'core/preferences/preferences_providers.dart';
import 'core/theme/app_theme.dart';

class SpritzPlanningApp extends ConsumerWidget {
  const SpritzPlanningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).valueOrNull;

    return MaterialApp.router(
      title: 'SpritzPlanning',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
