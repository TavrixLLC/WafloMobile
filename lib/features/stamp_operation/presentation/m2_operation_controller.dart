import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

enum M2OperationStage {
  idle,
  scanning,
  resolving,
  membershipReady,
  stampReview,
  stampSubmitting,
  stampAmbiguous,
  stampSucceeded,
  redemptionReview,
  redemptionSubmitting,
  redemptionAmbiguous,
  redemptionSucceeded,
  managerApprovalRequired,
  membershipInvalid,
  membershipBlocked,
  locationBlocked,
  policyBlocked,
  sessionBlocked,
  networkUnavailable,
  fatalContractError,
}

final class M2OperationState {
  const M2OperationState({
    required this.stage,
    this.membership,
    this.stampInput,
    this.selectedReward,
    this.stampResult,
    this.redemptionResult,
    this.pendingOperation,
    this.failure,
    this.credentialAvailable = false,
  });

  const M2OperationState.idle() : this(stage: M2OperationStage.idle);

  final M2OperationStage stage;
  final ResolvedMembership? membership;
  final StampOperationInput? stampInput;
  final AvailableReward? selectedReward;
  final StampOperationResult? stampResult;
  final RedemptionOperationResult? redemptionResult;
  final PendingOperationRecord? pendingOperation;
  final AppFailure? failure;
  final bool credentialAvailable;

  M2OperationState copyWith({
    M2OperationStage? stage,
    ResolvedMembership? membership,
    StampOperationInput? stampInput,
    AvailableReward? selectedReward,
    StampOperationResult? stampResult,
    RedemptionOperationResult? redemptionResult,
    PendingOperationRecord? pendingOperation,
    AppFailure? failure,
    bool? credentialAvailable,
    bool clearFailure = false,
  }) => M2OperationState(
    stage: stage ?? this.stage,
    membership: membership ?? this.membership,
    stampInput: stampInput ?? this.stampInput,
    selectedReward: selectedReward ?? this.selectedReward,
    stampResult: stampResult ?? this.stampResult,
    redemptionResult: redemptionResult ?? this.redemptionResult,
    pendingOperation: pendingOperation ?? this.pendingOperation,
    failure: clearFailure ? null : failure ?? this.failure,
    credentialAvailable: credentialAvailable ?? this.credentialAvailable,
  );

  @override
  String toString() =>
      'M2OperationState(stage: ${stage.name}, credentialAvailable: $credentialAvailable, sensitiveValues: [REDACTED])';
}

final class M2OperationController extends Notifier<M2OperationState> {
  String? _qrPayload;
  Future<void>? _mutation;
  int _resolveGeneration = 0;

  @override
  M2OperationState build() {
    final pending = ref.read(pendingOperationStoreProvider).read();
    if (pending == null) {
      return const M2OperationState.idle();
    }
    return M2OperationState(
      stage: pending.operationType == PendingOperationType.stamp
          ? M2OperationStage.stampAmbiguous
          : M2OperationStage.redemptionAmbiguous,
      pendingOperation: pending,
    );
  }

  void startScanning() {
    if (_mutation != null || state.pendingOperation != null) {
      return;
    }
    final context = ref.read(bootControllerProvider).context;
    if (context == null ||
        (!context.currentLocation.earningAllowed &&
            !context.currentLocation.redemptionAllowed)) {
      state = state.copyWith(stage: M2OperationStage.locationBlocked);
      return;
    }
    _clearCredential();
    state = const M2OperationState(stage: M2OperationStage.scanning);
  }

  Future<void> resolveCandidate(
    String candidate, {
    required String locale,
  }) async {
    if (state.stage != M2OperationStage.scanning || _mutation != null) {
      return;
    }
    if (candidate.length < 40 || candidate.length > 220) {
      _clearCredential();
      state = const M2OperationState(
        stage: M2OperationStage.membershipInvalid,
        failure: ApiFailure('MEMBERSHIP_CREDENTIAL_INVALID'),
      );
      return;
    }
    final generation = ++_resolveGeneration;
    _qrPayload = candidate;
    state = const M2OperationState(
      stage: M2OperationStage.resolving,
      credentialAvailable: true,
    );
    try {
      final membership = await ref
          .read(loyaltyOperationsApiProvider)
          .resolveMembership(qrPayload: candidate, locale: locale);
      if (generation != _resolveGeneration || _qrPayload == null) {
        return;
      }
      state = M2OperationState(
        stage: membership.operational
            ? M2OperationStage.membershipReady
            : M2OperationStage.membershipBlocked,
        membership: membership,
        credentialAvailable: true,
      );
    } on M2ContractViolation {
      _clearCredential();
      state = const M2OperationState(
        stage: M2OperationStage.fatalContractError,
        failure: ApiFailure('INVALID_RESPONSE_BODY'),
      );
    } on AppFailure catch (failure) {
      _clearCredential();
      state = M2OperationState(
        stage: _stageForFailure(failure),
        failure: failure,
      );
    } on Object {
      _clearCredential();
      state = const M2OperationState(
        stage: M2OperationStage.fatalContractError,
        failure: ApiFailure('INTERNAL_ERROR', responseReceived: false),
      );
    }
  }

