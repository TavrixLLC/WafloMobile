import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/review_access/domain/local_review_access.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

final class LocalDemoController extends Notifier<LocalDemoState> {
  static const _fixtureCredential =
      'waflo-local-demo-customer-credential-v1-opaque-sample';
  Future<void>? _operation;

  @override
  LocalDemoState build() => const LocalDemoState();

  bool get canEnter {
    try {
      return ref.read(localDemoAccessAvailableProvider);
    } on Object {
      return false;
    }
  }

  Future<bool> enterAuthorized(LocalReviewAccessGrant grant) async {
    if (!canEnter || state.active) return state.active;
    if (await _hasProductionState()) {
      return false;
    }
    await ref.read(localDemoRuntimeProvider).reset();
    await ref.read(localReviewAccessProvider).activate(grant);
    state = const LocalDemoState(status: LocalDemoStatus.active);
    return true;
  }

  Future<bool> restoreIfActive() async {
    final access = ref.read(localReviewAccessProvider);
    if (!access.isActive) return false;
    if (!canEnter || await _hasProductionState()) {
      await access.deactivate();
      return false;
    }
    await ref.read(localDemoRuntimeProvider).reset();
    state = const LocalDemoState(status: LocalDemoStatus.active);
    return true;
  }

  Future<void> exit() => _singleFlight(() async {
    if (!state.active) return;
    await ref
        .read(m2OperationControllerProvider.notifier)
        .acknowledgeAndReset();
    await ref.read(localDemoRuntimeProvider).reset();
    await ref.read(localReviewAccessProvider).deactivate();
    state = const LocalDemoState();
    ref.read(pairingControllerProvider.notifier).reset();
  });

  Future<bool> _hasProductionState() async {
    final session = await ref.read(sessionRepositoryProvider).read();
    final transaction = await ref
        .read(pairingTransactionRepositoryProvider)
        .read();
    return session != null || transaction != null;
  }

  Future<String> prepareScenario(
    LocalDemoScenario scenario, {
    required String locale,
  }) async {
    if (!state.active) throw LocalDemoUnavailableError();
    state = state.copyWith(scenario: scenario, busy: true);
    try {
      final runtime = ref.read(localDemoRuntimeProvider);
      runtime.selectScenario(scenario);
      final operations = ref.read(m2OperationControllerProvider.notifier);
      await operations.acknowledgeAndReset();
      switch (scenario) {
        case LocalDemoScenario.home:
          return '/home';
        case LocalDemoScenario.scannerReady:
        case LocalDemoScenario.scannerQrDetected:
        case LocalDemoScenario.scannerResolving:
        case LocalDemoScenario.scannerInvalidQr:
        case LocalDemoScenario.scannerExpiredQr:
        case LocalDemoScenario.scannerNetworkFailure:
        case LocalDemoScenario.scannerPermissionDenied:
          operations.startScanning();
          return '/loyalty';
        case LocalDemoScenario.customerZeroOfEight:
        case LocalDemoScenario.customerFiveOfEight:
        case LocalDemoScenario.customerRewardReady:
          await _loadMembership(operations, locale);
          return '/loyalty';
        case LocalDemoScenario.stampConfirmation:
          await _loadMembership(operations, locale);
          operations.prepareStampReview(
            amount: 1,
            purchaseAmountText: '',
            transactionReferenceText: '',
          );
          return '/loyalty';
        case LocalDemoScenario.stampSuccess:
          await _loadMembership(operations, locale);
          operations.prepareStampReview(
            amount: 1,
            purchaseAmountText: '',
            transactionReferenceText: '',
          );
          await operations.confirmStamp(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.redeemConfirmation:
          await _prepareRedeem(operations, locale);
          return '/loyalty';
        case LocalDemoScenario.managerApprovalRequired:
          await _prepareRedeem(operations, locale);
          await operations.confirmRedemption(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.managerApprovalPending:
          await _prepareRedeem(operations, locale);
          await operations.confirmRedemption(locale: locale);
          await operations.checkManagerApproval(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.managerApprovalRejected:
        case LocalDemoScenario.managerApprovalExpired:
          await _prepareRedeem(operations, locale);
          await operations.confirmRedemption(locale: locale);
          await operations.checkManagerApproval(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.redeemSuccess:
          await _prepareRedeem(operations, locale);
          await operations.confirmRedemption(locale: locale);
          runtime.setApprovalOutcome(LocalDemoApprovalOutcome.approved);
          await operations.checkManagerApproval(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.purchaseThresholdNotMet:
          await _loadMembership(operations, locale);
          operations.prepareStampReview(
            amount: 1,
            purchaseAmountText: '5',
            transactionReferenceText: '',
          );
          return '/loyalty';
        case LocalDemoScenario.billingBlocked:
          await _loadMembership(operations, locale);
          operations.prepareStampReview(
            amount: 1,
            purchaseAmountText: '',
            transactionReferenceText: '',
          );
          await operations.confirmStamp(locale: locale);
          return '/loyalty';
        case LocalDemoScenario.sessionExpired:
        case LocalDemoScenario.deviceRevoked:
          return '/demo-blocked';
        case LocalDemoScenario.appLock:
          await runtime.prepareAppLockFixture();
          ref.invalidate(appLockControllerProvider);
          return '/home';
        case LocalDemoScenario.deviceSecurity:
          return '/device-security';
        case LocalDemoScenario.settings:
          return '/settings';
      }
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> simulateScanner(LocalDemoScannerSimulation simulation) =>
      _singleFlight(() async {
        if (!state.active) throw LocalDemoUnavailableError();
        await ref.read(localDemoRuntimeProvider).simulateScanner(simulation);
      });

  Future<void> simulateManagerApproved({required String locale}) =>
      _singleFlight(() async {
        if (!state.active) throw LocalDemoUnavailableError();
        ref
            .read(localDemoRuntimeProvider)
            .setApprovalOutcome(LocalDemoApprovalOutcome.approved);
        await ref
            .read(m2OperationControllerProvider.notifier)
            .checkManagerApproval(locale: locale);
      });

  Future<void> _loadMembership(
    M2OperationController operations,
    String locale,
  ) async {
    operations.startScanning();
    await operations.resolveCandidate(_fixtureCredential, locale: locale);
  }

  Future<void> _prepareRedeem(
    M2OperationController operations,
    String locale,
  ) async {
    await _loadMembership(operations, locale);
    final membership = ref.read(m2OperationControllerProvider).membership;
    if (membership == null || membership.availableRewards.isEmpty) {
      throw StateError('Local demo reward fixture is unavailable.');
    }
    await operations.prepareRedemption(
      membership.availableRewards.first,
      locale: locale,
    );
  }

  Future<void> _singleFlight(Future<void> Function() action) {
    final running = _operation;
    if (running != null) return running;
    final operation = action();
    _operation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_operation, operation)) _operation = null;
      }),
    );
    return operation;
  }
}
