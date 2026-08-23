import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_navigation.dart';
import 'package:waflo_staff/features/settings/presentation/language_selector.dart';

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
    final localDemo = ref.watch(localDemoControllerProvider).active;
    final localDemoScenarioRoute = ref.watch(localDemoScenarioRouteProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            WafloLayout.pageGutter,
            8,
            WafloLayout.pageGutter,
            32,
          ),
          children: [
            WafloOperationalLabel(strings.appearanceAndLanguage),
            const SizedBox(height: WafloSpacing.sm),
            WafloLanguageSelector(
              selectedLocale: locale,
              onSelected: (selected) => unawaited(
                ref.read(localeControllerProvider.notifier).setLocale(selected),
              ),
            ),
            const SizedBox(height: WafloSpacing.sm),
            WafloSelectField<ThemeMode>(
              key: ValueKey('theme-select-${themeMode.name}'),
              selectedValue: themeMode,
              semanticsLabel: _themeModeLabel(strings, themeMode),
              icon: Icons.contrast_rounded,
              items: [
                DropdownMenuItem(
                  key: const Key('theme-system'),
                  value: ThemeMode.system,
                  child: Text(strings.themeSystem),
                ),
                DropdownMenuItem(
                  key: const Key('theme-light'),
                  value: ThemeMode.light,
                  child: Text(strings.themeLight),
                ),
                DropdownMenuItem(
                  key: const Key('theme-dark'),
                  value: ThemeMode.dark,
                  child: Text(strings.themeDark),
                ),
              ],
              onSelected: (selected) => unawaited(
                ref
                    .read(themeControllerProvider.notifier)
                    .setThemeMode(selected),
              ),
            ),
            const SizedBox(height: WafloSpacing.xl),
            WafloSurfaceCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                key: const Key('rapid-scan-setting'),
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: WafloSpacing.md,
                  vertical: WafloSpacing.xs,
                ),
                value: rapidScan,
                onChanged: (value) => unawaited(
                  ref
                      .read(rapidScanControllerProvider.notifier)
                      .setEnabled(value),
                ),
                title: Text(strings.rapidScanMode),
                subtitle: Text(strings.rapidScanModeBody),
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            WafloSurfaceCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.symmetric(
                  horizontal: WafloSpacing.md,
                ),
                title: Text(strings.deviceAndSecurity),
                trailing: const WafloForwardChevron(),
                onTap: () => context.push('/device-security'),
              ),
            ),
            if (localDemo && localDemoScenarioRoute != null)
              ListTile(
                key: const Key('review-tools-entry'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.science_outlined),
                title: Text(strings.demoScenarios),
                subtitle: Text(strings.sampleData),
                trailing: const WafloForwardChevron(),
                onTap: () => context.push(localDemoScenarioRoute),
              ),
            const SizedBox(height: WafloSpacing.xl),
            WafloOperationalLabel(strings.appInformation),
            const SizedBox(height: WafloSpacing.sm),
            WafloSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: WafloSpacing.md,
                    ),
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
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: WafloSpacing.md,
                    ),
                    title: Text(strings.openSourceLicenses),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: strings.appTitle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _themeModeLabel(AppLocalizations strings, ThemeMode themeMode) =>
    switch (themeMode) {
      ThemeMode.system => strings.themeSystem,
      ThemeMode.light => strings.themeLight,
      ThemeMode.dark => strings.themeDark,
    };
