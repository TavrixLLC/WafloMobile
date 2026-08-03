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
        recovery: CommandRecoveryResult.fromJson(
          _fixture('operation-completed.fixture.json'),
        ),
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
      expect(recovered.stampResult?.progress.progress, 3);
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
      recovery: CommandRecoveryResult.fromJson(
        _fixture('operation-completed.fixture.json'),
      ),
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

  test(
    'Manager-required reward is blocked without approval acquisition',
    () async {
      final membership = _membership(2);
      final api = _FakeLoyaltyApi(membership: membership);
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

      expect(
        container.read(m2OperationControllerProvider).stage,
        M2OperationStage.managerApprovalRequired,
      );
      expect(api.redeemCommandIds, isEmpty);
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
}) => ProviderContainer(
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    loyaltyOperationsApiProvider.overrideWithValue(api),
    pendingOperationStoreProvider.overrideWithValue(store),
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
  });

  final ResolvedMembership membership;
  final AppFailure? issueFailure;
  final CommandRecoveryResult? recovery;
  final RedemptionOperationResult? redemption;
  final List<String> issueCommandIds = [];
  final List<String> redeemCommandIds = [];
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
    return redemption ??
        RedemptionOperationResult.fromJson(
          _fixture('redeem-milestone.fixture.json'),
        );
  }

  @override
  Future<CommandRecoveryResult> commandStatus(String commandId) async =>
      recovery ??
      CommandRecoveryResult.fromJson(
        _fixture('operation-processing.fixture.json'),
      );
}

const _credential =
    'customer-membership-credential-fixture-000000000000000000000000';

ResolvedMembership _membership(int progress) {
  final value = _fixture('membership-resolve.fixture.json');
  final membership = value['membership']! as Map<String, Object?>;
  final policy = value['operationPolicy']! as Map<String, Object?>;
  value['progress'] = progress;
  membership['progress'] = progress;
  value['rewardReady'] = progress == 8;
  membership['rewardReady'] = progress == 8;
  membership['projectionVersion'] = progress + 1;
  policy['remainingProgressCapacity'] = 8 - progress;
  policy['effectiveMaximumStampAmount'] = (8 - progress).clamp(0, 5);
  if (progress == 8) {
    value['availableRewards'] = [
      <String, Object?>{
        'entitlementPublicId': '40000000-0000-4000-8000-000000000002',
        'type': 'FREE_ITEM',
        'finalReward': true,
        'threshold': 8,
        'name': 'Fixture final reward',
        'description': 'A sanitized final reward.',
        'redemptionInstructions': 'Follow merchant instructions.',
        'status': 'AVAILABLE',
        'redemptionCount': 0,
        'maximumRedemptionCount': 1,
        'expiresAt': null,
        'requiresManagerApproval': false,
      },
    ];
  }
  return ResolvedMembership.fromJson(value, allowInsecureAssets: false);
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;
