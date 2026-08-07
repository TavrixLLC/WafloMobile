import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/localization/localization_extensions.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final boot = ref.watch(bootControllerProvider);
    final m2 = ref.watch(m2OperationControllerProvider);
    final deviceContext = boot.context;
    final online = ref
        .watch(connectivityProvider)
        .when(
          data: (value) => value,
          error: (error, stackTrace) => false,
          loading: () => true,
        );
    final synchronized = deviceContext == null
        ? null
        : DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).add_Hm().format(deviceContext.synchronizedAt.toLocal());
    final hasCapability =
        deviceContext != null &&
        (!deviceContext.currentLocation.capabilitiesKnown ||
            deviceContext.currentLocation.earningAllowed ||
            deviceContext.currentLocation.redemptionAllowed);
    final canScan = online && hasCapability && m2.pendingOperation == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            tooltip: strings.settings,
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(bootControllerProvider.notifier).refreshContext,
          child: ListView(
            padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
            children: [
              if (!online) ...[
                WafloStatusBanner(
                  icon: Icons.cloud_off_outlined,
                  message: strings.offlineBanner,
                  color: WafloColors.warning,
                ),
                const SizedBox(height: WafloSpacing.md),
              ],
              WafloStatusBanner(
                icon: Icons.verified_user_outlined,
                message: strings.deviceReady,
                color: WafloColors.success,
              ),
              const SizedBox(height: WafloSpacing.md),
              WafloInfoCard(
                title:
                    deviceContext?.organization.displayName ??
                    strings.verifiedByWaflo,
                icon: Icons.business_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (deviceContext != null)
                      Text(
                        '${strings.staffLabel}: ${deviceContext.staff.displayName}',
                      ),
                    Text(
                      '${strings.roleLabel}: ${strings.localizeRole(deviceContext?.role ?? '')}',
                    ),
                    Text(
                      strings.assignedLocations(
                        deviceContext?.assignedLocationCount ?? 0,
                      ),
                    ),
                    if (synchronized != null)
                      Text(strings.lastSynchronized(synchronized)),
                  ],
                ),
              ),
              const SizedBox(height: WafloSpacing.md),
              if (deviceContext != null) ...[
                WafloInfoCard(
                  title: deviceContext.device.displayName,
                  icon: Icons.phone_android_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${strings.deviceStatusLabel}: ${deviceContext.device.status}',
                      ),
                      Text(
                        '${strings.platformLabel}: ${strings.localizePlatform(deviceContext.device.platform)}',
                      ),
                      Text(strings.appVersion(deviceContext.device.appVersion)),
                    ],
                  ),
                ),
                const SizedBox(height: WafloSpacing.md),
                WafloInfoCard(
                  title:
                      '${strings.currentLocationLabel}: ${deviceContext.currentLocation.displayName}',
                  icon: Icons.location_on_outlined,
                  child: _Capabilities(
                    earningAllowed:
                        deviceContext.currentLocation.earningAllowed,
                    redemptionAllowed:
                        deviceContext.currentLocation.redemptionAllowed,
                  ),
                ),
                const SizedBox(height: WafloSpacing.md),
                WafloInfoCard(
                  title: strings.locationsTitle,
                  icon: Icons.location_city_outlined,
                  child: deviceContext.assignedLocations.isEmpty
                      ? Text(strings.assignedLocations(0))
                      : Column(
                          children: [
                            for (final location
                                in deviceContext.assignedLocations)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(location.displayName),
                                subtitle: _Capabilities(
                                  earningAllowed: location.earningAllowed,
                                  redemptionAllowed: location.redemptionAllowed,
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: WafloSpacing.md),
                WafloInfoCard(
                  title: strings.updatePolicyLabel,
                  icon: Icons.system_update_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.minimumSupportedVersion(
                          deviceContext.appPolicy.minimumSupportedVersion,
                        ),
                      ),
                      Text(strings.appVersionCurrent),
                    ],
                  ),
                ),
                const SizedBox(height: WafloSpacing.md),
              ],
              WafloInfoCard(
                title: strings.securityStatus,
                icon: Icons.shield_outlined,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: WafloColors.success),
                    const SizedBox(width: WafloSpacing.sm),
                    Text(strings.active),
                  ],
                ),
              ),
              const SizedBox(height: WafloSpacing.md),
              if (m2.pendingOperation != null) ...[
                WafloStatusBanner(
                  icon: Icons.hourglass_top_outlined,
                  message: strings.pendingOperationBody,
                  color: WafloColors.warning,
                ),
                const SizedBox(height: WafloSpacing.sm),
                Card(
                  child: ListTile(
                    minTileHeight: 56,
                    leading: const Icon(Icons.manage_search_outlined),
                    title: Text(strings.pendingOperationTitle),
                    subtitle: Text(strings.checkStatus),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/loyalty'),
                  ),
                ),
                const SizedBox(height: WafloSpacing.md),
              ],
              if (!hasCapability) ...[
                WafloStatusBanner(
                  icon: Icons.location_off_outlined,
                  message: strings.noCapabilitiesBody,
                  color: WafloColors.warning,
                ),
                const SizedBox(height: WafloSpacing.sm),
                OutlinedButton.icon(
                  onPressed: ref
                      .read(bootControllerProvider.notifier)
                      .refreshContext,
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.refreshRequired),
                ),
                const SizedBox(height: WafloSpacing.md),
              ],
              _ActionTile(
                icon: Icons.qr_code_scanner,
                title: strings.scanCustomer,
                subtitle: online
                    ? hasCapability
                          ? strings.m2ScannerInstructions
                          : strings.noCapabilitiesBody
                    : strings.offlineOperationsBlocked,
                enabled: canScan,
                onTap: () {
                  ref
                      .read(m2OperationControllerProvider.notifier)
                      .startScanning();
                  context.go('/loyalty');
                },
              ),
              _UnavailableTile(
                icon: Icons.receipt_long_outlined,
                title: strings.recentOperations,
                subtitle: strings.notAvailableInM2,
              ),
              _UnavailableTile(
                icon: Icons.approval_outlined,
                title: strings.managerApprovals,
                subtitle: strings.notAvailableInM2,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.go('/settings');
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
}

final class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 64,
      enabled: enabled,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: enabled ? onTap : null,
    ),
  );
}

final class _Capabilities extends StatelessWidget {
  const _Capabilities({
    required this.earningAllowed,
    required this.redemptionAllowed,
  });

  final bool earningAllowed;
  final bool redemptionAllowed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    String value(bool allowed) =>
        allowed ? strings.capabilityAllowed : strings.capabilityBlocked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${strings.earningCapability}: ${value(earningAllowed)}'),
        Text('${strings.redemptionCapability}: ${value(redemptionAllowed)}'),
      ],
    );
  }
}

final class _UnavailableTile extends StatelessWidget {
  const _UnavailableTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      enabled: false,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.lock_clock_outlined),
    ),
  );
}