  void prepareStampReview({
    required int amount,
    required String purchaseAmountText,
    required String transactionReferenceText,
  }) {
    final membership = state.membership;
    if (state.stage != M2OperationStage.membershipReady ||
        membership == null ||
        _qrPayload == null) {
      state = state.copyWith(stage: M2OperationStage.membershipInvalid);
      return;
    }
    if (!membership.earningAllowed) {
      state = state.copyWith(
        stage: membership.locationEligibility.earning
            ? M2OperationStage.policyBlocked
            : M2OperationStage.locationBlocked,
      );
      return;
    }
    if (amount < 1 ||
        amount > membership.operationPolicy.selectableMaximumStampAmount) {
      state = state.copyWith(
        stage: M2OperationStage.policyBlocked,
        failure: const ApiFailure('STAMP_AMOUNT_INVALID'),
      );
      return;
    }
    try {
      final policy = membership.operationPolicy;
      MinorUnitMoney? money;
      if (policy.purchaseRequirementEnabled) {
        money = MinorUnitMoney.parse(
          purchaseAmountText,
          currencyCode: policy.purchaseCurrency!,
        );
        if (money.minorUnits < policy.minimumPurchaseAmountMinor!) {
          throw const MoneyInputException('PURCHASE_THRESHOLD_NOT_MET');
        }
      } else if (purchaseAmountText.trim().isNotEmpty) {
        throw const MoneyInputException('PURCHASE_AMOUNT_NOT_ALLOWED');
      }
      final reference = MerchantTransactionReference.parse(
        transactionReferenceText,
        allowed: policy.merchantTransactionReferenceAllowed,
        required: policy.merchantTransactionReferenceRequired,
      );
      state = state.copyWith(
        stage: M2OperationStage.stampReview,
        stampInput: StampOperationInput(
          amount: amount,
          purchaseAmountMinor: money?.minorUnits,
          purchaseCurrency: money?.currencyCode,
          merchantTransactionReference: reference?.value,
        ),
        clearFailure: true,
      );
    } on MoneyInputException catch (failure) {
      state = state.copyWith(
        stage: M2OperationStage.policyBlocked,
        failure: ApiFailure(failure.code),
      );
    }
  }

