import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_navigation.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final boot = ref.watch(bootControllerProvider);
    final localDemo = ref.watch(localDemoControllerProvider);
    final localDemoScenarioRoute = ref.watch(localDemoScenarioRouteProvider);
    final operation = ref.watch(m2OperationControllerProvider);
    final deviceContext = ref.watch(activeDeviceContextProvider);
    final online = ref.watch(operationalOnlineProvider);
    final capable =
        deviceContext != null &&
        (!deviceContext.currentLocation.capabilitiesKnown ||
            deviceContext.currentLocation.earningAllowed ||
            deviceContext.currentLocation.redemptionAllowed);
    final pending = operation.pendingOperation != null;
    final canScan = online && capable && !pending;
    final organization = _displayValue(
      deviceContext?.organization.displayName,
      strings.appTitle,
    );
    final location = _displayValue(
      deviceContext?.currentLocation.displayName,
      strings.unavailable,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: localDemo.active
              ? () async {}
              : ref.read(bootControllerProvider.notifier).refreshContext,
          child: ListView(
            key: const Key('task-first-home'),
            padding: const EdgeInsetsDirectional.fromSTEB(
              WafloLayout.pageGutter,
              20,
              WafloLayout.pageGutter,
              32,
            ),
            children: [
              Semantics(
                container: true,
                label: online ? strings.deviceReady : strings.offline,
                child: Row(
                  children: [
                    const WafloBrandMark(size: 30),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(WafloRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: online
                                  ? WafloColors.success
                                  : WafloColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: WafloSpacing.sm),
                          Text(
                            online ? strings.deviceReady : strings.offline,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: WafloSpacing.xl),
              Text(
                organization,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: WafloSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: context.waflo.subtleText,
                  ),
                  const SizedBox(width: WafloSpacing.xs),
                  Expanded(
                    child: Text(
                      location,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.waflo.subtleText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: WafloSpacing.lg),
              if ((boot.session?.isReview ?? false) || localDemo.active) ...[
                WafloStatusBanner(
                  icon: Icons.science_outlined,
                  message: localDemo.active
                      ? strings.sampleData
                      : strings.demoMode,
                  color: context.waflo.brandAction,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                const SizedBox(height: WafloSpacing.lg),
              ],
              if (localDemo.active && localDemoScenarioRoute != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const Key('local-demo-scenarios-entry'),
                    onPressed: () => context.push(localDemoScenarioRoute),
                    icon: const Icon(Icons.view_list_outlined),
                    label: Text(strings.demoScenarios),
                  ),
                ),
                const SizedBox(height: WafloSpacing.sm),
              ],
              if (!online) ...[
                WafloStatusBanner(
                  icon: Icons.cloud_off_rounded,
                  message: '${strings.offlineBanner} ${strings.noOfflineQueue}',
                  color: WafloColors.warning,
                  backgroundColor: context.waflo.warningSurface,
                ),
                const SizedBox(height: WafloSpacing.lg),
              ],
              if (pending) ...[
                _PendingTransaction(onPressed: () => context.push('/loyalty')),
                const SizedBox(height: WafloSpacing.lg),
              ],
              const SizedBox(height: WafloSpacing.md),
              if (!capable) ...[
                WafloStatusBanner(
                  icon: Icons.location_off_outlined,
                  message: strings.noCapabilitiesBody,
                  color: WafloColors.warning,
                  backgroundColor: context.waflo.warningSurface,
                ),
                const SizedBox(height: WafloSpacing.md),
              ],
              WafloPrimaryActionPanel(
                title: strings.scanCustomer,
                subtitle: pending
                    ? strings.scannerBlockedPending
                    : online
                    ? strings.serveNextCustomer
                    : strings.offlineOperationsBlocked,
                onPressed: canScan
                    ? () {
                        ref
                            .read(m2OperationControllerProvider.notifier)
                            .startScanning();
                        context.go('/loyalty');
                      }
                    : null,
              ),
              const SizedBox(height: WafloSpacing.lg),
              WafloOperationalLabel(strings.deviceControls),
              const SizedBox(height: WafloSpacing.sm),
              _HomeActionDock(
                onDeviceSecurity: () => context.push('/device-security'),
                onSettings: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PendingTransaction extends StatelessWidget {
  const _PendingTransaction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Material(
      color: context.waflo.warningSurface,
      borderRadius: BorderRadius.circular(WafloRadius.large),
      child: InkWell(
        key: const Key('pending-operation-home'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(WafloRadius.large),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.sync_problem_rounded,
                color: WafloColors.warning,
              ),
              const SizedBox(width: WafloSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.checkingTransaction,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.waflo.onWarningSurface,
                      ),
                    ),
                    const SizedBox(height: WafloSpacing.xs),
                    Text(
                      strings.pendingDoNotScanAgain,
                      style: TextStyle(color: context.waflo.onWarningSurface),
                    ),
                  ],
                ),
              ),
              WafloForwardChevron(color: context.waflo.onWarningSurface),
            ],
          ),
        ),
      ),
    );
  }
}

final class _HomeActionDock extends StatelessWidget {
  const _HomeActionDock({
    required this.onDeviceSecurity,
    required this.onSettings,
  });

  final VoidCallback onDeviceSecurity;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stackActions =
          constraints.maxWidth < 340 ||
          MediaQuery.textScalerOf(context).scale(14) >= 18.2;
      final deviceSecurity = _HomeDockAction(
        key: const Key('home-device-security'),
        icon: Icons.shield_outlined,
        label: AppLocalizations.of(context).deviceAndSecurity,
        onTap: onDeviceSecurity,
      );
      final settings = _HomeDockAction(
        key: const Key('home-settings'),
        icon: Icons.tune_rounded,
        label: AppLocalizations.of(context).settings,
        onTap: onSettings,
      );
      if (stackActions) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            deviceSecurity,
            const SizedBox(height: WafloSpacing.sm),
            settings,
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: deviceSecurity),
            const SizedBox(width: WafloSpacing.sm),
            Expanded(child: settings),
          ],
        ),
      );
    },
  );
}

final class _HomeDockAction extends StatelessWidget {
  const _HomeDockAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(WafloRadius.large),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(WafloRadius.medium),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: context.waflo.brandAction,
                    ),
                  ),
                  const Spacer(),
                  WafloForwardChevron(color: context.waflo.subtleText),
                ],
              ),
              const SizedBox(height: WafloSpacing.md),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _displayValue(String? value, String unavailable) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? unavailable : trimmed;
}
