import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';

final class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => ref.read(preferencesRepositoryProvider).readLocale();

  Future<void> setLocale(Locale? locale) async {
    await ref.read(preferencesRepositoryProvider).setLocale(locale);
    state = locale;
  }
}

final class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesRepositoryProvider).readThemeMode();

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(preferencesRepositoryProvider).setThemeMode(mode);
    state = mode;
  }
}

final class RapidScanController extends Notifier<bool> {
  @override
  bool build() => ref.read(preferencesRepositoryProvider).readRapidScanMode();

  Future<void> setEnabled(bool enabled) async {
    await ref.read(preferencesRepositoryProvider).setRapidScanMode(enabled);
    state = enabled;
  }
}
