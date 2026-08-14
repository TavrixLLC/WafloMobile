import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_mode.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

LocalDemoRuntime createLocalDemoRuntime() => LocalDemoRuntimeDebug();

/// Debug-only fixture runtime. This library is not selected when
/// `dart.vm.product` is true, and it still requires the explicit build define.
final class LocalDemoRuntimeDebug implements LocalDemoRuntime {
  LocalDemoRuntimeDebug({
    this.forceAvailable = false,
    CustomerScannerAdapter Function()? scannerFactory,
  }) : _scannerFactory =
           scannerFactory ?? (() => MobileCustomerScannerAdapter()),
       _operations = _LocalDemoLoyaltyOperations(),
       _appLock = _LocalDemoAppLockStore();

  static const _configured = bool.fromEnvironment('WAFLO_LOCAL_DEMO_ENABLED');
  final bool forceAvailable;
  final CustomerScannerAdapter Function() _scannerFactory;
  final _LocalDemoLoyaltyOperations _operations;
  final MemoryPendingOperationStore _pending = MemoryPendingOperationStore();
  final MemoryManagerApprovalIntentStore _approvalIntents =
      MemoryManagerApprovalIntentStore();
  final _LocalDemoAppLockStore _appLock;
  _LocalDemoCustomerScannerAdapter? _scanner;
  LocalDemoScenario _scenario = LocalDemoScenario.home;

  @override
  bool availableFor(AppEnvironment environment) =>
      (forceAvailable || (_configured && kDebugMode)) &&
      environment.flavor != AppFlavor.production;

  @override
  AuthoritativeDeviceContext get deviceContext => AuthoritativeDeviceContext(
    organization: const OrganizationContext(
      publicId: 'demo-organization',
      displayName: 'Waflo Demo Café',
    ),
    staff: const StaffContext(
      publicId: 'demo-staff',
      displayName: 'Sample Staff',
      role: 'STAFF',
    ),
    device: const DeviceContextSummary(
      publicId: 'demo-device',
      displayName: 'Owner review device',
      status: 'ACTIVE',
      platform: 'ANDROID',
      appVersion: '1.0.0',
    ),
    currentLocation: const LocationContext(
      publicId: 'demo-location',
      displayName: 'Sample counter',
      earningAllowed: true,
      redemptionAllowed: true,
    ),
    assignedLocations: const [
      LocationContext(
        publicId: 'demo-location',
        displayName: 'Sample counter',
        earningAllowed: true,
        redemptionAllowed: true,
      ),
    ],
    appPolicy: const AppUpdatePolicy(
      minimumSupportedVersion: '1.0.0',
      updateRequired: false,
    ),
    requestId: 'local-demo-no-request',
    synchronizedAt: DateTime.now().toUtc(),
  );

  @override
  AppLockStore get appLock => _appLock;

  @override
  LoyaltyOperationsApi get loyaltyOperations => _operations;

  @override
  ManagerApprovalIntentStore get managerApprovalIntents => _approvalIntents;

  @override
  PendingOperationStore get pendingOperations => _pending;

  @override
  CustomerScannerAdapter createScannerAdapter() {
    final initial = _scannerStateFor(_scenario);
    final scanner = _LocalDemoCustomerScannerAdapter(
      runtime: this,
      camera: _scannerFactory(),
      initialState: initial,
      cameraEnabled: initial == CustomerScannerState.ready,
    );
    _scanner = scanner;
    return scanner;
  }

  @override
  void selectScenario(LocalDemoScenario scenario) {
    _scenario = scenario;
    _operations.configure(scenario);
  }

  @override
  void setApprovalOutcome(LocalDemoApprovalOutcome outcome) {
    _operations.approvalOutcome = outcome;
  }

  @override
  Future<void> simulateScanner(LocalDemoScannerSimulation simulation) async {
    final scanner = _scanner;
    if (scanner == null) throw LocalDemoUnavailableError();
    await scanner.simulate(simulation);
  }

  @override
  Future<void> prepareAppLockFixture() async {
    await _appLock.setPin('2468');
    await _appLock.setConfiguration(
      const AppLockConfiguration(mode: AppLockMode.pin),
    );
  }

  @override
  Future<void> reset() async {
    final scanner = _scanner;
    _scanner = null;
    if (scanner != null) await scanner.dispose();
    await _pending.clear();
    await _approvalIntents.clear();
    _appLock.reset();
    _scenario = LocalDemoScenario.home;
    _operations.reset();
  }

