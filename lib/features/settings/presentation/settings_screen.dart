import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_navigation.dart';

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
    final reviewSession =
        ref.watch(bootControllerProvider).session?.isReview ?? false;
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
            _SettingsChoiceGroup(
              children: [
                _SettingsChoice(
                  label: strings.english,
                  selected: locale.languageCode == 'en',
                  onTap: () => unawaited(
                    ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(const Locale('en')),
                  ),
                ),
                _SettingsChoice(
                  label: strings.arabic,
                  selected: locale.languageCode == 'ar',
                  onTap: () => unawaited(
                    ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(const Locale('ar')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WafloSpacing.xl),
            _SettingsChoiceGroup(
              children: [
                _SettingsChoice(
                  label: strings.themeSystem,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => unawaited(
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ),
                _SettingsChoice(
                  label: strings.themeLight,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => unawaited(
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                ),
                _SettingsChoice(
                  label: strings.themeDark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => unawaited(
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                ),
              ],
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
                trailing: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                ),
                onTap: () => context.push('/device-security'),
              ),
            ),
            if (reviewSession || (localDemo && localDemoScenarioRoute != null))
              ListTile(
                key: const Key('review-tools-entry'),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.science_outlined),
                title: Text(strings.demoScenarios),
                subtitle: Text(
                  localDemo ? strings.sampleData : strings.demoMode,
                ),
                trailing: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                ),
                onTap: () => context.push(
                  localDemo ? localDemoScenarioRoute! : '/review-tools',
                ),
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

final class _SettingsChoiceGroup extends StatelessWidget {
  const _SettingsChoiceGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const SizedBox(height: WafloSpacing.sm),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1)
            const SizedBox(width: WafloSpacing.sm),
        ],
      ],
    );
  }
}

final class _SettingsChoice extends StatelessWidget {
  const _SettingsChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WafloRadius.medium),
        side: BorderSide(
          color: selected
              ? context.waflo.brandAction
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WafloRadius.medium),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: WafloSpacing.sm,
                vertical: WafloSpacing.sm,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? context.waflo.brandAction : null,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
