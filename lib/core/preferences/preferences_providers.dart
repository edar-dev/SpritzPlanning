import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/plan/plan_tier.dart';
import 'app_preferences.dart';
import 'plan_tier_storage.dart';
import 'workspace_storage.dart';

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() => AppPreferences.loadThemeMode();

  Future<void> setThemeMode(ThemeMode mode) async {
    await AppPreferences.saveThemeMode(mode);
    state = AsyncData(mode);
  }
}

final localeProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() => AppPreferences.loadLocale();

  Future<void> setLocale(Locale locale) async {
    await AppPreferences.saveLocale(locale);
    state = AsyncData(locale);
  }
}

final projectorModeProvider = AsyncNotifierProvider<ProjectorModeNotifier, bool>(
  ProjectorModeNotifier.new,
);

class ProjectorModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => AppPreferences.loadProjectorMode();

  Future<void> setProjectorMode(bool enabled) async {
    await AppPreferences.saveProjectorMode(enabled);
    state = AsyncData(enabled);
  }
}

final planTierProvider =
    AsyncNotifierProvider<PlanTierNotifier, PlanTier>(PlanTierNotifier.new);

class PlanTierNotifier extends AsyncNotifier<PlanTier> {
  @override
  Future<PlanTier> build() => PlanTierStorage.load();

  Future<void> setTier(PlanTier tier) async {
    await PlanTierStorage.save(tier);
    state = AsyncData(tier);
  }
}

final activeWorkspaceProvider = AsyncNotifierProvider<ActiveWorkspaceNotifier,
    WorkspaceProfile>(ActiveWorkspaceNotifier.new);

class ActiveWorkspaceNotifier extends AsyncNotifier<WorkspaceProfile> {
  @override
  Future<WorkspaceProfile> build() => WorkspaceStorage.loadActive();

  Future<void> refresh() async {
    state = AsyncData(await WorkspaceStorage.loadActive());
  }

  Future<void> setActive(String workspaceId) async {
    await WorkspaceStorage.setActiveId(workspaceId);
    await refresh();
  }
}
