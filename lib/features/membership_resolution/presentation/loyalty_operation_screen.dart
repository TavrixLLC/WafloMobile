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
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/loyalty_progress/presentation/two_state_stamp_grid.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

final class LoyaltyOperationScreen extends ConsumerWidget {
  const LoyaltyOperationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(m2OperationControllerProvider);
    final controller = ref.read(m2OperationControllerProvider.notifier);
    final submitting =
        state.stage == M2OperationStage.stampSubmitting ||
        state.stage == M2OperationStage.redemptionSubmitting;
    return PopScope(
      canPop: !submitting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title(strings, state.stage)),
          leading: submitting
              ? null
              : IconButton(
                  tooltip: strings.close,
                  onPressed: () async {
                    if (state.stage == M2OperationStage.stampAmbiguous ||
                        state.stage == M2OperationStage.redemptionAmbiguous) {
                      controller.cancelLocalRecoveryView();
                    } else {
                      await controller.acknowledgeAndReset();
                    }
                    if (context.mounted) context.go('/home');
                  },
                  icon: const Icon(Icons.close),
                ),
        ),
        body: SafeArea(
          child: _OperationBody(state: state, controller: controller),
        ),
      ),
    );
  }

  static String _title(AppLocalizations strings, M2OperationStage stage) =>
      switch (stage) {
        M2OperationStage.scanning => strings.m2ScannerTitle,
        M2OperationStage.resolving => strings.resolvingMembership,
        M2OperationStage.membershipReady => strings.membershipTitle,
        M2OperationStage.stampReview => strings.reviewStampTitle,
        M2OperationStage.stampSubmitting => strings.issuingStamps,
        M2OperationStage.stampSucceeded => strings.stampSuccessTitle,
        M2OperationStage.redemptionReview => strings.redemptionReviewTitle,
        M2OperationStage.redemptionSubmitting => strings.redeemingReward,
        M2OperationStage.redemptionSucceeded => strings.redemptionSuccessTitle,
        M2OperationStage.stampAmbiguous ||
        M2OperationStage.redemptionAmbiguous => strings.pendingOperationTitle,
        M2OperationStage.managerApprovalRequired =>
          strings.managerApprovalRequired,
        _ => strings.scanCustomer,
      };
}

final class _OperationBody extends ConsumerWidget {
  const _OperationBody({required this.state, required this.controller});

  final M2OperationState state;
  final M2OperationController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityProvider).value ?? false;
    if (!online &&
        state.stage != M2OperationStage.membershipReady &&
        state.stage != M2OperationStage.stampAmbiguous &&
        state.stage != M2OperationStage.redemptionAmbiguous &&
        state.stage != M2OperationStage.stampSucceeded &&
        state.stage != M2OperationStage.redemptionSucceeded) {
      return _CenteredOperation(
        child: _ErrorPanel(
          icon: Icons.cloud_off_outlined,
          message: AppLocalizations.of(context).offlineOperationsBlocked,
          requestId: null,
          onRetry: null,
        ),
      );
    }
    return switch (state.stage) {
      M2OperationStage.idle => _CenteredOperation(
        child: FilledButton.icon(
          onPressed: controller.startScanning,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(AppLocalizations.of(context).scanCustomer),
        ),
      ),
      M2OperationStage.scanning => const _CustomerScannerView(),
      M2OperationStage.resolving => _ProgressPanel(
        message: AppLocalizations.of(context).resolvingMembership,
      ),
      M2OperationStage.membershipReady => _MembershipOperationView(
        key: ValueKey(state.membership?.requestId),
        state: state,
        online: online,
      ),
      M2OperationStage.stampReview => _StampReview(state: state),
      M2OperationStage.stampSubmitting => _ProgressPanel(
        message: AppLocalizations.of(context).issuingStamps,
      ),
      M2OperationStage.stampSucceeded => _StampSuccess(state: state),
      M2OperationStage.redemptionReview => _RedemptionReview(state: state),
      M2OperationStage.redemptionSubmitting => _ProgressPanel(
        message: AppLocalizations.of(context).redeemingReward,
      ),
      M2OperationStage.redemptionSucceeded => _RedemptionSuccess(state: state),
      M2OperationStage.stampAmbiguous ||
      M2OperationStage.redemptionAmbiguous => _PendingRecovery(state: state),
      M2OperationStage.managerApprovalRequired => _ManagerApprovalPanel(
        reward: state.selectedReward,
      ),
      _ => _FailureState(state: state),
    };
  }
}

