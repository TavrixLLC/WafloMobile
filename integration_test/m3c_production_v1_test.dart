import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import 'm2_app_integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M3C Production-v1 approval and denial matrix', (tester) async {
    final membership = m2IntegrationMembership(8);
    final approvalStore = MemoryManagerApprovalIntentStore();
    final pendingStore = MemoryPendingOperationStore();
    final api = EmulatorLoyaltyApi(
      membership: membership,
      redemptionOutcomes: [
        _approvalFailure('MANAGER_APPROVAL_REQUIRED'),
        _approvalFailure('MANAGER_APPROVAL_PENDING'),
        _finalResult(),
      ],
    );
    final container = m2IntegrationContainer(
      api: api,
      store: pendingStore,
      managerApprovalStore: approvalStore,
    );
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    // 01 paired authority, 02 explicit scan, and 03 authoritative resolve.
    expect(container.read(bootControllerProvider).stage, BootStage.pairedReady);
    controller.startScanning();
    await controller.resolveCandidate(_credential, locale: 'en');
    expect(
      container
          .read(m2OperationControllerProvider)
          .membership
          ?.progress
          .progress,
      8,
    );

    // 04 Manager policy never blocks the initial signed redeem. 05 The Staff
    // must confirm before the first mutation is sent.
    await controller.prepareRedemption(
      membership.availableRewards.single,
      locale: 'en',
    );
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionReview,
    );
    expect(api.redeemCommandIds, isEmpty);
    await controller.confirmRedemption(locale: 'en');

    // 06 required response is durable, 07 keeps the authoritative 8/8 state,
    // and 08 exposes only the Web handoff/check action in the Staff UI.
    var state = container.read(m2OperationControllerProvider);
    expect(state.managerApprovalState, ManagerApprovalState.required);
    expect(state.membership?.progress.progress, 8);
    expect(state.redemptionResult, isNull);
    expect(approvalStore.value, isNotNull);
    await pumpM2IntegrationApp(tester, container);
    expect(find.text('Manager approval required'), findsWidgets);
    expect(find.byKey(const Key('manager-approval-check')), findsOneWidget);
    expect(find.textContaining('Approve in this app'), findsNothing);

    // 09 pending is non-mutating, 10 reuses the exact command, and 11 a later
    // approved retry commits the authoritative server result.
    await controller.checkManagerApproval(locale: 'en');
    state = container.read(m2OperationControllerProvider);
    expect(state.managerApprovalState, ManagerApprovalState.pending);
    expect(state.redemptionResult, isNull);
    await controller.checkManagerApproval(locale: 'en');
    state = container.read(m2OperationControllerProvider);
    expect(state.stage, M2OperationStage.redemptionSucceeded);
    expect(api.redeemCommandIds, hasLength(3));
    expect(api.redeemCommandIds.toSet(), hasLength(1));
    expect(api.redeemInputs.first.managerApprovalPublicId, isNull);
    expect(
      api.redeemInputs.skip(1).map((input) => input.managerApprovalPublicId),
      everyElement(_approvalPublicId),
    );
    expect(state.redemptionResult?.progress.progress, 0);
    expect(
      state.redemptionResult?.progress.slots.every(
        (slot) => slot == StampSlotState.empty,
      ),
      isTrue,
    );

    // 12 response loss after approved retry remains one command, 13 displays
    // checking status, and 14 command recovery commits without resubmission.
    final ambiguousStore = MemoryPendingOperationStore();
    final ambiguousApprovalStore = MemoryManagerApprovalIntentStore();
    final result = _finalResult();
    final ambiguousApi = EmulatorLoyaltyApi(
      membership: membership,
      redemptionOutcomes: [
        _approvalFailure('MANAGER_APPROVAL_REQUIRED'),
        const ApiFailure('OPERATION_RESULT_UNKNOWN', responseReceived: false),
      ],
      recovery: CommandRecoveryResult(
        commandId: _commandId,
        operationPublicId: result.operationPublicId,
        operationType: CommandOperationType.redemption,
        status: CommandRecoveryStatus.completed,
        safeFailureCode: null,
        stampResult: null,
        redemptionResult: result,
        createdAt: DateTime.utc(2026, DateTime.august, 11, 12),
        completedAt: DateTime.utc(2026, DateTime.august, 11, 12, 0, 1),
        requestId: '10000000-0000-4000-8000-000000000001',
      ),
    );
    final ambiguousContainer = m2IntegrationContainer(
      api: ambiguousApi,
      store: ambiguousStore,
      managerApprovalStore: ambiguousApprovalStore,
    );
    addTearDown(ambiguousContainer.dispose);
    final ambiguousController = ambiguousContainer.read(
      m2OperationControllerProvider.notifier,
    );
    ambiguousController.startScanning();
    await ambiguousController.resolveCandidate(_credential, locale: 'en');
    await ambiguousController.prepareRedemption(
      membership.availableRewards.single,
      locale: 'en',
    );
    await ambiguousController.confirmRedemption(locale: 'en');
    await ambiguousController.checkManagerApproval(locale: 'en');
    expect(
      ambiguousContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionAmbiguous,
    );
    expect(ambiguousApprovalStore.value, isNotNull);
    await pumpM2IntegrationApp(tester, ambiguousContainer);
    expect(find.text('Checking transaction status'), findsOneWidget);
    await ambiguousController.recoverPending();
    expect(
      ambiguousContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionSucceeded,
    );
    expect(ambiguousApi.redeemCommandIds.toSet(), hasLength(1));
    expect(ambiguousApprovalStore.value, isNull);

    // 15 billing denial never changes authoritative customer progress and is
    // never converted into an offline or optimistic success.
    final billingApi = EmulatorLoyaltyApi(
      membership: m2IntegrationMembership(2),
      issueFailure: const ApiFailure(
        'OPERATION_BILLING_BLOCKED',
        httpStatus: 403,
      ),
    );
    final billingContainer = m2IntegrationContainer(
      api: billingApi,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(billingContainer.dispose);
    final billingController = billingContainer.read(
      m2OperationControllerProvider.notifier,
    );
    billingController.startScanning();
    await billingController.resolveCandidate(_credential, locale: 'en');
    billingController.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    await billingController.confirmStamp(locale: 'en');
    final billingState = billingContainer.read(m2OperationControllerProvider);
    expect(billingState.failure?.safeCode, 'OPERATION_BILLING_BLOCKED');
    expect(billingState.membership?.progress.progress, 2);
    expect(billingState.stampResult, isNull);
  });
}

ApiFailure _approvalFailure(String code) => ApiFailure(
  code,
  httpStatus: 409,
  details: const {
    'approvalRequest': {
      'publicId': _approvalPublicId,
      'status': 'PENDING',
      'expiresAt': '2030-08-11T21:00:00.000Z',
    },
    'operationType': 'REDEEM',
    'retryWithSameIdempotencyKey': true,
  },
);

RedemptionOperationResult _finalResult() {
  final source = m2FinalRedemptionResult();
  return RedemptionOperationResult(
    operationPublicId: source.operationPublicId,
    commandId: _commandId,
    replayed: source.replayed,
    redemptionPublicId: source.redemptionPublicId,
    rewardStatus: source.rewardStatus,
    finalReward: source.finalReward,
    beforeProgress: source.beforeProgress,
    progress: source.progress,
    rewardReady: source.rewardReady,
    completedCycles: source.completedCycles,
    projectionVersion: source.projectionVersion,
    requestId: source.requestId,
  );
}

const _credential =
    'customer-membership-credential-fixture-not-a-real-credential-0001';
const _commandId = '20000000-0000-4000-8000-000000000001';
const _approvalPublicId = '70000000-0000-4000-8000-000000000001';