  Future<void> confirmStamp({required String locale}) {
    final running = _mutation;
    if (running != null) {
      return running;
    }
    final operation = _confirmStamp(locale: locale);
    _mutation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_mutation, operation)) {
          _mutation = null;
        }
      }),
    );
    return operation;
  }

  Future<void> _confirmStamp({required String locale}) async {
    final membership = state.membership;
    final input = state.stampInput;
    final qr = _qrPayload;
    if (state.stage != M2OperationStage.stampReview ||
        membership == null ||
        input == null ||
        qr == null) {
      return;
    }
    final commandId = ref.read(businessCommandIdGeneratorProvider).next();
    final referenceHash = input.merchantTransactionReference == null
        ? null
        : sha256
              .convert(utf8.encode(input.merchantTransactionReference!))
              .toString();
    final pending = PendingOperationRecord(
      commandId: commandId,
      operationType: PendingOperationType.stamp,
      membershipPublicId: membership.membershipPublicId,
      stampAmount: input.amount,
      purchaseAmountMinor: input.purchaseAmountMinor,
      currency: input.purchaseCurrency,
      transactionReferenceHash: referenceHash,
      createdAt: DateTime.now().toUtc(),
      lastCheckedAt: null,
      status: PendingOperationStatus.submitting,
    );
    await ref.read(pendingOperationStoreProvider).write(pending);
    state = state.copyWith(
      stage: M2OperationStage.stampSubmitting,
      pendingOperation: pending,
      credentialAvailable: false,
      clearFailure: true,
    );
    _qrPayload = null;
    try {
      final result = await ref
          .read(loyaltyOperationsApiProvider)
          .issueStamps(
            qrPayload: qr,
            locale: locale,
            commandId: commandId,
            input: input,
          );
      if (result.beforeProgress != membership.progress.progress ||
          result.progress.progress - result.beforeProgress != input.amount) {
        throw const M2ContractViolation('STAMP_RESULT_PROJECTION_INVALID');
      }
      final completed = pending.checked(
        at: DateTime.now(),
        status: PendingOperationStatus.completed,
      );
      await ref.read(pendingOperationStoreProvider).write(completed);
      state = state.copyWith(
        stage: M2OperationStage.stampSucceeded,
        stampResult: result,
        pendingOperation: completed,
      );
    } on M2ContractViolation {
      state = state.copyWith(
        stage: M2OperationStage.fatalContractError,
        failure: const ApiFailure('INVALID_RESPONSE_BODY'),
      );
    } on AppFailure catch (failure) {
      await _handleMutationFailure(pending, failure);
    } on Object {
      await _markAmbiguous(pending);
    }
  }

  Future<void> prepareRedemption(
    AvailableReward reward, {
    required String locale,
  }) async {
    var membership = state.membership;
    final qr = _qrPayload;
    if (state.stage != M2OperationStage.membershipReady ||
        membership == null ||
        qr == null) {
      return;
    }
    if (!membership.redemptionAllowed) {
      state = state.copyWith(stage: M2OperationStage.locationBlocked);
      return;
    }
    if (reward.requiresManagerApproval) {
      state = state.copyWith(
        stage: M2OperationStage.managerApprovalRequired,
        selectedReward: reward,
      );
      return;
    }
    if (!reward.isRedeemableAt(DateTime.now())) {
      state = state.copyWith(
        stage: M2OperationStage.policyBlocked,
        failure: const ApiFailure('REWARD_NOT_AVAILABLE'),
      );
      return;
    }
    if (!membership.isFreshAt(DateTime.now())) {
      state = state.copyWith(stage: M2OperationStage.resolving);
      try {
        membership = await ref
            .read(loyaltyOperationsApiProvider)
            .resolveMembership(qrPayload: qr, locale: locale);
      } on M2ContractViolation {
        state = state.copyWith(stage: M2OperationStage.fatalContractError);
        return;
      } on AppFailure catch (failure) {
        state = state.copyWith(
          stage: _stageForFailure(failure),
          failure: failure,
        );
        return;
      }
      final refreshed = membership.availableRewards
          .where(
            (candidate) =>
                candidate.entitlementPublicId == reward.entitlementPublicId,
          )
          .firstOrNull;
      if (refreshed == null || !refreshed.isRedeemableAt(DateTime.now())) {
        state = state.copyWith(
          stage: M2OperationStage.policyBlocked,
          membership: membership,
          failure: const ApiFailure('REWARD_NOT_AVAILABLE'),
        );
        return;
      }
      reward = refreshed;
    }
    state = state.copyWith(
      stage: M2OperationStage.redemptionReview,
      membership: membership,
      selectedReward: reward,
      clearFailure: true,
    );
  }

  Future<void> confirmRedemption({required String locale}) {
    final running = _mutation;
    if (running != null) {
      return running;
    }
    final operation = _confirmRedemption(locale: locale);
    _mutation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_mutation, operation)) {
          _mutation = null;
        }
      }),
    );
    return operation;
  }

  Future<void> _confirmRedemption({required String locale}) async {
    final membership = state.membership;
    final reward = state.selectedReward;
    final qr = _qrPayload;
    if (state.stage != M2OperationStage.redemptionReview ||
        membership == null ||
        reward == null ||
        qr == null ||
        reward.requiresManagerApproval) {
      return;
    }
    final commandId = ref.read(businessCommandIdGeneratorProvider).next();
    final pending = PendingOperationRecord(
      commandId: commandId,
      operationType: PendingOperationType.redemption,
      membershipPublicId: membership.membershipPublicId,
      entitlementPublicId: reward.entitlementPublicId,
      finalReward: reward.finalReward,
      createdAt: DateTime.now().toUtc(),
      lastCheckedAt: null,
      status: PendingOperationStatus.submitting,
    );
    await ref.read(pendingOperationStoreProvider).write(pending);
    state = state.copyWith(
      stage: M2OperationStage.redemptionSubmitting,
      pendingOperation: pending,
      credentialAvailable: false,
      clearFailure: true,
    );
    _qrPayload = null;
    try {
      final result = await ref
          .read(loyaltyOperationsApiProvider)
          .redeemReward(
            qrPayload: qr,
            locale: locale,
            commandId: commandId,
            input: RedemptionOperationInput(
              entitlementPublicId: reward.entitlementPublicId,
              finalReward: reward.finalReward,
            ),
          );
      if (result.reward.entitlementPublicId != reward.entitlementPublicId ||
          result.reward.finalReward != reward.finalReward ||
          (!reward.finalReward &&
              result.progress.progress != membership.progress.progress)) {
        throw const M2ContractViolation('REDEMPTION_RESULT_PROJECTION_INVALID');
      }
      final completed = pending.checked(
        at: DateTime.now(),
        status: PendingOperationStatus.completed,
      );
      await ref.read(pendingOperationStoreProvider).write(completed);
      state = state.copyWith(
        stage: M2OperationStage.redemptionSucceeded,
        redemptionResult: result,
        pendingOperation: completed,
      );
    } on M2ContractViolation {
      state = state.copyWith(
        stage: M2OperationStage.fatalContractError,
        failure: const ApiFailure('INVALID_RESPONSE_BODY'),
      );
    } on AppFailure catch (failure) {
      await _handleMutationFailure(pending, failure);
    } on Object {
      await _markAmbiguous(pending);
    }
  }

  Future<void> recoverPending() async {
    final pending =
        state.pendingOperation ??
        ref.read(pendingOperationStoreProvider).read();
    if (pending == null || _mutation != null) {
      return;
    }
    if (pending.isStaleAt(DateTime.now())) {
      state = state.copyWith(
        stage: M2OperationStage.policyBlocked,
        pendingOperation: pending,
        failure: const ApiFailure('OPERATION_RECOVERY_EXPIRED'),
      );
      return;
    }
    try {
      final result = await ref
          .read(loyaltyOperationsApiProvider)
          .commandStatus(pending.commandId);
      if ((pending.operationType == PendingOperationType.stamp &&
              result.operationType != CommandOperationType.stamp) ||
          (pending.operationType == PendingOperationType.redemption &&
              result.operationType != CommandOperationType.redemption)) {
        throw const M2ContractViolation('COMMAND_TYPE_MISMATCH');
      }
      switch (result.status) {
        case CommandRecoveryStatus.processing:
          final processing = pending.checked(
            at: DateTime.now(),
            status: PendingOperationStatus.processing,
          );
          await ref.read(pendingOperationStoreProvider).write(processing);
          state = state.copyWith(
            stage: pending.operationType == PendingOperationType.stamp
                ? M2OperationStage.stampAmbiguous
                : M2OperationStage.redemptionAmbiguous,
            pendingOperation: processing,
          );
        case CommandRecoveryStatus.failed:
          final failed = pending.checked(
            at: DateTime.now(),
            status: PendingOperationStatus.failed,
            failureCode: result.safeFailureCode,
          );
          await ref.read(pendingOperationStoreProvider).write(failed);
          final failure = ApiFailure(
            result.safeFailureCode ?? 'OPERATION_FAILED',
            requestId: result.requestId,
          );
          state = state.copyWith(
            stage: _stageForFailure(failure),
            pendingOperation: failed,
            failure: failure,
          );
        case CommandRecoveryStatus.completed:
          final completed = pending.checked(
            at: DateTime.now(),
            status: PendingOperationStatus.completed,
          );
          await ref.read(pendingOperationStoreProvider).write(completed);
          if (pending.operationType == PendingOperationType.stamp) {
            final stamp = StampOperationResult.fromJson(result.result!);
            state = state.copyWith(
              stage: M2OperationStage.stampSucceeded,
              stampResult: stamp,
              pendingOperation: completed,
            );
          } else {
            final redemption = RedemptionOperationResult.fromJson(
              result.result!,
            );
            state = state.copyWith(
              stage: M2OperationStage.redemptionSucceeded,
              redemptionResult: redemption,
              pendingOperation: completed,
            );
          }
      }
    } on M2ContractViolation {
      state = state.copyWith(stage: M2OperationStage.fatalContractError);
    } on AppFailure catch (failure) {
      if (failure.safeCode == 'OPERATION_NOT_FOUND') {
        final notFound = pending.checked(
          at: DateTime.now(),
          status: PendingOperationStatus.notFound,
          failureCode: failure.safeCode,
        );
        await ref.read(pendingOperationStoreProvider).write(notFound);
        state = state.copyWith(
          stage: M2OperationStage.membershipInvalid,
          pendingOperation: notFound,
          failure: failure,
        );
      } else {
        state = state.copyWith(
          stage: _stageForFailure(failure),
          failure: failure,
        );
      }
    }
  }

  Future<void> acknowledgeAndReset() async {
    await ref.read(pendingOperationStoreProvider).clear();
    _clearCredential();
    state = const M2OperationState.idle();
  }

  void cancelLocalRecoveryView() {
    _clearCredential();
    // Closing the recovery screen does not cancel or hide the server command.
    // Keep the pending state so Home continues to block new mutations and can
    // reopen the same recovery view.
  }

  void returnToMembership() {
    if (state.membership == null) {
      _clearCredential();
      state = const M2OperationState.idle();
      return;
    }
    state = state.copyWith(
      stage: M2OperationStage.membershipReady,
      clearFailure: true,
    );
  }

  void onBackground() {
    _resolveGeneration += 1;
    _clearCredential();
    if (state.stage == M2OperationStage.scanning) {
      state = const M2OperationState.idle();
    } else if (_mutation == null) {
      state = state.copyWith(credentialAvailable: false);
    }
  }

  Future<void> onSessionBlocked() async {
    _clearCredential();
    await ref.read(pendingOperationStoreProvider).clear();
    state = const M2OperationState(stage: M2OperationStage.sessionBlocked);
  }

  Future<void> _handleMutationFailure(
    PendingOperationRecord pending,
    AppFailure failure,
  ) async {
    if (failure.safeCode == 'OPERATION_RESULT_UNKNOWN' ||
        failure is NetworkFailure) {
      await _markAmbiguous(pending);
      return;
    }
    final failed = pending.checked(
      at: DateTime.now(),
      status: PendingOperationStatus.failed,
      failureCode: failure.safeCode,
    );
    await ref.read(pendingOperationStoreProvider).write(failed);
    state = state.copyWith(
      stage: _stageForFailure(failure),
      pendingOperation: failed,
      failure: failure,
    );
  }

  Future<void> _markAmbiguous(PendingOperationRecord pending) async {
    final processing = pending.checked(
      at: DateTime.now(),
      status: PendingOperationStatus.processing,
    );
    await ref.read(pendingOperationStoreProvider).write(processing);
    state = state.copyWith(
      stage: pending.operationType == PendingOperationType.stamp
          ? M2OperationStage.stampAmbiguous
          : M2OperationStage.redemptionAmbiguous,
      pendingOperation: processing,
      failure: const ApiFailure(
        'OPERATION_RESULT_UNKNOWN',
        responseReceived: false,
      ),
    );
  }

  void _clearCredential() => _qrPayload = null;

  static M2OperationStage _stageForFailure(AppFailure failure) =>
      switch (failure.safeCode) {
        'MEMBERSHIP_CREDENTIAL_INVALID' => M2OperationStage.membershipInvalid,
        'MEMBERSHIP_NOT_OPERATIONAL' ||
        'PROGRAM_NOT_OPERATIONAL' => M2OperationStage.membershipBlocked,
        'LOCATION_NOT_AUTHORIZED' ||
        'LOCATION_EARNING_DISABLED' ||
        'LOCATION_REDEMPTION_DISABLED' ||
        'STAFF_ASSIGNMENT_REQUIRED' => M2OperationStage.locationBlocked,
        'STAFF_DEVICE_NOT_ACTIVE' ||
        'STAFF_DEVICE_NOT_FOUND' ||
        'STAFF_DEVICE_REVOKED' ||
        'STAFF_DEVICE_COMPROMISED' ||
        'STAFF_DEVICE_SESSION_EXPIRED' => M2OperationStage.sessionBlocked,
        'MANAGER_APPROVAL_REQUIRED' ||
        'MANAGER_APPROVAL_INVALID' => M2OperationStage.managerApprovalRequired,
        'BACKEND_UNAVAILABLE' => M2OperationStage.networkUnavailable,
        'INVALID_RESPONSE_BODY' => M2OperationStage.fatalContractError,
        _ => M2OperationStage.policyBlocked,
      };
}
