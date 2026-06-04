import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'core/l10n/l10n_extensions.dart';
import 'core/preferences/preferences_providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/projector_theme.dart';

class SpritzPlanningApp extends ConsumerWidget {
  const SpritzPlanningApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).valueOrNull;
    final projectorMode =
        ref.watch(projectorModeProvider).valueOrNull ?? false;
    final projector = ProjectorMode(enabled: projectorMode);
    final textScale = projectorMode ? 1.25 : 1.0;
    final workspace = ref.watch(activeWorkspaceProvider).valueOrNull;
    final brandColor = workspace != null
        ? Color(workspace.brandColorArgb)
        : const Color(AppColors.oliveGreen);
    final lightScheme = AppTheme.light.colorScheme.copyWith(
      secondary: brandColor,
      tertiary: brandColor,
    );

    return MaterialApp.router(
      title: 'SpritzPlanning',
      theme: AppTheme.light.copyWith(
        colorScheme: lightScheme,
        extensions: [projector],
        textTheme: AppTheme.light.textTheme.apply(fontSizeFactor: textScale),
      ),
      darkTheme: AppTheme.dark.copyWith(
        extensions: [projector],
        textTheme: AppTheme.dark.textTheme.apply(fontSizeFactor: textScale),
      ),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