  static CustomerScannerState _scannerStateFor(LocalDemoScenario scenario) =>
      switch (scenario) {
        LocalDemoScenario.scannerQrDetected =>
          CustomerScannerState.candidateCaptured,
        LocalDemoScenario.scannerResolving => CustomerScannerState.resolving,
        LocalDemoScenario.scannerInvalidQr => CustomerScannerState.invalidQr,
        LocalDemoScenario.scannerExpiredQr => CustomerScannerState.expiredQr,
        LocalDemoScenario.scannerNetworkFailure =>
          CustomerScannerState.networkFailure,
        LocalDemoScenario.scannerPermissionDenied =>
          CustomerScannerState.cameraPermissionDenied,
        _ => CustomerScannerState.ready,
      };
}

final class _LocalDemoLoyaltyOperations implements LoyaltyOperationsApi {
  LocalDemoScenario scenario = LocalDemoScenario.home;
  LocalDemoApprovalOutcome approvalOutcome = LocalDemoApprovalOutcome.pending;
  int progress = 5;
  int completedCycles = 1;
  int projectionVersion = 10;

  void configure(LocalDemoScenario value) {
    scenario = value;
    progress = switch (value) {
      LocalDemoScenario.customerZeroOfEight => 0,
      LocalDemoScenario.customerRewardReady ||
      LocalDemoScenario.redeemConfirmation ||
      LocalDemoScenario.managerApprovalRequired ||
      LocalDemoScenario.managerApprovalPending ||
      LocalDemoScenario.managerApprovalRejected ||
      LocalDemoScenario.managerApprovalExpired ||
      LocalDemoScenario.redeemSuccess => 8,
      _ => 5,
    };
    approvalOutcome = switch (value) {
      LocalDemoScenario.managerApprovalRejected =>
        LocalDemoApprovalOutcome.rejected,
      LocalDemoScenario.managerApprovalExpired =>
        LocalDemoApprovalOutcome.expired,
      LocalDemoScenario.redeemSuccess => LocalDemoApprovalOutcome.approved,
      _ => LocalDemoApprovalOutcome.pending,
    };
  }

  void reset() {
    scenario = LocalDemoScenario.home;
    progress = 5;
    completedCycles = 1;
    projectionVersion = 10;
    approvalOutcome = LocalDemoApprovalOutcome.pending;
  }

