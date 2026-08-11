import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  test(
    'stamp mutation uses one command and recovers ambiguous completion',
    () async {
      final store = MemoryPendingOperationStore();
      final api = _FakeLoyaltyApi(
        membership: _membership(2),
        issueFailure: const ApiFailure(
          'OPERATION_RESULT_UNKNOWN',
          responseReceived: false,
        ),
        recovery: _recoveryFixture('operation-completed.fixture.json'),
      );
      final container = _container(api: api, store: store);
      addTearDown(container.dispose);
      final controller = container.read(m2OperationControllerProvider.notifier);

      controller.startScanning();
      await controller.resolveCandidate(_credential, locale: 'en');
      controller.prepareStampReview(
        amount: 1,
        purchaseAmountText: '10.000',
        transactionReferenceText: '',
      );
      await controller.confirmStamp(locale: 'en');

      expect(
        container.read(m2OperationControllerProvider).stage,
        M2OperationStage.stampAmbiguous,
      );
      expect(api.issueCommandIds, const [
        '20000000-0000-4000-8000-000000000001',
      ]);
      expect(store.value?.status, PendingOperationStatus.processing);

      await controller.recoverPending();

      final recovered = container.read(m2OperationControllerProvider);
      expect(recovered.stage, M2OperationStage.stampSucceeded);
      expect(recovered.stampResult?.progress.progress, 5);
      expect(api.issueCommandIds, hasLength(1));
    },
  );

  test('process restart restores one pending command without QR', () async {
    final store = MemoryPendingOperationStore()
      ..value = PendingOperationRecord(
        commandId: '20000000-0000-4000-8000-000000000001',
        operationType: PendingOperationType.stamp,
        membershipPublicId: 'mem_fixture_not_a_credential',
        stampAmount: 1,
        createdAt: DateTime.now().toUtc(),
        lastCheckedAt: null,
        status: PendingOperationStatus.processing,
      );
    final api = _FakeLoyaltyApi(
      membership: _membership(2),
      recovery: _recoveryFixture('operation-completed.fixture.json'),
    );
    final container = _container(api: api, store: store);
    addTearDown(container.dispose);

    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampAmbiguous,
    );
    await container
        .read(m2OperationControllerProvider.notifier)
        .recoverPending();
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampSucceeded,
    );
    expect(api.resolveCalls, 0);
    expect(api.issueCommandIds, isEmpty);
  });

  test(
    'PROCESSING after restart keeps the same command and blocks scan',
    () async {
      final store = MemoryPendingOperationStore()
        ..value = PendingOperationRecord(
          commandId: '20000000-0000-4000-8000-000000000001',
          operationType: PendingOperationType.stamp,
          membershipPublicId: 'mem_fixture_not_a_credential',
          stampAmount: 1,
          createdAt: DateTime.now().toUtc(),
          lastCheckedAt: null,
          status: PendingOperationStatus.processing,
        );
      final api = _FakeLoyaltyApi(
        membership: _membership(2),
        recovery: _recoveryFixture('operation-processing.fixture.json'),
      );
      final container = _container(api: api, store: store);
      addTearDown(container.dispose);
      final controller = container.read(m2OperationControllerProvider.notifier);

      await controller.recoverPending();
      controller.startScanning();

      final state = container.read(m2OperationControllerProvider);
      expect(state.stage, M2OperationStage.stampAmbiguous);
      expect(state.pendingOperation?.commandId, store.value?.commandId);
      expect(store.value?.status, PendingOperationStatus.processing);
      expect(api.resolveCalls, 0);
      expect(api.issueCommandIds, isEmpty);
    },
  );

  test(
    'FAILED after restart exposes safe failure without a new mutation',
    () async {
      final store = MemoryPendingOperationStore()
        ..value = PendingOperationRecord(
          commandId: '20000000-0000-4000-8000-000000000001',
          operationType: PendingOperationType.stamp,
          membershipPublicId: 'mem_fixture_not_a_credential',
          stampAmount: 1,
          createdAt: DateTime.now().toUtc(),
          lastCheckedAt: null,
          status: PendingOperationStatus.processing,
        );
      final api = _FakeLoyaltyApi(
        membership: _membership(2),
        recovery: _recoveryFixture('operation-failed.fixture.json'),
      );
      final container = _container(api: api, store: store);
      addTearDown(container.dispose);
      final controller = container.read(m2OperationControllerProvider.notifier);

      await controller.recoverPending();
      controller.startScanning();

      final state = container.read(m2OperationControllerProvider);
      expect(state.stage, M2OperationStage.policyBlocked);
      expect(state.failure?.safeCode, 'PURCHASE_CURRENCY_MISMATCH');
      expect(store.value?.status, PendingOperationStatus.failed);
      expect(state.pendingOperation?.commandId, store.value?.commandId);
      expect(api.resolveCalls, 0);
      expect(api.issueCommandIds, isEmpty);
    },
  );

  test('leaving recovery view keeps the pending command blocking scans', () {
    final store = MemoryPendingOperationStore()
      ..value = PendingOperationRecord(
        commandId: '20000000-0000-4000-8000-000000000001',
        operationType: PendingOperationType.stamp,
        membershipPublicId: 'mem_fixture_not_a_credential',
        stampAmount: 1,
        createdAt: DateTime.now().toUtc(),
        lastCheckedAt: null,
        status: PendingOperationStatus.processing,
      );
    final container = _container(
      api: _FakeLoyaltyApi(membership: _membership(2)),
      store: store,
    );
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    controller.cancelLocalRecoveryView();
    controller.startScanning();

    final state = container.read(m2OperationControllerProvider);
    expect(state.stage, M2OperationStage.stampAmbiguous);
    expect(state.pendingOperation?.commandId, store.value?.commandId);
  });

  test(
    'background clears transient credential and prevents mutation',
    () async {
      final api = _FakeLoyaltyApi(membership: _membership(2));
      final container = _container(
        api: api,
        store: MemoryPendingOperationStore(),
      );
      addTearDown(container.dispose);
      final controller = container.read(m2OperationControllerProvider.notifier);

      controller.startScanning();
      await controller.resolveCandidate(_credential, locale: 'en');
      controller.onBackground();
      controller.prepareStampReview(
        amount: 1,
        purchaseAmountText: '10.000',
        transactionReferenceText: '',
      );

      expect(
        container.read(m2OperationControllerProvider).stage,
        M2OperationStage.membershipInvalid,
      );
      expect(api.issueCommandIds, isEmpty);
    },
  );

  test('billing denial preserves authoritative customer projection', () async {
    final membership = _membership(2);
    final api = _FakeLoyaltyApi(
      membership: membership,
      issueFailure: const ApiFailure(
        'OPERATION_BILLING_BLOCKED',
        httpStatus: 403,
      ),
    );
    final store = MemoryPendingOperationStore();
    final container = _container(api: api, store: store);
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    controller.startScanning();
    await controller.resolveCandidate(_credential, locale: 'en');
    controller.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    await controller.confirmStamp(locale: 'en');

    final state = container.read(m2OperationControllerProvider);
    expect(state.stage, M2OperationStage.policyBlocked);
    expect(state.failure?.safeCode, 'OPERATION_BILLING_BLOCKED');
    expect(state.membership?.progress.progress, 2);
    expect(state.stampResult, isNull);
    expect(api.issueCommandIds, hasLength(1));
    expect(store.value?.status, PendingOperationStatus.failed);
  });

  test('Manager-required redeem preserves and reuses exact intent', () async {
    final membership = _membership(2);
    final success = RedemptionOperationResult.fromJson(
      _fixture('redeem-milestone.fixture.json'),
    );
    final api = _FakeLoyaltyApi(
      membership: membership,
      redemptionOutcomes: [
        const ApiFailure(
          'MANAGER_APPROVAL_REQUIRED',
          httpStatus: 409,
          details: {
            'approvalRequest': {
              'publicId': '70000000-0000-4000-8000-000000000001',
              'status': 'PENDING',
              'expiresAt': '2030-08-11T21:00:00.000Z',
            },
            'operationType': 'REDEEM',
            'retryWithSameIdempotencyKey': true,
          },
        ),
        const ApiFailure(
          'MANAGER_APPROVAL_PENDING',
          httpStatus: 409,
          details: {
            'approvalRequest': {
              'publicId': '70000000-0000-4000-8000-000000000001',
              'status': 'PENDING',
              'expiresAt': '2030-08-11T21:00:00.000Z',
            },
            'operationType': 'REDEEM',
            'retryWithSameIdempotencyKey': true,
          },
        ),
        success,
      ],
    );
    final approvalStore = MemoryManagerApprovalIntentStore();
    final container = _container(
      api: api,
      store: MemoryPendingOperationStore(),
      approvalStore: approvalStore,
    );
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    controller.startScanning();
    await controller.resolveCandidate(_credential, locale: 'en');
    await controller.prepareRedemption(
      membership.availableRewards.single,
      locale: 'en',
    );
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionReview,
    );
    await controller.confirmRedemption(locale: 'en');
    expect(
      container.read(m2OperationControllerProvider).managerApprovalState,
      ManagerApprovalState.required,
    );
    expect(approvalStore.value, isNotNull);

    await controller.checkManagerApproval(locale: 'en');
    expect(
      container.read(m2OperationControllerProvider).managerApprovalState,
      ManagerApprovalState.pending,
    );
    await controller.checkManagerApproval(locale: 'en');

    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionSucceeded,
    );
    expect(api.redeemCommandIds.toSet(), hasLength(1));
    expect(api.redeemInputs.first.managerApprovalPublicId, isNull);
    expect(
      api.redeemInputs.skip(1).map((input) => input.managerApprovalPublicId),
      everyElement('70000000-0000-4000-8000-000000000001'),
    );
    expect(approvalStore.value, isNull);
  });

  test(
    'every terminal approval state fails closed without redemption',
    () async {
      const terminalCodes = <String, ManagerApprovalState>{
        'MANAGER_APPROVAL_REJECTED': ManagerApprovalState.rejected,
        'MANAGER_APPROVAL_EXPIRED': ManagerApprovalState.expired,
        'MANAGER_APPROVAL_CONSUMED': ManagerApprovalState.consumed,
        'MANAGER_APPROVAL_MISMATCH': ManagerApprovalState.mismatch,
        'MANAGER_APPROVAL_INVALID': ManagerApprovalState.invalid,
        'MANAGER_APPROVAL_NOT_APPLICABLE': ManagerApprovalState.notApplicable,
        'MANAGER_APPROVAL_ALREADY_DECIDED': ManagerApprovalState.alreadyDecided,
        'MANAGER_APPROVAL_STALE': ManagerApprovalState.stale,
        'MANAGER_APPROVAL_APPROVER_INACTIVE':
            ManagerApprovalState.approverInactive,
      };

      for (final entry in terminalCodes.entries) {
        final membership = _membership(2);
        final approvalStore = MemoryManagerApprovalIntentStore();
        final pendingStore = MemoryPendingOperationStore();
        final api = _FakeLoyaltyApi(
          membership: membership,
          redemptionOutcomes: [
            _approvalFailure('MANAGER_APPROVAL_REQUIRED'),
            ApiFailure(entry.key, httpStatus: 409),
          ],
        );
        final container = _container(
          api: api,
          store: pendingStore,
          approvalStore: approvalStore,
        );
        addTearDown(container.dispose);
        final controller = container.read(
          m2OperationControllerProvider.notifier,
        );

        controller.startScanning();
        await controller.resolveCandidate(_credential, locale: 'en');
        await controller.prepareRedemption(
          membership.availableRewards.single,
          locale: 'en',
        );
        await controller.confirmRedemption(locale: 'en');
        await controller.checkManagerApproval(locale: 'en');

        final state = container.read(m2OperationControllerProvider);
        expect(state.stage, M2OperationStage.managerApprovalRequired);
        expect(state.managerApprovalState, entry.value);
        expect(state.redemptionResult, isNull);
        expect(pendingStore.value?.status, PendingOperationStatus.failed);
        expect(pendingStore.value?.failureCode, entry.key);
        expect(api.redeemCommandIds.toSet(), hasLength(1));
        expect(approvalStore.value, isNull);
      }
    },
  );

  test(
    'approved retry response loss keeps command and uses status recovery',
    () async {
      final membership = _membership(2);
      final approvalStore = MemoryManagerApprovalIntentStore();
      final pendingStore = MemoryPendingOperationStore();
      final recoveryJson = _fixture('operation-completed.fixture.json');
      final redemptionJson = _fixture('redeem-milestone.fixture.json');
      const commandId = '20000000-0000-4000-8000-000000000001';
      recoveryJson['commandId'] = commandId;
      recoveryJson['operationType'] = 'REDEEM_REWARD';
      redemptionJson['commandId'] = commandId;
      redemptionJson['operationPublicId'] = recoveryJson['operationPublicId'];
      recoveryJson['result'] = redemptionJson;
      final api = _FakeLoyaltyApi(
        membership: membership,
        recovery: CommandRecoveryResult.fromJson(recoveryJson),
        redemptionOutcomes: [
          _approvalFailure('MANAGER_APPROVAL_REQUIRED'),
          const ApiFailure('OPERATION_RESULT_UNKNOWN', responseReceived: false),
        ],
      );
      final container = _container(
        api: api,
        store: pendingStore,
        approvalStore: approvalStore,
      );
      addTearDown(container.dispose);
      final controller = container.read(m2OperationControllerProvider.notifier);

      controller.startScanning();
      await controller.resolveCandidate(_credential, locale: 'en');
      await controller.prepareRedemption(
        membership.availableRewards.single,
        locale: 'en',
      );
      await controller.confirmRedemption(locale: 'en');
      await controller.checkManagerApproval(locale: 'en');

      expect(
        container.read(m2OperationControllerProvider).stage,
        M2OperationStage.redemptionAmbiguous,
      );
      expect(pendingStore.value?.status, PendingOperationStatus.processing);
      expect(approvalStore.value, isNotNull);

      await controller.recoverPending();

      final state = container.read(m2OperationControllerProvider);
      expect(state.stage, M2OperationStage.redemptionSucceeded);
      expect(state.redemptionResult, isNotNull);
      expect(api.redeemCommandIds.toSet(), hasLength(1));
      expect(api.redeemCommandIds, hasLength(2));
      expect(approvalStore.value, isNull);
    },
  );

  test(
    'approval intent survives restart and resumes with the same command',
    () async {
      final membership = _membership(2);
      final approvalStore = MemoryManagerApprovalIntentStore();
      final pendingStore = MemoryPendingOperationStore();
      final api = _FakeLoyaltyApi(
        membership: membership,
        redemptionOutcomes: [
          _approvalFailure('MANAGER_APPROVAL_REQUIRED'),
          RedemptionOperationResult.fromJson(
            _fixture('redeem-milestone.fixture.json'),
          ),
        ],
      );
      final beforeRestart = _container(
        api: api,
        store: pendingStore,
        approvalStore: approvalStore,
      );
      final controller = beforeRestart.read(
        m2OperationControllerProvider.notifier,
      );

      controller.startScanning();
      await controller.resolveCandidate(_credential, locale: 'en');
      await controller.prepareRedemption(
        membership.availableRewards.single,
        locale: 'en',
      );
      await controller.confirmRedemption(locale: 'en');
      final originalCommand = pendingStore.value?.commandId;
      beforeRestart.dispose();

      final afterRestart = _container(
        api: api,
        store: pendingStore,
        approvalStore: approvalStore,
      );
      addTearDown(afterRestart.dispose);
      expect(
        afterRestart.read(m2OperationControllerProvider).managerApprovalState,
        ManagerApprovalState.required,
      );

      await afterRestart
          .read(m2OperationControllerProvider.notifier)
          .checkManagerApproval(locale: 'en');

      expect(
        afterRestart.read(m2OperationControllerProvider).stage,
        M2OperationStage.redemptionSucceeded,
      );
      expect(api.redeemCommandIds, everyElement(originalCommand));
      expect(api.redeemCommandIds, hasLength(2));
      expect(approvalStore.value, isNull);
    },
  );

  test('final redemption displays the authoritative zero projection', () async {
    final membership = _membership(8);
    final api = _FakeLoyaltyApi(
      membership: membership,
      redemption: RedemptionOperationResult.fromJson(
        _fixture('redeem-final-reset.fixture.json'),
      ),
    );
    final container = _container(
      api: api,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    controller.startScanning();
    await controller.resolveCandidate(_credential, locale: 'en');
    await controller.prepareRedemption(
      membership.availableRewards.single,
      locale: 'en',
    );
    await controller.confirmRedemption(locale: 'en');

    final state = container.read(m2OperationControllerProvider);
    expect(state.stage, M2OperationStage.redemptionSucceeded);
    expect(state.redemptionResult?.progress.progress, 0);
    expect(state.redemptionResult?.rewardReady, isFalse);
    expect(api.redeemCommandIds, hasLength(1));
  });
}

