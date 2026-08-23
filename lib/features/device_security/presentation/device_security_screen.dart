import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/localization/localization_extensions.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';

final class DeviceSecurityScreen extends ConsumerWidget {
  const DeviceSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final localDemo = ref.watch(localDemoControllerProvider);
    final deviceContext = ref.watch(activeDeviceContextProvider);
    final appLock = ref.watch(appLockControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final device = deviceContext?.device;
    final currentLocation = deviceContext?.currentLocation;
    final role = _nonEmpty(deviceContext?.role);
    final status = _nonEmpty(device?.status);
    final verified = deviceContext == null
        ? strings.unavailable
        : DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_Hm().format(deviceContext.synchronizedAt.toLocal());
    return Scaffold(
      appBar: AppBar(title: Text(strings.deviceAndSecurity)),
      body: SafeArea(
        child: WafloResponsiveListView(
          children: [
            Text(
              strings.securityProtected,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: WafloSpacing.xs),
            Text(
              strings.securityProtectedBody,
              style: TextStyle(color: context.waflo.subtleText),
            ),
            const SizedBox(height: WafloSpacing.lg),
            WafloSurfaceCard(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Column(
                children: [
                  WafloSummaryRow(
                    label: strings.thisDevice,
                    value: _available(device?.displayName, strings),
                  ),
                  WafloSummaryRow(
                    label: strings.activeOrganization,
                    value: _available(
                      deviceContext?.organization.displayName,
                      strings,
                    ),
                  ),
                  WafloSummaryRow(
                    label: strings.currentLocationLabel,
                    value: _available(currentLocation?.displayName, strings),
                  ),
                  WafloSummaryRow(
                    label: strings.roleLabel,
                    value: role == null
                        ? strings.unavailable
                        : strings.localizeRole(role),
                  ),
                  WafloSummaryRow(
                    label: strings.deviceStatusLabel,
                    value: status == 'ACTIVE'
                        ? strings.active
                        : status ?? strings.unavailable,
                  ),
                  WafloSummaryRow(
                    label: strings.locationsTitle,
                    value: deviceContext == null
                        ? strings.unavailable
                        : strings.assignedLocations(
                            deviceContext.assignedLocationCount,
                          ),
                    divider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            WafloSurfaceCard(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Column(
                children: [
                  WafloSummaryRow(
                    label: strings.earningCapability,
                    value: _capability(
                      strings,
                      known: currentLocation?.capabilitiesKnown,
                      allowed: currentLocation?.earningAllowed,
                    ),
                  ),
                  WafloSummaryRow(
                    label: strings.redemptionCapability,
                    value: _capability(
                      strings,
                      known: currentLocation?.capabilitiesKnown,
                      allowed: currentLocation?.redemptionAllowed,
                    ),
                  ),
                  WafloSummaryRow(label: strings.lastVerified, value: verified),
                  WafloSummaryRow(
                    label: strings.appLock,
                    value: _modeLabel(strings, appLock.configuration.mode),
                  ),
                  WafloSummaryRow(
                    label: strings.appVersionLabel,
                    value: packageInfo.when(
                      data: (info) => _available(info.version, strings),
                      error: (error, stackTrace) => strings.unavailable,
                      loading: () => '…',
                    ),
                    divider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: WafloSpacing.sm),
            Text(
              _platform(strings, device?.platform),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.waflo.subtleText),
            ),
            const SizedBox(height: WafloSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: localDemo.active
                  ? () {}
                  : () => unawaited(
                      ref
                          .read(bootControllerProvider.notifier)
                          .refreshContext(),
                    ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.refreshStatus),
            ),
            const SizedBox(height: WafloSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.push('/app-lock'),
              icon: const Icon(Icons.lock_outline_rounded),
              label: Text(strings.appLockSettings),
            ),
            const SizedBox(height: WafloSpacing.sm),
            TextButton.icon(
              key: const Key('sign-out'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _confirmSignOut(
                context,
                ref,
                strings,
                localDemo: localDemo.active,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                localDemo.active ? strings.exitDemo : strings.signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _modeLabel(AppLocalizations strings, AppLockMode mode) =>
      switch (mode) {
        AppLockMode.off => strings.appLockOff,
        AppLockMode.biometric => strings.pinAndBiometrics,
        AppLockMode.pin => strings.localStaffPin,
      };

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String _available(String? value, AppLocalizations strings) =>
      _nonEmpty(value) ?? strings.unavailable;

  static String _capability(
    AppLocalizations strings, {
    required bool? known,
    required bool? allowed,
  }) {
    if (known != true || allowed == null) return strings.unavailable;
    return allowed ? strings.capabilityAllowed : strings.capabilityBlocked;
  }

  static String _platform(AppLocalizations strings, String? platform) {
    final value = _nonEmpty(platform);
    return value == null
        ? strings.unavailable
        : strings.localizePlatform(value);
  }

  static Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings, {
    required bool localDemo,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localDemo ? strings.exitDemo : strings.signOutTitle),
        content: Text(
          localDemo ? strings.exitLocalDemoBody : strings.signOutBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localDemo ? strings.exitDemo : strings.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      if (localDemo) {
        await ref.read(localDemoControllerProvider.notifier).exit();
      } else {
        await ref.read(bootControllerProvider.notifier).logout();
      }
    }
  }
}
