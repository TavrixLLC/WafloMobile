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
    final deviceContext = ref.watch(bootControllerProvider).context;
    final appLock = ref.watch(appLockControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final verified = deviceContext == null
        ? strings.unavailable
        : DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_Hm().format(deviceContext.synchronizedAt.toLocal());
    return Scaffold(
      appBar: AppBar(title: Text(strings.deviceAndSecurity)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
              decoration: BoxDecoration(
                color: context.waflo.successSurface,
                borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
              ),
              child: Row(
                children: [
                  const WafloReadyBeacon(size: 42),
                  const SizedBox(width: WafloSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.securityProtected,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: context.waflo.onSuccessSurface),
                        ),
                        Text(
                          strings.securityProtectedBody,
                          style: TextStyle(
                            color: context.waflo.onSuccessSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WafloSpacing.xl),
            WafloOperationalLabel(strings.thisDevice),
            const SizedBox(height: WafloSpacing.sm),
            WafloSummaryRow(
              label: strings.deviceName,
              value: deviceContext?.device.displayName ?? strings.unavailable,
            ),
            WafloSummaryRow(
              label: strings.platformLabel,
              value: strings.localizePlatform(
                deviceContext?.device.platform ?? '',
              ),
            ),
            WafloSummaryRow(
              label: strings.activeOrganization,
              value:
                  deviceContext?.organization.displayName ??
                  strings.unavailable,
            ),
            WafloSummaryRow(
              label: strings.currentLocationLabel,
              value:
                  deviceContext?.currentLocation.displayName ??
                  strings.unavailable,
            ),
            WafloSummaryRow(label: strings.lastVerified, value: verified),
            WafloSummaryRow(
              label: strings.appLock,
              value: _modeLabel(strings, appLock.configuration.mode),
            ),
            WafloSummaryRow(
              label: strings.appVersionLabel,
              value: packageInfo.when(
                data: (info) => info.version,
                error: (error, stackTrace) => strings.unavailable,
                loading: () => '…',
              ),
              divider: false,
            ),
            const SizedBox(height: WafloSpacing.xl),
            FilledButton.tonalIcon(
              onPressed: () => unawaited(
                ref.read(bootControllerProvider.notifier).refreshContext(),
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
              onPressed: () => _confirmSignOut(context, ref, strings),
              icon: const Icon(Icons.logout_rounded),
              label: Text(strings.signOut),
            ),
          ],
        ),
      ),
    );
  }

  static String _modeLabel(AppLocalizations strings, AppLockMode mode) =>
      switch (mode) {
        AppLockMode.off => strings.appLockOff,
        AppLockMode.biometric => strings.biometric,
        AppLockMode.pin => strings.localStaffPin,
      };

  static Future<void> _confirmSignOut(
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
