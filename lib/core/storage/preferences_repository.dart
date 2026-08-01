import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SafeContextCache {
  const SafeContextCache({
    required this.role,
    required this.platform,
    required this.deviceDisplayName,
    required this.lastSynchronizedAt,
  });

  final String role;
  final String platform;
  final String deviceDisplayName;
  final DateTime lastSynchronizedAt;

  Map<String, Object?> toJson() => {
    'version': 1,
    'role': role,
    'platform': platform,
    'deviceDisplayName': deviceDisplayName,
    'lastSynchronizedAt': lastSynchronizedAt.toUtc().toIso8601String(),
  };

  static SafeContextCache? fromJson(Object? value) {
    if (value is! Map<String, Object?> || value['version'] != 1) {
      return null;
    }
    final role = value['role'];
    final platform = value['platform'];
    final deviceDisplayName = value['deviceDisplayName'];
    final synchronized = value['lastSynchronizedAt'];
    if (role is! String ||
        platform is! String ||
        deviceDisplayName is! String ||
        synchronized is! String) {
      return null;
    }
    final parsed = DateTime.tryParse(synchronized);
    if (parsed == null) {
      return null;
    }
    return SafeContextCache(
      role: role,
      platform: platform,
      deviceDisplayName: deviceDisplayName,
      lastSynchronizedAt: parsed,
    );
  }
}

final class PreferencesRepository {
  PreferencesRepository(this._preferences);

  static const _localeKey = 'preferences.locale.v1';
  static const _themeKey = 'preferences.theme.v1';
  static const _contextKey = 'cache.safe_device_context.v1';

  final SharedPreferences _preferences;

  Locale? readLocale() {
    final value = _preferences.getString(_localeKey);
    return switch (value) {
      'en' => const Locale('en'),
      'ar' => const Locale('ar'),
      _ => null,
    };
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _preferences.remove(_localeKey);
    } else {
      await _preferences.setString(_localeKey, locale.languageCode);
    }
  }

  ThemeMode readThemeMode() => switch (_preferences.getString(_themeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setThemeMode(ThemeMode mode) =>
      _preferences.setString(_themeKey, mode.name);

  SafeContextCache? readSafeContext() {
    final raw = _preferences.getString(_contextKey);
    if (raw == null) {
      return null;
    }
    try {
      final value = jsonDecode(raw);
      return SafeContextCache.fromJson(value);
    } on FormatException {
      return null;
    }
  }

  Future<void> setSafeContext(SafeContextCache context) =>
      _preferences.setString(_contextKey, jsonEncode(context.toJson()));

  Future<void> clearSafeContext() => _preferences.remove(_contextKey);
}
