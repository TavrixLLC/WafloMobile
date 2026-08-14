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
import 'package:waflo_staff/features/customer_scan/presentation/professional_scanner_overlay.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls.dart';
import 'package:waflo_staff/features/loyalty_progress/presentation/two_state_stamp_grid.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
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
        state.stage == M2OperationStage.redemptionSubmitting ||
        state.managerApprovalState == ManagerApprovalState.checking;
    final approvalPending =
        state.stage == M2OperationStage.managerApprovalRequired &&
        state.managerApprovalState?.canCheck == true;
    final scanning =
        state.stage == M2OperationStage.scanning ||
        state.stage == M2OperationStage.resolving ||
        state.stage == M2OperationStage.networkUnavailable;
    return PopScope(
      canPop: !submitting,
      child: Scaffold(
        backgroundColor: scanning ? WafloColors.darkCanvas : null,
        appBar: scanning
            ? null
            : AppBar(
                title: Text(_title(strings, state.stage)),
                leading: submitting
                    ? null
                    : IconButton(
                        tooltip: strings.close,
                        onPressed: () async {
                          if (state.stage == M2OperationStage.stampAmbiguous ||
                              state.stage ==
                                  M2OperationStage.redemptionAmbiguous ||
                              approvalPending) {
                            controller.cancelLocalRecoveryView();
                          } else {
                            await controller.acknowledgeAndReset();
                          }
                          if (context.mounted) context.go('/home');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
        body: scanning
            ? _OperationBody(state: state, controller: controller)
            : SafeArea(
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
    final online = ref.watch(operationalOnlineProvider);
    if (!online &&
        state.stage != M2OperationStage.membershipReady &&
        state.stage != M2OperationStage.stampAmbiguous &&
        state.stage != M2OperationStage.redemptionAmbiguous &&
        state.stage != M2OperationStage.managerApprovalRequired &&
        state.stage != M2OperationStage.stampSucceeded &&
        state.stage != M2OperationStage.redemptionSucceeded) {
      return _CenteredOperation(
        child: _ErrorPanel(
          icon: Icons.cloud_off_outlined,
          message: AppLocalizations.of(context).offlineOperationsBlocked,
          actionLabel: AppLocalizations.of(context).scanNextCustomer,
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
      M2OperationStage.scanning ||
      M2OperationStage.resolving ||
      M2OperationStage.networkUnavailable => const _CustomerScannerView(),
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
        state: state,
        online: online,
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
  String? _reportedFailureCode;
  Timer? _invalidRecovery;

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
    if (state == AppLifecycleState.resumed) {
      unawaited(_adapter?.foreground());
    } else {
      unawaited(_adapter?.background());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _invalidRecovery?.cancel();
    unawaited(_adapter?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final adapter = ref.watch(customerScannerAdapterProvider);
    final operation = ref.watch(m2OperationControllerProvider);
    final location = ref.watch(activeDeviceContextProvider)?.currentLocation;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    _adapter = adapter;
    _reportFailure(operation, adapter);
    return ValueListenableBuilder<CustomerScannerState>(
      valueListenable: adapter.state,
      builder: (context, scannerState, child) => Stack(
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
          ProfessionalScannerOverlay(
            state: scannerState,
            semanticLabel: strings.scanFrameLabel,
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    _ScannerRoundAction(
                      tooltip: strings.close,
                      icon: Icons.close_rounded,
                      onPressed: () => unawaited(_close(adapter)),
                    ),
                    const SizedBox(width: WafloSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.m2ScannerTitle,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style:
                                (largeText
                                        ? Theme.of(
                                            context,
                                          ).textTheme.titleMedium
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleLarge)
                                    ?.copyWith(color: Colors.white),
                          ),
                          if (location != null)
                            Text(
                              location.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _scannerInstruction(strings, scannerState),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      shadows: const [Shadow(blurRadius: 8)],
                    ),
                  ),
                ),
                const SizedBox(height: WafloSpacing.md),
                _ScannerStatusPill(
                  label: _scannerStatus(strings, scannerState),
                  busy: _isScannerBusy(scannerState),
                ),
                const SizedBox(height: WafloSpacing.md),
                if (_requiresExplicitRetry(scannerState)) ...[
                  OutlinedButton.icon(
                    key: const Key('scanner-resolve-retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: () => unawaited(_retry(adapter)),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.retry),
                  ),
                  const SizedBox(height: WafloSpacing.sm),
                ],
                const LocalDemoScannerControlsSlot(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: adapter.torchEnabled,
                      builder: (context, enabled, child) => _ScannerRoundAction(
                        tooltip: strings.toggleFlash,
                        label: enabled ? strings.flashOff : strings.flashOn,
                        icon: enabled
                            ? Icons.flashlight_off_rounded
                            : Icons.flashlight_on_rounded,
                        onPressed: () => unawaited(adapter.toggleTorch()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isPermissionFailure(scannerState))
            _ScannerPermissionPanel(
              permanentlyDenied:
                  scannerState ==
                  CustomerScannerState.cameraPermissionPermanentlyDenied,
              onRetry: () => unawaited(adapter.resetForExplicitRetry()),
            ),
        ],
      ),
    );
  }

  Future<void> _close(CustomerScannerAdapter adapter) async {
    await adapter.stop();
    await ref
        .read(m2OperationControllerProvider.notifier)
        .acknowledgeAndReset();
    if (mounted) context.go('/home');
  }

  void _reportFailure(
    M2OperationState operation,
    CustomerScannerAdapter adapter,
  ) {
    final failure =
        operation.stage == M2OperationStage.scanning ||
            operation.stage == M2OperationStage.networkUnavailable
        ? operation.failure
        : null;
    if (failure == null || failure.safeCode == _reportedFailureCode) return;
    _reportedFailureCode = failure.safeCode;
    final scannerFailure = switch (failure.safeCode) {
      'MEMBERSHIP_CREDENTIAL_INVALID' => CustomerScannerState.invalidQr,
      'BACKEND_UNAVAILABLE' => CustomerScannerState.networkFailure,
      _ => CustomerScannerState.resolveFailed,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      adapter.reportResolveFailure(scannerFailure);
      if (scannerFailure == CustomerScannerState.invalidQr) {
        _invalidRecovery?.cancel();
        _invalidRecovery = Timer(const Duration(milliseconds: 1400), () {
          if (mounted) unawaited(_retry(adapter));
        });
      }
    });
  }

  Future<void> _retry(CustomerScannerAdapter adapter) async {
    _invalidRecovery?.cancel();
    _reportedFailureCode = null;
    ref
        .read(m2OperationControllerProvider.notifier)
        .clearScannerFailureForRetry();
    await adapter.resetForExplicitRetry();
  }

  static bool _isScannerBusy(CustomerScannerState state) =>
      state == CustomerScannerState.requestingPermission ||
      state == CustomerScannerState.initializingCamera ||
      state == CustomerScannerState.candidateCaptured ||
      state == CustomerScannerState.resolving;

  static bool _isPermissionFailure(CustomerScannerState state) =>
      state == CustomerScannerState.cameraPermissionRequired ||
      state == CustomerScannerState.cameraPermissionDenied ||
      state == CustomerScannerState.cameraPermissionPermanentlyDenied;

  static bool _requiresExplicitRetry(CustomerScannerState state) =>
      state == CustomerScannerState.expiredQr ||
      state == CustomerScannerState.networkFailure ||
      state == CustomerScannerState.resolveFailed;

  static String _scannerInstruction(
    AppLocalizations strings,
    CustomerScannerState state,
  ) => switch (state) {
    CustomerScannerState.candidateCaptured ||
    CustomerScannerState.resolving ||
    CustomerScannerState.networkFailure ||
    CustomerScannerState.resolveFailed => strings.codeDetected,
    CustomerScannerState.invalidQr ||
    CustomerScannerState.expiredQr => strings.scanCustomerHelp,
    _ => strings.scanCustomerHelp,
  };

  static String _scannerStatus(
    AppLocalizations strings,
    CustomerScannerState state,
  ) => switch (state) {
    CustomerScannerState.requestingPermission => strings.requestingCamera,
    CustomerScannerState.initializingCamera => strings.initializingCamera,
    CustomerScannerState.candidateCaptured => strings.codeDetected,
    CustomerScannerState.resolving => strings.scannerResolving,
    CustomerScannerState.customerResolved => strings.customerLoaded,
    CustomerScannerState.invalidQr => strings.invalidCustomerQr,
    CustomerScannerState.expiredQr => strings.expiredCustomerQr,
    CustomerScannerState.networkFailure => strings.unableToLoadCustomer,
    CustomerScannerState.resolveFailed => strings.unableToLoadCustomer,
    CustomerScannerState.cameraUnavailable => strings.cameraUnavailable,
    _ => strings.scannerReady,
  };
}

final class _ScannerRoundAction extends StatelessWidget {
  const _ScannerRoundAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: const Color(0xB3091713),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: label == null ? 12 : 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                if (label != null) ...[
                  const SizedBox(width: WafloSpacing.xs),
                  Text(
                    label!,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class _ScannerStatusPill extends StatelessWidget {
  const _ScannerStatusPill({required this.label, required this.busy});

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xCC091713),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            if (busy) ...[
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: WafloColors.coral,
                ),
              ),
              const SizedBox(width: WafloSpacing.sm),
            ] else ...[
              const Icon(
                Icons.center_focus_strong_rounded,
                size: 18,
                color: WafloColors.coral,
              ),
              const SizedBox(width: WafloSpacing.sm),
            ],
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

final class _ScannerPermissionPanel extends StatelessWidget {
  const _ScannerPermissionPanel({
    required this.permanentlyDenied,
    required this.onRetry,
  });

  final bool permanentlyDenied;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: const Color(0xF2091713),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(WafloSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.no_photography_outlined,
                    size: 56,
                    color: WafloColors.coral,
                  ),
                  const SizedBox(height: WafloSpacing.lg),
                  Text(
                    permanentlyDenied
                        ? strings.cameraPermissionDeniedTitle
                        : strings.cameraPermissionRequiredTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: WafloSpacing.sm),
                  Text(
                    permanentlyDenied
                        ? strings.cameraPermissionDeniedBody
                        : strings.cameraPermissionRequiredBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: WafloSpacing.xl),
                  FilledButton.icon(
                    onPressed: permanentlyDenied
                        ? () => unawaited(openAppSettings())
                        : onRetry,
                    icon: Icon(
                      permanentlyDenied
                          ? Icons.settings_outlined
                          : Icons.camera_alt_outlined,
                    ),
                    label: Text(
                      permanentlyDenied ? strings.openSettings : strings.retry,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                      color: context.waflo.brandAction,
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
            borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
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
              color: context.waflo.successSurface,
              borderRadius: BorderRadius.circular(WafloRadius.large),
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
                          color: context.waflo.onSuccessSurface,
                        ),
                      ),
                      Text(
                        strings.rewardReadyBody,
                        style: TextStyle(color: context.waflo.onSuccessSurface),
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
              borderRadius: BorderRadius.circular(WafloRadius.large),
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
            color: WafloColors.warning,
            backgroundColor: context.waflo.warningSurface,
          ),
          const SizedBox(height: WafloSpacing.md),
        ],
        if (!widget.state.credentialAvailable) ...[
          WafloStatusBanner(
            icon: Icons.qr_code_scanner,
            message: strings.rescanRequired,
            color: WafloColors.warning,
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
        color: context.waflo.successSurface,
        borderRadius: BorderRadius.circular(WafloRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            reward.finalReward ? strings.finalReward : strings.milestoneReward,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.waflo.onSuccessSurface,
            ),
          ),
          const SizedBox(height: WafloSpacing.xs),
          Text(
            reward.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: context.waflo.onSuccessSurface,
            ),
          ),
          if (reward.description.isNotEmpty) ...[
            const SizedBox(height: WafloSpacing.xs),
            Text(
              reward.description,
              style: TextStyle(color: context.waflo.onSuccessSurface),
            ),
          ],
          const SizedBox(height: WafloSpacing.sm),
          Text(
            strings.thresholdLabel(reward.threshold),
            style: TextStyle(color: context.waflo.onSuccessSurface),
          ),
          if (expiration != null)
            Text(
              strings.expirationLabel(expiration),
              style: TextStyle(color: context.waflo.onSuccessSurface),
            ),
          if (reward.requiresManagerApproval)
            Text(
              strings.managerApprovalRequired,
              style: const TextStyle(
                color: WafloColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton(
            onPressed: redemptionAllowed
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
    final location = ref.watch(activeDeviceContextProvider)?.currentLocation;
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
    final location = ref.watch(activeDeviceContextProvider)?.currentLocation;
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
          borderRadius: BorderRadius.circular(WafloRadius.large),
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
          color: WafloColors.warning,
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
              color: context.waflo.successSurface,
              borderRadius: BorderRadius.circular(WafloRadius.medium),
            ),
            child: Text(
              strings.rewardReady,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.waflo.onSuccessSurface,
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
      child: CustomScrollView(
        key: const Key('operation-success'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 18, 24, 0),
            sliver: SliverList.list(
              children: [
                const Align(child: WafloReadyBeacon(size: 72)),
                const SizedBox(height: WafloSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: WafloSpacing.lg),
                Container(
                  padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: children
                        .map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: WafloSpacing.md,
                            ),
                            child: child,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 32),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
    final online = ref.watch(operationalOnlineProvider);
    return _CenteredOperation(
      child: Container(
        key: const Key('ambiguous-operation-recovery'),
        padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
        decoration: BoxDecoration(
          color: context.waflo.warningSurface,
          borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              child: Icon(
                Icons.sync_problem_rounded,
                size: 54,
                color: WafloColors.warning,
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
  const _ManagerApprovalPanel({required this.state, required this.online});

  final M2OperationState state;
  final bool online;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final approval = state.managerApprovalState ?? ManagerApprovalState.invalid;
    final presentation = _approvalPresentation(context, strings, approval);
    final controller = ref.read(m2OperationControllerProvider.notifier);
    final locale = Localizations.localeOf(context).languageCode;
    final reward = state.selectedReward;
    final membership = state.membership;
    return _CenteredOperation(
      child: Semantics(
        liveRegion: true,
        container: true,
        label: '${presentation.title}. ${presentation.body}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
              decoration: BoxDecoration(
                color: presentation.background,
                borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: presentation.foreground.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: approval == ManagerApprovalState.checking
                        ? Padding(
                            padding: const EdgeInsetsDirectional.all(22),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: presentation.foreground,
                            ),
                          )
                        : Icon(
                            presentation.icon,
                            size: 36,
                            color: presentation.foreground,
                          ),
                  ),
                  const SizedBox(height: WafloSpacing.md),
                  Text(
                    presentation.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: presentation.foreground,
                    ),
                  ),
                  const SizedBox(height: WafloSpacing.sm),
                  Text(
                    presentation.body,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (membership != null || reward != null) ...[
              const SizedBox(height: WafloSpacing.md),
              WafloInfoCard(
                title: reward?.name ?? strings.finalReward,
                icon: Icons.redeem_rounded,
                child: Text(
                  [
                    if (membership != null) membership.customerDisplayName,
                    if (membership != null) membership.programName,
                  ].join(' · '),
                ),
              ),
            ],
            const SizedBox(height: WafloSpacing.md),
            _ApprovalHandoffRail(strings: strings, approvalState: approval),
            const SizedBox(height: WafloSpacing.md),
            WafloStatusBanner(
              icon: Icons.shield_outlined,
              message: strings.approvalNoMutation,
              color: context.waflo.brandAction,
            ),
            const SizedBox(height: WafloSpacing.lg),
            if (approval.canCheck)
              FilledButton.icon(
                key: const Key('manager-approval-check'),
                onPressed: online
                    ? () => controller.checkManagerApproval(locale: locale)
                    : null,
                icon: const Icon(Icons.sync_rounded),
                label: Text(strings.managerApprovalCheck),
              )
            else if (approval != ManagerApprovalState.checking)
              FilledButton.icon(
                key: const Key('manager-approval-rescan'),
                onPressed: () async {
                  await controller.acknowledgeAndReset();
                  controller.startScanning();
                  if (context.mounted) context.go('/loyalty');
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(
                  approval.requiresNewIntent
                      ? strings.startNewRedemption
                      : strings.refreshCustomerState,
                ),
              ),
            if (approval.canCheck)
              LocalDemoManagerApprovalAction(locale: locale),
            if (approval.canCheck) ...[
              const SizedBox(height: WafloSpacing.sm),
              TextButton(
                onPressed: () {
                  controller.cancelLocalRecoveryView();
                  context.go('/home');
                },
                child: Text(strings.dismissRecovery),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static _ApprovalPresentation _approvalPresentation(
    BuildContext context,
    AppLocalizations strings,
    ManagerApprovalState state,
  ) => switch (state) {
    ManagerApprovalState.required => _ApprovalPresentation(
      strings.managerApprovalRequired,
      strings.managerApprovalBody,
      Icons.approval_outlined,
      context.waflo.onWarningSurface,
      context.waflo.warningSurface,
    ),
    ManagerApprovalState.pending => _ApprovalPresentation(
      strings.managerApprovalPending,
      strings.managerApprovalPendingBody,
      Icons.hourglass_top_rounded,
      context.waflo.onWarningSurface,
      context.waflo.warningSurface,
    ),
    ManagerApprovalState.checking => _ApprovalPresentation(
      strings.managerApprovalChecking,
      strings.managerApprovalCheckingBody,
      Icons.sync_rounded,
      context.waflo.onSuccessSurface,
      context.waflo.successSurface,
    ),
    ManagerApprovalState.rejected => _ApprovalPresentation(
      strings.managerApprovalRejectedTitle,
      strings.managerApprovalRejectedBody,
      Icons.do_not_disturb_alt_rounded,
      context.waflo.onDangerSurface,
      context.waflo.dangerSurface,
    ),
    ManagerApprovalState.expired => _ApprovalPresentation(
      strings.managerApprovalExpiredTitle,
      strings.managerApprovalExpiredBody,
      Icons.timer_off_outlined,
      context.waflo.onWarningSurface,
      context.waflo.warningSurface,
    ),
    ManagerApprovalState.consumed => _ApprovalPresentation(
      strings.managerApprovalConsumedTitle,
      strings.managerApprovalConsumedBody,
      Icons.history_rounded,
      context.waflo.onWarningSurface,
      context.waflo.warningSurface,
    ),
    ManagerApprovalState.stale => _ApprovalPresentation(
      strings.managerApprovalStaleTitle,
      strings.managerApprovalStaleBody,
      Icons.refresh_rounded,
      context.waflo.onWarningSurface,
      context.waflo.warningSurface,
    ),
    ManagerApprovalState.approverInactive => _ApprovalPresentation(
      strings.managerApproverInactiveTitle,
      strings.managerApproverInactiveBody,
      Icons.person_off_outlined,
      context.waflo.onDangerSurface,
      context.waflo.dangerSurface,
    ),
    _ => _ApprovalPresentation(
      strings.managerApprovalInvalidTitle,
      strings.managerApprovalInvalidBody,
      Icons.shield_outlined,
      context.waflo.onDangerSurface,
      context.waflo.dangerSurface,
    ),
  };
}

final class _ApprovalHandoffRail extends StatelessWidget {
  const _ApprovalHandoffRail({
    required this.strings,
    required this.approvalState,
  });

  final AppLocalizations strings;
  final ManagerApprovalState approvalState;

  @override
  Widget build(BuildContext context) {
    final active =
        approvalState == ManagerApprovalState.required ||
            approvalState == ManagerApprovalState.pending
        ? 1
        : 2;
    final labels = [
      strings.approvalStepRequested,
      strings.approvalStepMerchant,
      strings.approvalStepComplete,
    ];
    return Container(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(WafloRadius.large),
      ),
      child: Column(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: index < active
                        ? context.waflo.brandAction
                        : index == active
                        ? context.waflo.warningSurface
                        : Theme.of(context).colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index < active
                        ? Icons.check_rounded
                        : index == 1
                        ? Icons.language_rounded
                        : Icons.smartphone_rounded,
                    size: 18,
                    color: index < active
                        ? context.waflo.onBrandAction
                        : index == active
                        ? context.waflo.onWarningSurface
                        : context.waflo.subtleText,
                  ),
                ),
                const SizedBox(width: WafloSpacing.sm),
                Expanded(
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: index <= active ? null : context.waflo.subtleText,
                    ),
                  ),
                ),
              ],
            ),
            if (index != labels.length - 1)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  margin: const EdgeInsetsDirectional.only(start: 15),
                  width: 2,
                  height: 18,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

final class _ApprovalPresentation {
  const _ApprovalPresentation(
    this.title,
    this.body,
    this.icon,
    this.foreground,
    this.background,
  );

  final String title;
  final String body;
  final IconData icon;
  final Color foreground;
  final Color background;
}

final class _FailureState extends ConsumerWidget {
  const _FailureState({required this.state});

  final M2OperationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final expiredRecovery =
        state.failure?.safeCode == 'OPERATION_RECOVERY_EXPIRED';
    final thresholdCorrection =
        state.failure?.safeCode == 'PURCHASE_THRESHOLD_NOT_MET' &&
        state.credentialAvailable &&
        state.pendingOperation == null;
    final billingBlocked =
        state.failure?.safeCode == 'OPERATION_BILLING_BLOCKED';
    final controller = ref.read(m2OperationControllerProvider.notifier);
    return _CenteredOperation(
      child: _ErrorPanel(
        icon: state.stage == M2OperationStage.networkUnavailable
            ? Icons.cloud_off_outlined
            : Icons.error_outline,
        message: strings.m2ErrorMessage(state.failure?.safeCode),
        actionLabel: thresholdCorrection
            ? strings.reviewDetails
            : billingBlocked
            ? strings.dismissRecovery
            : strings.scanNextCustomer,
        actionIcon: thresholdCorrection
            ? Icons.edit_outlined
            : billingBlocked
            ? Icons.home_outlined
            : Icons.qr_code_scanner_rounded,
        onRetry:
            state.stage == M2OperationStage.sessionBlocked ||
                state.stage == M2OperationStage.fatalContractError ||
                expiredRecovery
            ? null
            : thresholdCorrection
            ? controller.returnToMembership
            : billingBlocked
            ? () async {
                await controller.acknowledgeAndReset();
                if (context.mounted) context.go('/home');
              }
            : () async {
                await controller.acknowledgeAndReset();
                controller.startScanning();
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
    required this.actionLabel,
    this.actionIcon = Icons.qr_code_scanner_rounded,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final String actionLabel;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: WafloInfoCard(
        title: strings.operationNotCompleted,
        icon: icon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            if (onRetry != null) ...[
              const SizedBox(height: WafloSpacing.md),
              FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(actionIcon),
                label: Text(actionLabel),
              ),
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