final class _CustomerScannerView extends ConsumerStatefulWidget {
  const _CustomerScannerView();

  @override
  ConsumerState<_CustomerScannerView> createState() =>
      _CustomerScannerViewState();
}

final class _CustomerScannerViewState
    extends ConsumerState<_CustomerScannerView>
    with WidgetsBindingObserver {
  CustomerScannerAdapter? _adapter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adapter = ref.read(customerScannerAdapterProvider);
      unawaited(_adapter!.start());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_adapter?.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_adapter?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final adapter = ref.watch(customerScannerAdapterProvider);
    _adapter = adapter;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
          child: Semantics(
            liveRegion: true,
            child: Text(
              strings.m2ScannerInstructions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Expanded(
          child: adapter.buildPreview(
            context,
            onDetected: (candidate) => ref
                .read(m2OperationControllerProvider.notifier)
                .resolveCandidate(
                  candidate,
                  locale: Localizations.localeOf(context).languageCode,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(adapter.toggleTorch()),
                  icon: const Icon(Icons.flashlight_on_outlined),
                  label: Text(strings.toggleFlash),
                ),
              ),
              const SizedBox(width: WafloSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    unawaited(adapter.stop());
                    unawaited(
                      ref
                          .read(m2OperationControllerProvider.notifier)
                          .acknowledgeAndReset(),
                    );
                    context.go('/home');
                  },
                  child: Text(strings.cancel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _MembershipOperationView extends ConsumerStatefulWidget {
  const _MembershipOperationView({
    required this.state,
    required this.online,
    super.key,
  });

  final M2OperationState state;
  final bool online;

  @override
  ConsumerState<_MembershipOperationView> createState() =>
      _MembershipOperationViewState();
}

final class _MembershipOperationViewState
    extends ConsumerState<_MembershipOperationView> {
  final _purchaseController = TextEditingController();
  final _referenceController = TextEditingController();
  int _amount = 1;

  @override
  void dispose() {
    _purchaseController.clear();
    _referenceController.clear();
    _purchaseController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membership = widget.state.membership!;
    final strings = AppLocalizations.of(context);
    final policy = membership.operationPolicy;
    final maximum = policy.selectableMaximumStampAmount;
    if (_amount > maximum && maximum > 0) {
      _amount = maximum;
    }
    final dateFormat = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();
    return ListView(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
      children: [
        WafloInfoCard(
          title: membership.programName,
          icon: Icons.loyalty_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${strings.customerLabel}: ${membership.customerDisplayName}',
              ),
              Text(
                '${strings.membershipStatusLabel}: ${strings.localizeMembershipStatus(membership.status.name)}',
              ),
              Text(strings.completedCycles(membership.completedCycles)),
              Text(
                strings.resolvedAt(
                  dateFormat.format(membership.resolvedAt.toLocal()),
                ),
              ),
              const SizedBox(height: WafloSpacing.md),
              TwoStateStampGrid(
                progress: membership.progress,
                artwork: membership.stampArtwork,
                cache: ref.watch(stampImageCacheProvider),
                semanticLabel: strings.progressOf(
                  membership.progress.goal,
                  membership.progress.progress,
                ),
                allowInsecureAssets:
                    ref.watch(environmentProvider).flavor.name == 'development',
              ),
              const SizedBox(height: WafloSpacing.sm),
              Text(
                strings.progressOf(
                  membership.progress.goal,
                  membership.progress.progress,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (membership.rewardReady)
                WafloStatusBanner(
                  icon: Icons.info_outline,
                  message: strings.finalReady,
                  color: WafloColors.warning,
                ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacing.md),
        if (membership.earningAllowed) ...[
          WafloInfoCard(
            title: strings.stampAmount,
            icon: Icons.add_circle_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  value: _amount.toString(),
                  label: strings.stampAmount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: strings.stampAmount,
                        onPressed: _amount > 1
                            ? () => setState(() => _amount -= 1)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_amount',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: strings.stampAmount,
                        onPressed: _amount < maximum
                            ? () => setState(() => _amount += 1)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Text(
                  strings.projectedProgress(
                    membership.progress.goal,
                    membership.progress.progress + _amount,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (policy.purchaseRequirementEnabled) ...[
                  const SizedBox(height: WafloSpacing.md),
                  TextField(
                    key: const Key('purchase-amount-field'),
                    controller: _purchaseController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: strings.purchaseAmount,
                      helperText: strings.requiredCurrency(
                        policy.purchaseCurrency!,
                      ),
                    ),
                  ),
                ],
                if (policy.merchantTransactionReferenceAllowed) ...[
                  const SizedBox(height: WafloSpacing.md),
                  TextField(
                    key: const Key('transaction-reference-field'),
                    controller: _referenceController,
                    maxLength: 120,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: policy.merchantTransactionReferenceRequired
                          ? strings.transactionReference
                          : '${strings.transactionReference} (${strings.optionalLabel})',
                    ),
                  ),
                ],
                const SizedBox(height: WafloSpacing.md),
                FilledButton(
                  onPressed: widget.online && widget.state.credentialAvailable
                      ? () => ref
                            .read(m2OperationControllerProvider.notifier)
                            .prepareStampReview(
                              amount: _amount,
                              purchaseAmountText: _purchaseController.text,
                              transactionReferenceText:
                                  _referenceController.text,
                            )
                      : null,
                  child: Text(strings.continueToReview),
                ),
              ],
            ),
          ),
          const SizedBox(height: WafloSpacing.md),
        ],
        if (!widget.online)
          WafloStatusBanner(
            icon: Icons.cloud_off_outlined,
            message: strings.offlineOperationsBlocked,
            color: WafloColors.warning,
          ),
        if (!widget.state.credentialAvailable)
          WafloStatusBanner(
            icon: Icons.qr_code_scanner,
            message: strings.rescanRequired,
            color: WafloColors.warning,
          ),
        if (membership.availableRewards.isNotEmpty)
          WafloInfoCard(
            title: strings.rewardsTitle,
            icon: Icons.card_giftcard_outlined,
            child: Column(
              children: [
                for (final reward in membership.availableRewards)
                  _RewardTile(
                    reward: reward,
                    redemptionAllowed:
                        membership.redemptionAllowed &&
                        widget.online &&
                        widget.state.credentialAvailable,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

final class _RewardTile extends ConsumerWidget {
  const _RewardTile({required this.reward, required this.redemptionAllowed});

  final AvailableReward reward;
  final bool redemptionAllowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final expiration = reward.expiresAt == null
        ? null
        : DateFormat.yMd(locale).format(reward.expiresAt!.toLocal());
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(reward.name, style: Theme.of(context).textTheme.titleMedium),
            Text(reward.description),
            Text(
              reward.finalReward
                  ? strings.finalReward
                  : strings.milestoneReward,
            ),
            Text(strings.thresholdLabel(reward.threshold)),
            Text(
              strings.redemptionCount(
                reward.redemptionCount,
                reward.maximumRedemptionCount,
              ),
            ),
            if (expiration != null) Text(strings.expirationLabel(expiration)),
            if (reward.redemptionInstructions != null)
              Text(reward.redemptionInstructions!),
            if (reward.requiresManagerApproval)
              Text(
                strings.managerApprovalRequired,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: WafloSpacing.sm),
            FilledButton.tonal(
              onPressed: redemptionAllowed || reward.requiresManagerApproval
                  ? () => ref
                        .read(m2OperationControllerProvider.notifier)
                        .prepareRedemption(reward, locale: locale)
                  : null,
              child: Text(strings.redeem),
            ),
          ],
        ),
      ),
    );
  }
}

final class _StampReview extends ConsumerWidget {
  const _StampReview({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = state.membership!;
    final input = state.stampInput!;
    final strings = AppLocalizations.of(context);
    final location = ref.watch(bootControllerProvider).context?.currentLocation;
    return _ReviewList(
      title: strings.reviewStampTitle,
      rows: [
        (strings.customerLabel, membership.customerDisplayName),
        (strings.programLabel, membership.programName),
        (strings.stampAmount, input.amount.toString()),
        (
          strings.membershipTitle,
          strings.progressOf(
            membership.progress.goal,
            membership.progress.progress,
          ),
        ),
        (
          strings.projectedProgress(
            membership.progress.goal,
            membership.progress.progress + input.amount,
          ),
          '',
        ),
        if (input.purchaseAmountMinor != null)
          (
            strings.purchaseAmount,
            MinorUnitMoney(
              minorUnits: input.purchaseAmountMinor!,
              currencyCode: input.purchaseCurrency!,
              fractionDigits: CurrencyMetadata.fractionDigits(
                input.purchaseCurrency!,
              ),
            ).formatExact(),
          ),
        if (location != null)
          (strings.currentLocationLabel, location.displayName),
      ],
      warning:
          membership.progress.progress + input.amount ==
              membership.progress.goal
          ? strings.rewardReady
          : null,
      confirmLabel: strings.confirmStamp,
      onConfirm: () => ref
          .read(m2OperationControllerProvider.notifier)
          .confirmStamp(locale: Localizations.localeOf(context).languageCode),
      onBack: ref
          .read(m2OperationControllerProvider.notifier)
          .returnToMembership,
    );
  }
}

final class _RedemptionReview extends ConsumerWidget {
  const _RedemptionReview({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final membership = state.membership!;
    final reward = state.selectedReward!;
    final location = ref.watch(bootControllerProvider).context?.currentLocation;
    return _ReviewList(
      title: strings.redemptionReviewTitle,
      rows: [
        (strings.customerLabel, membership.customerDisplayName),
        (strings.programLabel, membership.programName),
        (strings.rewardsTitle, reward.name),
        (
          reward.finalReward ? strings.finalReward : strings.milestoneReward,
          reward.description,
        ),
        (
          strings.membershipTitle,
          strings.progressOf(
            membership.progress.goal,
            membership.progress.progress,
          ),
        ),
        if (location != null)
          (strings.currentLocationLabel, location.displayName),
      ],
      warning: reward.finalReward
          ? strings.finalResetWarning(membership.progress.goal)
          : null,
      confirmLabel: strings.confirmRedemption,
      onConfirm: () => ref
          .read(m2OperationControllerProvider.notifier)
          .confirmRedemption(
            locale: Localizations.localeOf(context).languageCode,
          ),
      onBack: ref
          .read(m2OperationControllerProvider.notifier)
          .returnToMembership,
    );
  }
}

final class _ReviewList extends StatelessWidget {
  const _ReviewList({
    required this.title,
    required this.rows,
    required this.warning,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onBack,
  });

  final String title;
  final List<(String, String)> rows;
  final String? warning;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
    children: [
      WafloInfoCard(
        title: title,
        icon: Icons.fact_check_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: WafloSpacing.sm),
                child: Text(row.$2.isEmpty ? row.$1 : '${row.$1}: ${row.$2}'),
              ),
            if (warning != null)
              WafloStatusBanner(
                icon: Icons.warning_amber_rounded,
                message: warning!,
                color: WafloColors.warning,
              ),
            const SizedBox(height: WafloSpacing.md),
            FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
            const SizedBox(height: WafloSpacing.sm),
            OutlinedButton(
              onPressed: onBack,
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ],
        ),
      ),
    ],
  );
}

final class _StampSuccess extends ConsumerWidget {
  const _StampSuccess({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final result = state.stampResult!;
    final membership = state.membership;
    return _SuccessLayout(
      title: strings.stampSuccessTitle,
      children: [
        Text(
          strings.stampsIssued(
            result.progress.progress - result.beforeProgress,
          ),
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          strings.progressOf(result.progress.goal, result.progress.progress),
          textAlign: TextAlign.center,
        ),
        if (membership != null)
          TwoStateStampGrid(
            progress: result.progress,
            artwork: membership.stampArtwork,
            cache: ref.watch(stampImageCacheProvider),
            semanticLabel: strings.progressOf(
              result.progress.goal,
              result.progress.progress,
            ),
            allowInsecureAssets:
                ref.watch(environmentProvider).flavor.name == 'development',
          ),
        if (result.rewardReady)
          WafloStatusBanner(
            icon: Icons.info_outline,
            message: strings.rewardReady,
            color: WafloColors.success,
          ),
        for (final reward in result.unlockedRewards)
          ListTile(
            leading: const Icon(Icons.card_giftcard_outlined),
            title: Text(reward.name),
            subtitle: Text('${strings.rewardUnlocked}: ${reward.description}'),
          ),
        Text(
          strings.operationReferenceSuffix(_suffix(result.operationPublicId)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

final class _RedemptionSuccess extends ConsumerWidget {
  const _RedemptionSuccess({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final result = state.redemptionResult!;
    final membership = state.membership;
    return _SuccessLayout(
      title: strings.redemptionSuccessTitle,
      children: [
        Text(
          result.reward.name,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          result.reward.finalReward
              ? strings.cycleResetComplete(result.progress.goal)
              : strings.progressUnchanged,
          textAlign: TextAlign.center,
        ),
        if (membership != null)
          TwoStateStampGrid(
            progress: result.progress,
            artwork: membership.stampArtwork,
            cache: ref.watch(stampImageCacheProvider),
            semanticLabel: strings.progressOf(
              result.progress.goal,
              result.progress.progress,
            ),
            allowInsecureAssets:
                ref.watch(environmentProvider).flavor.name == 'development',
          ),
        Text(
          strings.operationReferenceSuffix(_suffix(result.operationPublicId)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

final class _SuccessLayout extends ConsumerWidget {
  const _SuccessLayout({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
        children: [
          WafloInfoCard(
            title: title,
            icon: Icons.check_circle_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                const SizedBox(height: WafloSpacing.md),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(m2OperationControllerProvider.notifier)
                        .acknowledgeAndReset();
                    if (context.mounted) {
                      ref
                          .read(m2OperationControllerProvider.notifier)
                          .startScanning();
                    }
                  },
                  child: Text(strings.scanNextCustomer),
                ),
                const SizedBox(height: WafloSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(m2OperationControllerProvider.notifier)
                        .acknowledgeAndReset();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  },
                  child: Text(strings.done),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _PendingRecovery extends ConsumerWidget {
  const _PendingRecovery({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final online = ref.watch(connectivityProvider).value ?? false;
    return _CenteredOperation(
      child: WafloInfoCard(
        title: strings.pendingOperationTitle,
        icon: Icons.hourglass_top_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.pendingOperationBody),
            if (state.failure != null)
              Text(strings.m2ErrorMessage(state.failure?.safeCode)),
            const SizedBox(height: WafloSpacing.md),
            FilledButton(
              onPressed: online
                  ? ref
                        .read(m2OperationControllerProvider.notifier)
                        .recoverPending
                  : null,
              child: Text(strings.checkStatus),
            ),
            const SizedBox(height: WafloSpacing.sm),
            OutlinedButton(
              onPressed: () {
                ref
                    .read(m2OperationControllerProvider.notifier)
                    .cancelLocalRecoveryView();
                context.go('/home');
              },
              child: Text(strings.dismissRecovery),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ManagerApprovalPanel extends ConsumerWidget {
  const _ManagerApprovalPanel({required this.reward});

  final AvailableReward? reward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return _CenteredOperation(
      child: WafloInfoCard(
        title: strings.managerApprovalRequired,
        icon: Icons.admin_panel_settings_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (reward != null) Text(reward!.name),
            Text(strings.managerApprovalBody),
            const SizedBox(height: WafloSpacing.md),
            OutlinedButton(
              onPressed: ref
                  .read(m2OperationControllerProvider.notifier)
                  .returnToMembership,
              child: Text(strings.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FailureState extends ConsumerWidget {
  const _FailureState({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final expiredRecovery =
        state.failure?.safeCode == 'OPERATION_RECOVERY_EXPIRED';
    return _CenteredOperation(
      child: _ErrorPanel(
        icon: state.stage == M2OperationStage.networkUnavailable
            ? Icons.cloud_off_outlined
            : Icons.error_outline,
        message: strings.m2ErrorMessage(state.failure?.safeCode),
        requestId: state.failure?.requestId,
        onRetry:
            state.stage == M2OperationStage.sessionBlocked ||
                state.stage == M2OperationStage.fatalContractError ||
                expiredRecovery
            ? null
            : () async {
                await ref
                    .read(m2OperationControllerProvider.notifier)
                    .acknowledgeAndReset();
                ref
                    .read(m2OperationControllerProvider.notifier)
                    .startScanning();
              },
      ),
    );
  }
}

final class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.icon,
    required this.message,
    required this.requestId,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final String? requestId;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: WafloInfoCard(
        title: strings.genericError,
        icon: icon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            if (requestId != null) Text(strings.requestReference(requestId!)),
            if (onRetry != null) ...[
              const SizedBox(height: WafloSpacing.md),
              FilledButton(onPressed: onRetry, child: Text(strings.retry)),
            ],
          ],
        ),
      ),
    );
  }
}

final class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => _CenteredOperation(
    child: Semantics(
      liveRegion: true,
      label: message,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: WafloSpacing.md),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

final class _CenteredOperation extends StatelessWidget {
  const _CenteredOperation({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: child,
      ),
    ),
  );
}

String _suffix(String value) =>
    value.length <= 8 ? value : value.substring(value.length - 8);
