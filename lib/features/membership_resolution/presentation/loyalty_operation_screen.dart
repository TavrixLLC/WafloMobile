import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/localization/localization_extensions.dart';
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
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
      unawaited(_adapter?.background());
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
    return ValueListenableBuilder<CustomerScannerState>(
      valueListenable: adapter.state,
      builder: (context, scannerState, child) => Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                adapter.buildPreview(
                  context,
                  onDetected: (candidate) => ref
                      .read(m2OperationControllerProvider.notifier)
                      .resolveCandidate(
                        candidate,
                        locale: Localizations.localeOf(context).languageCode,
                      ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x99000000),
                        Color(0x00000000),
                        Color(0xB3000000),
                      ],
                      stops: [0, 0.5, 1],
                    ),
                  ),
                ),
                Center(
                  child: Semantics(
                    label: strings.scanFrameLabel,
                    image: true,
                    child: const _ScannerFrame(),
                  ),
                ),
                PositionedDirectional(
                  start: WafloSpacing.lg,
                  end: WafloSpacing.lg,
                  top: WafloSpacing.lg,
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.m2ScannerInstructions,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
                if (_isScannerBusy(scannerState))
                  ColoredBox(
                    color: const Color(0xB30D1814),
                    child: Center(
                      child: Semantics(
                        liveRegion: true,
                        label: _scannerStatus(strings, scannerState),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: WafloSpacing.md),
                            Text(
                              _scannerStatus(strings, scannerState),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (scannerState == CustomerScannerState.cameraPermissionDenied)
                  ColoredBox(
                    color: const Color(0xF20D1814),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(
                          WafloSpacing.xl,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.no_photography_outlined,
                              size: 52,
                              color: Colors.white,
                            ),
                            const SizedBox(height: WafloSpacing.md),
                            Text(
                              strings.cameraPermissionDeniedTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: WafloSpacing.sm),
                            Text(
                              strings.cameraPermissionDeniedBody,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: WafloSpacing.lg),
                            FilledButton(
                              onPressed: () => unawaited(openAppSettings()),
                              child: Text(strings.openSettings),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: adapter.torchEnabled,
                    builder: (context, enabled, child) => Tooltip(
                      message: strings.toggleFlash,
                      child: OutlinedButton.icon(
                        onPressed: () => unawaited(adapter.toggleTorch()),
                        icon: Icon(
                          enabled
                              ? Icons.flashlight_off_rounded
                              : Icons.flashlight_on_rounded,
                        ),
                        label: Text(
                          enabled ? strings.flashOff : strings.flashOn,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: WafloSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      unawaited(adapter.stop());
                      unawaited(
                        ref
                            .read(m2OperationControllerProvider.notifier)
                            .acknowledgeAndReset(),
                      );
                      context.go('/home');
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: Text(strings.cancel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static bool _isScannerBusy(CustomerScannerState state) =>
      state == CustomerScannerState.requestingPermission ||
      state == CustomerScannerState.candidateCaptured ||
      state == CustomerScannerState.resolving;

  static String _scannerStatus(
    AppLocalizations strings,
    CustomerScannerState state,
  ) => switch (state) {
    CustomerScannerState.requestingPermission => strings.requestingCamera,
    CustomerScannerState.candidateCaptured => strings.codeDetected,
    CustomerScannerState.resolving => strings.scannerResolving,
    _ => strings.scannerReady,
  };
}

final class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('customer-scanner-frame'),
    width: 252,
    height: 252,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white, width: 3),
    ),
  );
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
    return ListView(
      key: const Key('customer-membership-screen'),
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
      children: [
        Semantics(
          container: true,
          label:
              '${membership.customerDisplayName}. ${membership.programName}. ${strings.localizeMembershipStatus(membership.status.name)}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WafloOperationalLabel(membership.programName),
              const SizedBox(height: WafloSpacing.sm),
              Text(
                membership.customerDisplayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: WafloSpacing.sm),
              Row(
                children: [
                  const WafloReadyBeacon(size: 20),
                  const SizedBox(width: WafloSpacing.sm),
                  Text(
                    strings.localizeMembershipStatus(membership.status.name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.waflo.counter,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: WafloSpacing.xl),
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(WafloRadius.stage),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: WafloSpacing.md,
                runSpacing: WafloSpacing.sm,
                children: [
                  WafloOperationalLabel(strings.currentProgress),
                  Text(
                    '${membership.progress.progress}/${membership.progress.goal}',
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: WafloSpacing.xs),
              ExcludeSemantics(
                child: Text(
                  strings.progressOf(
                    membership.progress.goal,
                    membership.progress.progress,
                  ),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                membership.rewardReady
                    ? strings.rewardReady
                    : strings.stampsUntilReward(
                        membership.progress.goal - membership.progress.progress,
                      ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        if (membership.rewardReady) ...[
          const SizedBox(height: WafloSpacing.md),
          Container(
            key: const Key('reward-ready-outside-grid'),
            padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
            decoration: BoxDecoration(
              color: context.waflo.readySurface,
              borderRadius: BorderRadius.circular(WafloRadius.card),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WafloReadyBeacon(size: 34),
                const SizedBox(width: WafloSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.rewardReady,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.waflo.onReadySurface,
                        ),
                      ),
                      Text(
                        strings.rewardReadyBody,
                        style: TextStyle(color: context.waflo.onReadySurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: WafloSpacing.xl),
        if (membership.earningAllowed) ...[
          Container(
            padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(WafloRadius.card),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.stampAmount,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: WafloSpacing.md),
                Semantics(
                  value: _amount.toString(),
                  label: strings.stampAmount,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: '${strings.stampAmount} -',
                        onPressed: _amount > 1
                            ? () => setState(() => _amount -= 1)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_amount',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: '${strings.stampAmount} +',
                        onPressed: _amount < maximum
                            ? () => setState(() => _amount += 1)
                            : null,
                        icon: const Icon(Icons.add_rounded),
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
                  key: const Key('review-stamp-operation'),
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
          const SizedBox(height: WafloSpacing.lg),
        ],
        if (!widget.online) ...[
          WafloStatusBanner(
            icon: Icons.cloud_off_outlined,
            message:
                '${strings.offlineOperationsBlocked} ${strings.noOfflineQueue}',
            color: WafloColors.signalAmber,
            backgroundColor: context.waflo.warningSurface,
          ),
          const SizedBox(height: WafloSpacing.md),
        ],
        if (!widget.state.credentialAvailable) ...[
          WafloStatusBanner(
            icon: Icons.qr_code_scanner,
            message: strings.rescanRequired,
            color: WafloColors.signalAmber,
            backgroundColor: context.waflo.warningSurface,
          ),
          const SizedBox(height: WafloSpacing.md),
        ],
        if (membership.availableRewards.isNotEmpty) ...[
          WafloOperationalLabel(strings.rewardsTitle),
          const SizedBox(height: WafloSpacing.sm),
          for (final reward in membership.availableRewards) ...[
            _RewardTile(
              reward: reward,
              redemptionAllowed:
                  membership.redemptionAllowed &&
                  widget.online &&
                  widget.state.credentialAvailable,
            ),
            const SizedBox(height: WafloSpacing.sm),
          ],
        ],
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
    return Container(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
      decoration: BoxDecoration(
        color: context.waflo.readySurface,
        borderRadius: BorderRadius.circular(WafloRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            reward.finalReward ? strings.finalReward : strings.milestoneReward,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.waflo.onReadySurface,
            ),
          ),
          const SizedBox(height: WafloSpacing.xs),
          Text(
            reward.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: context.waflo.onReadySurface,
            ),
          ),
          if (reward.description.isNotEmpty) ...[
            const SizedBox(height: WafloSpacing.xs),
            Text(
              reward.description,
              style: TextStyle(color: context.waflo.onReadySurface),
            ),
          ],
          const SizedBox(height: WafloSpacing.sm),
          Text(
            strings.thresholdLabel(reward.threshold),
            style: TextStyle(color: context.waflo.onReadySurface),
          ),
          if (expiration != null)
            Text(
              strings.expirationLabel(expiration),
              style: TextStyle(color: context.waflo.onReadySurface),
            ),
          if (reward.requiresManagerApproval)
            Text(
              strings.managerApprovalRequired,
              style: const TextStyle(
                color: WafloColors.signalAmber,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton(
            onPressed: redemptionAllowed || reward.requiresManagerApproval
                ? () => ref
                      .read(m2OperationControllerProvider.notifier)
                      .prepareRedemption(reward, locale: locale)
                : null,
            child: Text(strings.redeem),
          ),
        ],
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
        if (input.merchantTransactionReference?.isNotEmpty ?? false)
          (strings.transactionReference, input.merchantTransactionReference!),
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
    key: const Key('operation-confirmation'),
    padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
    children: [
      const Align(child: WafloReadyBeacon(size: 54)),
      const SizedBox(height: WafloSpacing.lg),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: WafloSpacing.xl),
      Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(WafloRadius.card),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            for (var index = 0; index < rows.length; index += 1)
              WafloSummaryRow(
                label: rows[index].$2.isEmpty ? '' : rows[index].$1,
                value: rows[index].$2.isEmpty ? rows[index].$1 : rows[index].$2,
                divider: index != rows.length - 1,
              ),
          ],
        ),
      ),
      if (warning != null) ...[
        const SizedBox(height: WafloSpacing.md),
        WafloStatusBanner(
          icon: Icons.info_outline_rounded,
          message: warning!,
          color: WafloColors.signalAmber,
          backgroundColor: context.waflo.warningSurface,
        ),
      ],
      const SizedBox(height: WafloSpacing.xl),
      FilledButton(
        key: const Key('confirm-operation'),
        onPressed: onConfirm,
        child: Text(confirmLabel),
      ),
      const SizedBox(height: WafloSpacing.sm),
      OutlinedButton(
        onPressed: onBack,
        child: Text(AppLocalizations.of(context).cancel),
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
          style: Theme.of(context).textTheme.headlineSmall,
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
          Container(
            key: const Key('success-reward-ready'),
            padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
            decoration: BoxDecoration(
              color: context.waflo.readySurface,
              borderRadius: BorderRadius.circular(WafloRadius.compact),
            ),
            child: Text(
              strings.rewardReady,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.waflo.onReadySurface,
              ),
            ),
          ),
        if (result.unlockedRewards.isNotEmpty)
          WafloStatusBanner(
            icon: Icons.info_outline,
            message: strings.rewardUnlocked,
            color: WafloColors.success,
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
        if (state.selectedReward != null)
          Text(
            state.selectedReward!.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        Text(
          result.finalReward
              ? '${strings.newCycleStarted}. ${strings.cycleResetComplete(result.progress.goal)}'
              : strings.progressUnchanged,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
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
        key: const Key('operation-success'),
        padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
        children: [
          const Align(child: WafloReadyBeacon(size: 72)),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: WafloSpacing.lg),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: WafloSpacing.md),
              child: child,
            ),
          ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton.icon(
            key: const Key('scan-next-customer'),
            onPressed: () async {
              await ref
                  .read(m2OperationControllerProvider.notifier)
                  .resetForNextCustomer();
              if (context.mounted) {
                ref
                    .read(m2OperationControllerProvider.notifier)
                    .startScanning();
              }
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(strings.scanNextCustomer),
          ),
          const SizedBox(height: WafloSpacing.sm),
          OutlinedButton(
            onPressed: () async {
              await ref
                  .read(m2OperationControllerProvider.notifier)
                  .acknowledgeAndReset();
              if (context.mounted) context.go('/home');
            },
            child: Text(strings.done),
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
      child: Container(
        key: const Key('ambiguous-operation-recovery'),
        padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
        decoration: BoxDecoration(
          color: context.waflo.warningSurface,
          borderRadius: BorderRadius.circular(WafloRadius.stage),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              child: Icon(
                Icons.sync_problem_rounded,
                size: 54,
                color: WafloColors.signalAmber,
              ),
            ),
            const SizedBox(height: WafloSpacing.md),
            Text(
              strings.checkingTransaction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: context.waflo.onWarningSurface,
              ),
            ),
            const SizedBox(height: WafloSpacing.sm),
            Text(
              strings.connectionInterruptedAfterSend,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.waflo.onWarningSurface),
            ),
            const SizedBox(height: WafloSpacing.sm),
            Text(
              strings.pendingDoNotScanAgain,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.waflo.onWarningSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (state.failure != null) ...[
              const SizedBox(height: WafloSpacing.sm),
              Text(
                strings.m2ErrorMessage(state.failure?.safeCode),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.waflo.onWarningSurface),
              ),
            ],
            const SizedBox(height: WafloSpacing.lg),
            FilledButton(
              onPressed: online
                  ? ref
                        .read(m2OperationControllerProvider.notifier)
                        .recoverPending
                  : null,
              child: Text(strings.checkAgain),
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
    required this.onRetry,
  });

  final IconData icon;
  final String message;
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
