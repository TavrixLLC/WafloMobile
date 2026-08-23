import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';

final class ReviewToolsScreen extends ConsumerStatefulWidget {
  const ReviewToolsScreen({super.key});

  @override
  ConsumerState<ReviewToolsScreen> createState() => _ReviewToolsScreenState();
}

final class _ReviewToolsScreenState extends ConsumerState<ReviewToolsScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(
      Future<void>.microtask(
        () => ref.read(reviewAccessControllerProvider.notifier).load(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(reviewAccessControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.reviewTools)),
      body: SafeArea(
        child: WafloResponsiveListView(
          compactHorizontalPadding: WafloSpacing.lg,
          children: [
            WafloStatusBanner(
              icon: Icons.science_outlined,
              message: strings.reviewToolsBody,
              color: context.waflo.brandAction,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(height: WafloSpacing.lg),
            WafloOperationalLabel(strings.reviewScenarios),
            const SizedBox(height: WafloSpacing.sm),
            if (state.loading && state.scenarios.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...state.scenarios.map(
                (scenario) => _ScenarioTile(
                  scenario: scenario,
                  selected: state.selected == scenario.id,
                  enabled: !state.loading,
                  onTap: () => unawaited(
                    ref
                        .read(reviewAccessControllerProvider.notifier)
                        .select(scenario.id),
                  ),
                ),
              ),
            if (state.failure != null) ...[
              const SizedBox(height: WafloSpacing.md),
              WafloStatusBanner(
                icon: Icons.info_outline_rounded,
                message: strings.reviewEnvironmentUnavailable,
                color: WafloColors.warning,
                backgroundColor: context.waflo.warningSurface,
              ),
            ],
            const SizedBox(height: WafloSpacing.xl),
            OutlinedButton.icon(
              onPressed: state.loading
                  ? null
                  : () => unawaited(
                      ref
                          .read(reviewAccessControllerProvider.notifier)
                          .resetFixtures(),
                    ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(strings.resetReviewData),
            ),
            if (state.resetComplete) ...[
              const SizedBox(height: WafloSpacing.sm),
              Text(
                strings.reviewResetComplete,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: WafloColors.success),
              ),
            ],
            const SizedBox(height: WafloSpacing.md),
            TextButton(
              onPressed: state.loading
                  ? null
                  : () => unawaited(_confirmExit(context)),
              child: Text(strings.exitDemo),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.exitDemo),
        content: Text(strings.exitDemoBody),
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
      await ref.read(bootControllerProvider.notifier).exitReviewMode();
    }
  }
}

final class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.scenario,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ReviewScenarioSummary scenario;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = switch (scenario.id) {
      ReviewScenario.customerNew => strings.reviewScenarioNew,
      ReviewScenario.customerActive => strings.reviewScenarioActive,
      ReviewScenario.customerRewardReady => strings.reviewScenarioRewardReady,
      ReviewScenario.managerApprovalRequired =>
        strings.reviewScenarioManagerApproval,
      ReviewScenario.purchaseThresholdFailure =>
        strings.reviewScenarioPurchaseThreshold,
      ReviewScenario.billingBlocked => strings.reviewScenarioBillingBlocked,
      ReviewScenario.invalidQr => strings.reviewScenarioInvalidQr,
    };
    return Semantics(
      selected: selected,
      button: true,
      child: ListTile(
        key: Key('review-scenario-${scenario.id.wireValue}'),
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? context.waflo.brandAction : null,
        ),
        title: Text(title),
        subtitle: scenario.id == ReviewScenario.invalidQr
            ? Text(strings.reviewInvalidQrDetail)
            : Text(strings.progressOf(scenario.goal, scenario.progress)),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
