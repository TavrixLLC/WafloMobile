import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';

final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final themeMode = ref.watch(themeControllerProvider);
    final rapidScan = ref.watch(rapidScanControllerProvider);
    final environment = ref.watch(environmentProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
          children: [
            WafloOperationalLabel(strings.appearanceAndLanguage),
            const SizedBox(height: WafloSpacing.sm),
            RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  unawaited(
                    ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(Locale(value)),
                  );
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'en',
                    title: Text(strings.english),
                    secondary: const Icon(Icons.language_rounded),
                  ),
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: 'ar',
                    title: Text(strings.arabic),
                    secondary: const Icon(Icons.translate_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: WafloSpacing.xl),
            RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  unawaited(
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(value),
                  );
                }
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: ThemeMode.system,
                    title: Text(strings.themeSystem),
                    secondary: const Icon(Icons.brightness_auto_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: ThemeMode.light,
                    title: Text(strings.themeLight),
                    secondary: const Icon(Icons.light_mode_outlined),
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    value: ThemeMode.dark,
                    title: Text(strings.themeDark),
                    secondary: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
              ),
            ),
            const Divider(height: WafloSpacing.xl),
            SwitchListTile(
              key: const Key('rapid-scan-setting'),
              contentPadding: EdgeInsets.zero,
              value: rapidScan,
              onChanged: (value) => unawaited(
                ref
                    .read(rapidScanControllerProvider.notifier)
                    .setEnabled(value),
              ),
              secondary: const Icon(Icons.fast_forward_rounded),
              title: Text(strings.rapidScanMode),
              subtitle: Text(strings.rapidScanModeBody),
            ),
            const SizedBox(height: WafloSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shield_outlined),
              title: Text(strings.deviceAndSecurity),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
              ),
              onTap: () => context.push('/device-security'),
            ),
            const Divider(height: WafloSpacing.xl),
            WafloOperationalLabel(strings.appInformation),
            const SizedBox(height: WafloSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(strings.appTitle),
              subtitle: packageInfo.when(
                data: (info) => Text(strings.appVersion(info.version)),
                error: (error, stackTrace) => Text(strings.unavailable),
                loading: () => const LinearProgressIndicator(),
              ),
              trailing: !environment.isProduction
                  ? Text(environment.flavor.name)
                  : null,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(strings.openSourceLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: strings.appTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
