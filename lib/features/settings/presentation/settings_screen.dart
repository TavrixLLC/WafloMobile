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
    final environment = ref.watch(environmentProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
          children: [
            WafloInfoCard(
              title: strings.chooseLanguage,
              icon: Icons.language_outlined,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'en', label: Text(strings.english)),
                  ButtonSegment(value: 'ar', label: Text(strings.arabic)),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (selection) => unawaited(
                  ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(Locale(selection.first)),
                ),
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            WafloInfoCard(
              title: strings.appearance,
              icon: Icons.contrast_outlined,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(strings.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(strings.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(strings.themeDark),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) => unawaited(
                  ref
                      .read(themeControllerProvider.notifier)
                      .setThemeMode(selection.first),
                ),
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            WafloInfoCard(
              title: strings.deviceInformation,
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  packageInfo.when(
                    data: (info) => Text(strings.appVersion(info.version)),
                    error: (error, stackTrace) => Text(strings.genericError),
                    loading: () => const LinearProgressIndicator(),
                  ),
                  if (!environment.isProduction)
                    Text(strings.environment(environment.flavor.name)),
                ],
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            ListTile(
              leading: const Icon(Icons.sync),
              title: Text(strings.refreshContext),
              onTap: () => unawaited(
                ref.read(bootControllerProvider.notifier).refreshContext(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: Text(strings.privacy),
              subtitle: Text(strings.availableInNextPhase),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(strings.support),
              subtitle: Text(strings.availableInNextPhase),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(strings.openSourceLicenses),
              onTap: () => showLicensePage(
                context: context,
                applicationName: strings.appTitle,
              ),
            ),
            const Divider(),
            ListTile(
              key: const Key('sign-out'),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              leading: const Icon(Icons.logout),
              title: Text(strings.signOut),
              onTap: () => _confirmSignOut(context, ref, strings),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/home');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: strings.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: strings.settings,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.signOutTitle),
        content: Text(strings.signOutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(bootControllerProvider.notifier).logout();
    }
  }
}
