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
    final deviceContext = boot.context;
    final session = boot.session;
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
                title: session?.deviceDisplayName ?? strings.verifiedByWaflo,
                icon: Icons.phone_android_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${strings.roleLabel}: ${strings.localizeRole(deviceContext?.role ?? session?.role ?? '')}',
                    ),
                    Text(
                      '${strings.platformLabel}: ${strings.localizePlatform(deviceContext?.platform ?? session?.devicePlatform ?? '')}',
                    ),
                    Text(
                      strings.assignedLocations(
                        deviceContext?.assignedLocationCount ?? 1,
                      ),
                    ),
                    if (synchronized != null)
                      Text(strings.lastSynchronized(synchronized)),
                  ],
                ),
              ),
              const SizedBox(height: WafloSpacing.md),
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
              _UnavailableTile(
                icon: Icons.qr_code_scanner,
                title: strings.scanCustomer,
                subtitle: strings.availableInNextPhase,
              ),
              _UnavailableTile(
                icon: Icons.receipt_long_outlined,
                title: strings.recentOperations,
                subtitle: strings.availableInNextPhase,
              ),
              _UnavailableTile(
                icon: Icons.approval_outlined,
                title: strings.managerApprovals,
                subtitle: strings.availableInNextPhase,
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