ProviderContainer _container({
  required _FakeLoyaltyApi api,
  required MemoryPendingOperationStore store,
  ManagerApprovalIntentStore? approvalStore,
}) => ProviderContainer(
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    loyaltyOperationsApiProvider.overrideWithValue(api),
    pendingOperationStoreProvider.overrideWithValue(store),
    managerApprovalIntentStoreProvider.overrideWithValue(
      approvalStore ?? MemoryManagerApprovalIntentStore(),
    ),
    businessCommandIdGeneratorProvider.overrideWithValue(
      FixedBusinessCommandIdGenerator(const [
        '20000000-0000-4000-8000-000000000001',
      ]),
    ),
  ],
);

final class _FakeLoyaltyApi implements LoyaltyOperationsApi {
  _FakeLoyaltyApi({
    required this.membership,
    this.issueFailure,
    this.recovery,
    this.redemption,
    List<Object>? redemptionOutcomes,
  }) : redemptionOutcomes = [...?redemptionOutcomes];

  final ResolvedMembership membership;
  final AppFailure? issueFailure;
  final CommandRecoveryResult? recovery;
  final RedemptionOperationResult? redemption;
  final List<Object> redemptionOutcomes;
  final List<String> issueCommandIds = [];
  final List<String> redeemCommandIds = [];
  final List<RedemptionOperationInput> redeemInputs = [];
  int resolveCalls = 0;