  @override
  Future<ResolvedMembership> resolveMembership({
    required String qrPayload,
    required String locale,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (scenario == LocalDemoScenario.scannerInvalidQr) {
      throw const ApiFailure('MEMBERSHIP_CREDENTIAL_INVALID');
    }
    if (scenario == LocalDemoScenario.scannerNetworkFailure) {
      throw const NetworkFailure();
    }
    return _membership(locale);
  }

  @override
  Future<StampOperationResult> issueStamps({
    required String qrPayload,
    required String locale,
    required String commandId,
    required StampOperationInput input,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (scenario == LocalDemoScenario.billingBlocked) {
      throw const ApiFailure('OPERATION_BILLING_BLOCKED', httpStatus: 403);
    }
    final before = progress;
    progress = (progress + input.amount).clamp(0, 8).toInt();
    projectionVersion += 1;
    return StampOperationResult(
      operationPublicId: '10000000-0000-4000-8000-000000000101',
      commandId: commandId,
      replayed: false,
      beforeProgress: before,
      progress: StampProgress.validated(progress: progress, goal: 8),
      rewardReady: progress == 8,
      completedCycles: completedCycles,
      projectionVersion: projectionVersion,
      unlockedRewards: progress == 8
          ? const [
              UnlockedReward(
                publicId: '10000000-0000-4000-8000-000000000201',
                threshold: 8,
                status: 'AVAILABLE',
                finalReward: true,
              ),
            ]
          : const [],
      requestId: null,
    );
  }

  @override
  Future<RedemptionOperationResult> redeemReward({
    required String qrPayload,
    required String locale,
    required String commandId,
    required RedemptionOperationInput input,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (input.managerApprovalPublicId == null) {
      throw _approvalFailure('MANAGER_APPROVAL_REQUIRED');
    }
    switch (approvalOutcome) {
      case LocalDemoApprovalOutcome.pending:
        throw _approvalFailure('MANAGER_APPROVAL_PENDING');
      case LocalDemoApprovalOutcome.rejected:
        throw const ApiFailure('MANAGER_APPROVAL_REJECTED', httpStatus: 409);
      case LocalDemoApprovalOutcome.expired:
        throw const ApiFailure('MANAGER_APPROVAL_EXPIRED', httpStatus: 409);
      case LocalDemoApprovalOutcome.approved:
        final before = progress;
        progress = 0;
        completedCycles += 1;
        projectionVersion += 1;
        return RedemptionOperationResult(
          operationPublicId: '10000000-0000-4000-8000-000000000301',
          commandId: commandId,
          replayed: false,
          redemptionPublicId: '10000000-0000-4000-8000-000000000302',
          rewardStatus: RedemptionRewardStatus.redeemed,
          finalReward: true,
          beforeProgress: before,
          progress: StampProgress.validated(progress: 0, goal: 8),
          rewardReady: false,
          completedCycles: completedCycles,
          projectionVersion: projectionVersion,
          requestId: null,
        );
    }
  }

  @override
  Future<CommandRecoveryResult> commandStatus(String commandId) async =>
      CommandRecoveryResult(
        commandId: commandId,
        operationPublicId: '10000000-0000-4000-8000-000000000401',
        operationType: CommandOperationType.stamp,
        status: CommandRecoveryStatus.processing,
        safeFailureCode: null,
        stampResult: null,
        redemptionResult: null,
        createdAt: DateTime.now().toUtc(),
        completedAt: null,
        requestId: null,
      );

  ResolvedMembership _membership(String locale) {
    final purchaseRequired =
        scenario == LocalDemoScenario.purchaseThresholdNotMet;
    final capacity = 8 - progress;
    return ResolvedMembership(
      membershipPublicId: 'demo-membership-public',
      customerDisplayName: locale == 'ar' ? 'ليان العزاوي' : 'Layan Al-Azzawi',
      programName: locale == 'ar' ? 'قهوة الوفاء' : 'Coffee Flow',
      locale: locale == 'ar' ? 'ar' : 'en',
      status: MembershipStatus.active,
      progress: StampProgress.validated(progress: progress, goal: 8),
      completedCycles: completedCycles,
      projectionVersion: projectionVersion,
      rewardReady: progress == 8,
      locationEligibility: const LocationEligibility(
        earning: true,
        redemption: true,
      ),
      operationPolicy: MembershipOperationPolicy(
        maximumStampAmountPerOperation: 4,
        remainingProgressCapacity: capacity,
        effectiveMaximumStampAmount: capacity.clamp(0, 4).toInt(),
        dailyLimitEnabled: false,
        dailyMaximumStampAmount: null,
        dailyRemainingStampAmount: null,
        operationalLocalDate: DateTime.utc(2026, 8, 14),
        operationalTimezone: 'Asia/Baghdad',
        purchaseRequirementEnabled: purchaseRequired,
        minimumPurchaseAmountMinor: purchaseRequired ? 1000 : null,
        purchaseCurrency: purchaseRequired ? 'IQD' : null,
      ),
      stampArtwork: const StampArtwork(
        filledAssetDigest: null,
        emptyAssetDigest: null,
      ),
      availableRewards: progress == 8
          ? [
              AvailableReward(
                entitlementPublicId: '10000000-0000-4000-8000-000000000201',
                finalReward: true,
                threshold: 8,
                name: locale == 'ar' ? 'مشروب مجاني' : 'Complimentary drink',
                description: locale == 'ar'
                    ? 'اختر مشروباً من القائمة.'
                    : 'Choose one drink from the menu.',
                status: RewardAvailability.available,
                redemptionCount: 0,
                maximumRedemptionCount: 1,
                expiresAt: null,
                requiresManagerApproval: true,
              ),
            ]
          : const [],
      resolvedAt: DateTime.now().toUtc(),
      requestId: null,
    );
  }

  ApiFailure _approvalFailure(String code) => ApiFailure(
    code,
    httpStatus: 409,
    details: {
      'operationType': 'REDEEM',
      'retryWithSameIdempotencyKey': true,
      'approvalRequest': {
        'publicId': '10000000-0000-4000-8000-000000000501',
        'status': 'PENDING',
        'expiresAt': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      },
    },
  );
}

final class _LocalDemoCustomerScannerAdapter implements CustomerScannerAdapter {
  _LocalDemoCustomerScannerAdapter({
    required this.runtime,
    required CustomerScannerAdapter camera,
    required CustomerScannerState initialState,
    required this.cameraEnabled,
  }) : // Public constructor naming stays readable at the factory boundary.
       // ignore: prefer_initializing_formals
       _camera = camera,
       _state = ValueNotifier(initialState) {
    _camera.state.addListener(_syncCameraState);
  }

  static const _candidate =
      'waflo-local-demo-customer-credential-v1-opaque-sample';
  final LocalDemoRuntimeDebug runtime;
  final bool cameraEnabled;
  final CustomerScannerAdapter _camera;
  final ValueNotifier<CustomerScannerState> _state;
  Future<void> Function(String value)? _onDetected;
  bool _disposed = false;

  @override
  ScannerMode get mode => ScannerMode.customerMembershipQr;

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _camera.torchEnabled;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) {
    _onDetected = onDetected;
    return _camera.buildPreview(
      context,
      onDetected: (value) => _deliver(value),
    );
  }

  @override
  Future<void> start() async {
    if (_disposed || !cameraEnabled) return;
    await _camera.start();
  }

  @override
  Future<void> stop() => _camera.stop();

  @override
  Future<void> background() async {
    _state.value = CustomerScannerState.backgrounded;
    await _camera.background();
  }

  @override
  Future<void> foreground() async {
    if (_disposed || !cameraEnabled) return;
    await _camera.foreground();
  }

  @override
  void reportResolveFailure(CustomerScannerState failure) {
    if (!_disposed) _state.value = failure;
  }

  @override
  Future<void> resetForExplicitRetry() async {
    runtime.selectScenario(LocalDemoScenario.customerFiveOfEight);
    _state.value = CustomerScannerState.ready;
    if (cameraEnabled) await _camera.resetForExplicitRetry();
  }

  @override
  Future<void> toggleTorch() => _camera.toggleTorch();

  Future<void> simulate(LocalDemoScannerSimulation simulation) async {
    if (_disposed) return;
    switch (simulation) {
      case LocalDemoScannerSimulation.validQr:
        runtime.selectScenario(LocalDemoScenario.customerFiveOfEight);
        await _deliver(_candidate);
        return;
      case LocalDemoScannerSimulation.invalidQr:
        runtime.selectScenario(LocalDemoScenario.scannerInvalidQr);
        await _deliver(_candidate);
        return;
      case LocalDemoScannerSimulation.expiredQr:
        await _camera.stop();
        _state.value = CustomerScannerState.expiredQr;
        return;
      case LocalDemoScannerSimulation.networkFailure:
        runtime.selectScenario(LocalDemoScenario.scannerNetworkFailure);
        await _deliver(_candidate);
        return;
      case LocalDemoScannerSimulation.reset:
        await resetForExplicitRetry();
        return;
    }
  }

  Future<void> _deliver(String candidate) async {
    final callback = _onDetected;
    if (callback == null || _disposed) return;
    _state.value = CustomerScannerState.candidateCaptured;
    await _camera.stop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (_disposed) return;
    _state.value = CustomerScannerState.resolving;
    await callback(candidate);
  }

  void _syncCameraState() {
    if (!_disposed && cameraEnabled) _state.value = _camera.state.value;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _camera.state.removeListener(_syncCameraState);
    await _camera.dispose();
    _state.dispose();
  }
}

final class _LocalDemoAppLockStore implements AppLockStore {
  AppLockConfiguration _configuration = const AppLockConfiguration();
  List<int>? _pinDigest;
  List<int>? _salt;
  PinRateLimit _rateLimit = const PinRateLimit(failures: 0);

  void reset() {
    _configuration = const AppLockConfiguration();
    _pinDigest = null;
    _salt = null;
    _rateLimit = const PinRateLimit(failures: 0);
  }

  @override
  AppLockConfiguration readConfiguration() => _configuration;

  @override
  Future<void> setConfiguration(AppLockConfiguration configuration) async =>
      _configuration = configuration;

  @override
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(pin)) {
      throw const FormatException('PIN_FORMAT_INVALID');
    }
    final random = Random.secure();
    _salt = List<int>.generate(24, (_) => random.nextInt(256));
    _pinDigest = sha256.convert([..._salt!, ...utf8.encode(pin)]).bytes;
    _rateLimit = const PinRateLimit(failures: 0);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final expected = _pinDigest;
    final salt = _salt;
    if (expected == null || salt == null) return false;
    final actual = sha256.convert([...salt, ...utf8.encode(pin)]).bytes;
    if (actual.length != expected.length) return false;
    var difference = 0;
    for (var index = 0; index < actual.length; index += 1) {
      difference |= actual[index] ^ expected[index];
    }
    return difference == 0;
  }

  @override
  Future<void> clearPin() async {
    _pinDigest = null;
    _salt = null;
    await clearRateLimit();
  }

  @override
  Future<PinRateLimit> readRateLimit() async => _rateLimit;

  @override
  Future<PinRateLimit> registerFailure(DateTime now) async {
    final failures = _rateLimit.failures + 1;
    final delay = PinRateLimitPolicy.delayFor(failures);
    _rateLimit = PinRateLimit(
      failures: failures,
      retryAt: delay == Duration.zero ? null : now.toUtc().add(delay),
    );
    return _rateLimit;
  }

  @override
  Future<void> clearRateLimit() async =>
      _rateLimit = const PinRateLimit(failures: 0);
}
