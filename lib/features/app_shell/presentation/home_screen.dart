import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
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
    final lastVerified = deviceContext == null
        ? null
        : DateFormat.Hm(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(deviceContext.synchronizedAt.toLocal());

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
              Text(
                deviceContext?.organization.displayName ?? strings.appTitle,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: WafloSpacing.sm),
              Wrap(
                spacing: WafloSpacing.xs,
                runSpacing: WafloSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    deviceContext?.currentLocation.displayName ??
                        strings.unavailable,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.waflo.subtleText,
                    ),
                  ),
                  if (lastVerified != null)
                    Text(
                      '· ${strings.lastVerified} $lastVerified',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.waflo.subtleText,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: WafloSpacing.xxl),
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
              Row(
                children: [
                  Expanded(
                    child: _HomeLink(
                      label: strings.deviceAndSecurity,
                      onTap: () => context.push('/device-security'),
                    ),
                  ),
                  const SizedBox(width: WafloSpacing.sm),
                  Expanded(
                    child: _HomeLink(
                      label: strings.settings,
                      onTap: () => context.push('/settings'),
                    ),
                  ),
                ],
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
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: context.waflo.onWarningSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _HomeLink extends StatelessWidget {
  const _HomeLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: context.waflo.subtleText,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
    ),
    child: Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: context.waflo.subtleText,
      ),
    ),
  );
}