  @override
  Future<ResolvedMembership> resolveMembership({
    required String qrPayload,
    required String locale,
  }) async {
    resolveCalls += 1;
    return membership;
  }

  @override
  Future<StampOperationResult> issueStamps({
    required String qrPayload,
    required String locale,
    required String commandId,
    required StampOperationInput input,
  }) async {
    issueCommandIds.add(commandId);
    final failure = issueFailure;
    if (failure != null) {
      throw failure;
    }
    return StampOperationResult.fromJson(
      _fixture('stamp-success.fixture.json'),
    );
  }

  @override
  Future<RedemptionOperationResult> redeemReward({
    required String qrPayload,
    required String locale,
    required String commandId,
    required RedemptionOperationInput input,
  }) async {
    redeemCommandIds.add(commandId);
    redeemInputs.add(input);
    if (redemptionOutcomes.isNotEmpty) {
      final outcome = redemptionOutcomes.removeAt(0);
      if (outcome is AppFailure) throw outcome;
      return outcome as RedemptionOperationResult;
    }
    return redemption ??
        RedemptionOperationResult.fromJson(
          _fixture('redeem-milestone.fixture.json'),
        );
  }

  @override
  Future<CommandRecoveryResult> commandStatus(String commandId) async =>
      recovery ?? _recoveryFixture('operation-processing.fixture.json');
}

