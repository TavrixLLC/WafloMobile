import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';

final class LocalDemoScenariosScreen extends ConsumerWidget {
  const LocalDemoScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(localDemoControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.demoScenarios)),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              key: const Key('local-demo-scenario-hub'),
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
              children: [
                WafloStatusBanner(
                  icon: Icons.visibility_outlined,
                  message: strings.localDemoScenarioBody,
                  color: context.waflo.brandAction,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                const SizedBox(height: WafloSpacing.lg),
                for (final group in _groups(strings)) ...[
                  _ScenarioGroup(
                    group: group,
                    selected: state.scenario,
                    enabled: !state.busy,
                    onSelect: (scenario) =>
                        unawaited(_openScenario(context, ref, scenario)),
                  ),
                  const SizedBox(height: WafloSpacing.sm),
                ],
                const SizedBox(height: WafloSpacing.lg),
                OutlinedButton.icon(
                  key: const Key('exit-local-demo'),
                  onPressed: state.busy
                      ? null
                      : () => unawaited(_confirmExit(context, ref)),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(strings.exitDemo),
                ),
              ],
            ),
            if (state.busy)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  key: Key('local-demo-scenario-loading'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openScenario(
    BuildContext context,
    WidgetRef ref,
    LocalDemoScenario scenario,
  ) async {
    final path = await ref
        .read(localDemoControllerProvider.notifier)
        .prepareScenario(
          scenario,
          locale: Localizations.localeOf(context).languageCode,
        );
    if (context.mounted) unawaited(context.push(path));
  }

  static Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.exitDemo),
        content: Text(strings.exitLocalDemoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.exitDemo),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(localDemoControllerProvider.notifier).exit();
      if (context.mounted) context.go('/');
    }
  }

  static List<_ScenarioGroupData> _groups(AppLocalizations strings) => [
    _ScenarioGroupData(strings.demoGroupOverview, const [
      LocalDemoScenario.home,
    ]),
    _ScenarioGroupData(strings.demoGroupScanner, const [
      LocalDemoScenario.scannerReady,
      LocalDemoScenario.scannerQrDetected,
      LocalDemoScenario.scannerResolving,
      LocalDemoScenario.scannerInvalidQr,
      LocalDemoScenario.scannerExpiredQr,
      LocalDemoScenario.scannerNetworkFailure,
      LocalDemoScenario.scannerPermissionDenied,
    ]),
    _ScenarioGroupData(strings.demoGroupCustomer, const [
      LocalDemoScenario.customerZeroOfEight,
      LocalDemoScenario.customerFiveOfEight,
      LocalDemoScenario.customerRewardReady,
    ]),
    _ScenarioGroupData(strings.demoGroupOperations, const [
      LocalDemoScenario.stampConfirmation,
      LocalDemoScenario.stampSuccess,
      LocalDemoScenario.redeemConfirmation,
      LocalDemoScenario.managerApprovalRequired,
      LocalDemoScenario.managerApprovalPending,
      LocalDemoScenario.managerApprovalRejected,
      LocalDemoScenario.managerApprovalExpired,
      LocalDemoScenario.redeemSuccess,
      LocalDemoScenario.purchaseThresholdNotMet,
      LocalDemoScenario.billingBlocked,
    ]),
    _ScenarioGroupData(strings.demoGroupSystem, const [
      LocalDemoScenario.sessionExpired,
      LocalDemoScenario.deviceRevoked,
      LocalDemoScenario.appLock,
      LocalDemoScenario.deviceSecurity,
      LocalDemoScenario.settings,
    ]),
  ];
}

final class _ScenarioGroup extends StatelessWidget {
  const _ScenarioGroup({
    required this.group,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final _ScenarioGroupData group;
  final LocalDemoScenario selected;
  final bool enabled;
  final ValueChanged<LocalDemoScenario> onSelect;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(WafloRadius.large),
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      initiallyExpanded: group.scenarios.contains(selected),
      title: Text(group.title, style: Theme.of(context).textTheme.titleMedium),
      children: [
        for (final scenario in group.scenarios)
          _ScenarioRow(
            scenario: scenario,
            selected: selected == scenario,
            enabled: enabled,
            onTap: () => onSelect(scenario),
          ),
      ],
    ),
  );
}

final class _ScenarioRow extends StatelessWidget {
  const _ScenarioRow({
    required this.scenario,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final LocalDemoScenario scenario;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: ListTile(
        key: Key('local-demo-scenario-${scenario.name}'),
        minTileHeight: 54,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? context.waflo.brandAction : null,
        ),
        title: Text(_scenarioLabel(strings, scenario)),
        trailing: const WafloForwardChevron(),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  static String _scenarioLabel(
    AppLocalizations strings,
    LocalDemoScenario scenario,
  ) => switch (scenario) {
    LocalDemoScenario.home => strings.demoScenarioHome,
    LocalDemoScenario.scannerReady => strings.demoScenarioScannerReady,
    LocalDemoScenario.scannerQrDetected => strings.demoScenarioScannerDetected,
    LocalDemoScenario.scannerResolving => strings.demoScenarioScannerResolving,
    LocalDemoScenario.scannerInvalidQr => strings.demoScenarioScannerInvalid,
    LocalDemoScenario.scannerExpiredQr => strings.demoScenarioScannerExpired,
    LocalDemoScenario.scannerNetworkFailure =>
      strings.demoScenarioScannerNetwork,
    LocalDemoScenario.scannerPermissionDenied =>
      strings.demoScenarioScannerPermission,
    LocalDemoScenario.customerZeroOfEight => strings.demoScenarioCustomerZero,
    LocalDemoScenario.customerFiveOfEight => strings.demoScenarioCustomerFive,
    LocalDemoScenario.customerRewardReady => strings.demoScenarioCustomerEight,
    LocalDemoScenario.stampConfirmation => strings.demoScenarioStampConfirm,
    LocalDemoScenario.stampSuccess => strings.demoScenarioStampSuccess,
    LocalDemoScenario.redeemConfirmation => strings.demoScenarioRedeemConfirm,
    LocalDemoScenario.managerApprovalRequired =>
      strings.demoScenarioApprovalRequired,
    LocalDemoScenario.managerApprovalPending =>
      strings.demoScenarioApprovalPending,
    LocalDemoScenario.managerApprovalRejected =>
      strings.demoScenarioApprovalRejected,
    LocalDemoScenario.managerApprovalExpired =>
      strings.demoScenarioApprovalExpired,
    LocalDemoScenario.redeemSuccess => strings.demoScenarioRedeemSuccess,
    LocalDemoScenario.purchaseThresholdNotMet =>
      strings.demoScenarioPurchaseThreshold,
    LocalDemoScenario.billingBlocked => strings.demoScenarioBillingBlocked,
    LocalDemoScenario.sessionExpired => strings.demoScenarioSessionExpired,
    LocalDemoScenario.deviceRevoked => strings.demoScenarioDeviceRevoked,
    LocalDemoScenario.appLock => strings.demoScenarioAppLock,
    LocalDemoScenario.deviceSecurity => strings.demoScenarioDeviceSecurity,
    LocalDemoScenario.settings => strings.demoScenarioSettings,
  };
}

final class _ScenarioGroupData {
  const _ScenarioGroupData(this.title, this.scenarios);

  final String title;
  final List<LocalDemoScenario> scenarios;
}
