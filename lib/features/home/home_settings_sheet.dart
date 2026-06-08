import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/notifications/browser_notifications.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_providers.dart';
/// Lingua, tema e modalità proiettore in un unico pannello accessibile.
class HomeSettingsSheet extends ConsumerStatefulWidget {
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
  ConsumerState<HomeSettingsSheet> createState() => _HomeSettingsSheetState();
}

class _HomeSettingsSheetState extends ConsumerState<HomeSettingsSheet> {
  bool _notificationsEnabled = false;
  bool _notificationsLoaded = false;
  bool _soundEnabled = false;
  bool _hapticEnabled = false;
  bool _autoStartNextOrder = false;
  bool _feedbackLoaded = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPrefs());
  }

  Future<void> _loadPrefs() async {
    final enabled = await AppPreferences.loadNotificationsEnabled();
    final sound = await AppPreferences.loadSoundEffectsEnabled();
    final haptic = await AppPreferences.loadHapticEnabled();
    final autoNext = await AppPreferences.loadAutoStartNextOrder();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _notificationsLoaded = true;
      _soundEnabled = sound;
      _hapticEnabled = haptic;
      _autoStartNextOrder = autoNext;
      _feedbackLoaded = true;
    });
  }

  Future<void> _setNotifications(bool value) async {
    if (value) {
      final permission = await requestBrowserNotificationPermission();
      if (permission != BrowserNotificationPermission.granted) {
        if (!mounted) return;
        setState(() => _notificationsEnabled = false);
        await AppPreferences.saveNotificationsEnabled(false);
        return;
      }
    }
    await AppPreferences.saveNotificationsEnabled(value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
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
            if (_notificationsLoaded)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.notificationsTitle),
                subtitle: Text(l10n.notificationsSubtitle),
                value: _notificationsEnabled,
                onChanged: (value) => unawaited(_setNotifications(value)),
              ),
            if (_feedbackLoaded) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.soundEffectsTitle),
                subtitle: Text(l10n.soundEffectsSubtitle),
                value: _soundEnabled,
                onChanged: (value) async {
                  await AppPreferences.saveSoundEffectsEnabled(value);
                  if (!mounted) return;
                  setState(() => _soundEnabled = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.hapticTitle),
                subtitle: Text(l10n.hapticSubtitle),
                value: _hapticEnabled,
                onChanged: (value) async {
                  await AppPreferences.saveHapticEnabled(value);
                  if (!mounted) return;
                  setState(() => _hapticEnabled = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.autoNextOrderTitle),
                subtitle: Text(l10n.autoNextOrderSubtitle),
                value: _autoStartNextOrder,
                onChanged: (value) async {
                  await AppPreferences.saveAutoStartNextOrder(value);
                  if (!mounted) return;
                  setState(() => _autoStartNextOrder = value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