const _credential =
    'customer-membership-credential-fixture-000000000000000000000000';

ResolvedMembership _membership(int progress) {
  final value = _fixture('membership-resolve.fixture.json');
  final limits = value['operationLimits']! as Map<String, Object?>;
  value['progress'] = progress;
  value['rewardReady'] = progress == 8;
  value['projectionVersion'] = progress + 1;
  limits['dailyRemainingStamps'] = (8 - progress).clamp(0, 4);
  if (progress == 8) {
    value['availableRewards'] = [
      <String, Object?>{
        'publicId': '40000000-0000-4000-8000-000000000002',
        'finalReward': true,
        'threshold': 8,
        'name': 'Fixture final reward',
        'description': 'A sanitized final reward.',
        'status': 'AVAILABLE',
        'redemptionCount': 0,
        'maximumRedemptionCount': 1,
        'expiresAt': null,
        'requiresManagerApproval': false,
      },
    ];
  } else {
    final rewards = value['availableRewards']! as List<Object?>;
    final reward = rewards.single! as Map<String, Object?>;
    reward['requiresManagerApproval'] = true;
  }
  return ResolvedMembership.fromJson(value, allowInsecureAssets: false);
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

CommandRecoveryResult _recoveryFixture(String name) {
  final value = _fixture(name);
  const commandId = '20000000-0000-4000-8000-000000000001';
  value['commandId'] = commandId;
  final result = value['result'];
  if (result is Map<String, Object?>) {
    result['commandId'] = commandId;
  }
  return CommandRecoveryResult.fromJson(value);
}

ApiFailure _approvalFailure(String code) => ApiFailure(
  code,
  httpStatus: 409,
  details: const {
    'approvalRequest': {
      'publicId': '70000000-0000-4000-8000-000000000001',
      'status': 'PENDING',
      'expiresAt': '2030-08-11T21:00:00.000Z',
    },
    'operationType': 'REDEEM',
    'retryWithSameIdempotencyKey': true,
  },
);
