import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPreferences {
  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale_code';
  static const _lastNicknameKey = 'last_nickname';
  static const _hasCompletedSessionKey = 'has_completed_session';
  static const _projectorModeKey = 'projector_mode';
  static const _notificationsEnabledKey = 'notifications_enabled';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  static Future<void> saveLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
      return;
    }
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<String?> loadLastNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNicknameKey);
  }

  static Future<void> saveLastNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.length < 2) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastNicknameKey, trimmed);
  }

  static Future<bool> loadHasCompletedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedSessionKey) ?? false;
  }

  static Future<void> markSessionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedSessionKey, true);
  }

  static Future<bool> loadProjectorMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_projectorModeKey) ?? false;
  }

  static Future<void> saveProjectorMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_projectorModeKey, enabled);
  }

  static Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
