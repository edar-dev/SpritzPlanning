import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/preferences_providers.dart';

/// Lingua, tema e modalità proiettore in un unico pannello accessibile.
class HomeSettingsSheet extends ConsumerWidget {
  const HomeSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const HomeSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).valueOrNull ?? const Locale('it');
    final projectorMode =
        ref.watch(projectorModeProvider).valueOrNull ?? false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.appSettings,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.languageLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<Locale>(
              segments: const [
                ButtonSegment(value: Locale('it'), label: Text('IT')),
                ButtonSegment(value: Locale('en'), label: Text('EN')),
              ],
              selected: {locale},
              onSelectionChanged: (selected) {
                ref.read(localeProvider.notifier).setLocale(selected.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              l10n.themeSystem,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l10n.themeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(l10n.themeSystem),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selected) {
                ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.projectorMode),
              subtitle: Text(l10n.projectorModeHint),
              value: projectorMode,
              onChanged: (value) {
                ref.read(projectorModeProvider.notifier).setProjectorMode(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
