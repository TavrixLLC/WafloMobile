import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

enum BootStage {
  initializing,
  unpaired,
  pairingInProgress,
  pairedLoadingContext,
  pairedReady,
  localReviewReady,
  devicePending,
  sessionRefreshRequired,
  sessionExpired,
  staffUserDeactivated,
  staffMembershipInactive,
  staffLocationAssignmentInvalid,
  deviceRevoked,
  deviceCompromised,
  appUpdateRequired,
  backendUnavailable,
  configurationError,
  fatalLocalSecurityError,
}

final class BootState {
  const BootState({
    required this.stage,
    this.context,
    this.session,
    this.failure,
  });

  const BootState.initializing() : this(stage: BootStage.initializing);

  final BootStage stage;
  final AuthoritativeDeviceContext? context;
  final StaffDeviceSession? session;
  final AppFailure? failure;
}

final class BootController extends Notifier<BootState> {
  DateTime? _lastContextRefresh;
  Future<void>? _initialization;

  @override
  BootState build() => const BootState.initializing();

  Future<void> initialize() {
    final running = _initialization;
    if (running != null) {
      return running;
    }
    final operation = _initialize();
    _initialization = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_initialization, operation)) {
          _initialization = null;
        }
      }),
    );
    return operation;
  }

  Future<void> _initialize() async {
    state = const BootState.initializing();
    final environment = ref.read(environmentProvider);
    final issues = environment.validate();
    if (issues.isNotEmpty) {
      state = BootState(
        stage: BootStage.configurationError,
        failure: ConfigurationFailure(issues),
      );
      return;
    }
    try {
      final sessionRepository = ref.read(sessionRepositoryProvider);
      final identityRepository = ref.read(identityRepositoryProvider);
      final transactionRepository = ref.read(
        pairingTransactionRepositoryProvider,
      );
      final lifecycleRepository = ref.read(localLifecycleRepositoryProvider);
      final session = await sessionRepository.read();
      final identity = await identityRepository.load();
      final transaction = await transactionRepository.read();
      final lifecycle = await lifecycleRepository.read();

      if (session?.isReview == true ||
          transaction?.sessionMode == StaffSessionMode.review) {
        // Older builds could create backend-backed REVIEW sessions. They are
        // intentionally non-migratable into the frontend-only Review mode.
        await sessionRepository.clear();
        await identityRepository.delete();
        await transactionRepository.clear();
        await ref.read(preferencesRepositoryProvider).clearSafeContext();
        await ref.read(localReviewAccessProvider).deactivate();
        await lifecycleRepository.mark(LocalLifecycleState.neverPaired);
        state = const BootState(stage: BootStage.unpaired);
        return;
      }

      if (await ref
          .read(localDemoControllerProvider.notifier)
          .restoreIfActive()) {
        state = BootState(
          stage: BootStage.localReviewReady,
          context: ref.read(localDemoRuntimeProvider).deviceContext,
        );
        return;
      }

      if (lifecycle?.state == LocalLifecycleState.loggedOut) {
        await sessionRepository.clear();
        await identityRepository.delete();
        await transactionRepository.clear();
        state = const BootState(stage: BootStage.unpaired);
        return;
      }

      if (identity == null) {
        if (session == null && transaction == null) {
          await lifecycleRepository.mark(LocalLifecycleState.neverPaired);
          state = const BootState(stage: BootStage.unpaired);
          return;
        }
        await lifecycleRepository.mark(
          LocalLifecycleState.recoveryRequired,
          reason: 'LOCAL_KEY_MISSING',
        );
        state = const BootState(
          stage: BootStage.fatalLocalSecurityError,
          failure: LocalSecurityFailure('LOCAL_KEY_MISSING'),
        );
        return;
      }

      if (transaction != null) {
        if (session != null || transaction.isCompletionAmbiguous) {
          await lifecycleRepository.mark(
            LocalLifecycleState.recoveryRequired,
            reason: 'PAIRING_COMPLETION_AMBIGUOUS',
          );
          state = const BootState(
            stage: BootStage.fatalLocalSecurityError,
            failure: SecurePersistenceFailure(),
          );
          return;
        }
        state = const BootState(stage: BootStage.pairingInProgress);
        try {
          final result = await ref
              .read(pairingFlowServiceProvider)
              .resume(onProgress: (_) {});
          final restoredSession = await sessionRepository.read();
          _lastContextRefresh = DateTime.now().toUtc();
          state = BootState(
            stage: BootStage.pairedReady,
            context: result.context,
            session: restoredSession,
          );
        } on AppFailure catch (failure) {
          if (failure.safeCode == 'DEVICE_PAIRING_EXPIRED') {
            ref
                .read(pairingControllerProvider.notifier)
                .showExternalFailure(failure);
            state = const BootState(stage: BootStage.unpaired);
          } else {
            _setFailure(failure);
          }
        }
        return;
      }

      if (session == null) {
        if (lifecycle?.state == LocalLifecycleState.paired ||
            lifecycle?.state == LocalLifecycleState.pairing ||
            lifecycle?.state == LocalLifecycleState.recoveryRequired) {
          final reason = lifecycle?.reason ?? 'LOCAL_SESSION_MISSING';
          state = BootState(
            stage: _stageForRecoveryReason(reason),
            failure: LocalSecurityFailure(reason),
          );
          return;
        }
        await identityRepository.delete();
        await lifecycleRepository.mark(LocalLifecycleState.neverPaired);
        state = const BootState(stage: BootStage.unpaired);
        return;
      }

      if (lifecycle != null && lifecycle.state != LocalLifecycleState.paired) {
        await lifecycleRepository.mark(
          LocalLifecycleState.recoveryRequired,
          reason: lifecycle.reason ?? 'LOCAL_LIFECYCLE_MISMATCH',
          requestId: lifecycle.requestId,
        );
        state = const BootState(
          stage: BootStage.fatalLocalSecurityError,
          failure: LocalSecurityFailure('LOCAL_LIFECYCLE_MISMATCH'),
        );
        return;
      }
      await lifecycleRepository.mark(LocalLifecycleState.paired);
      if (session.deviceStatus == 'REVOKED') {
        const failure = ApiFailure('STAFF_DEVICE_REVOKED', httpStatus: 401);
        await sessionRepository.clear();
        await lifecycleRepository.mark(
          LocalLifecycleState.recoveryRequired,
          reason: failure.safeCode,
        );
        state = BootState(stage: BootStage.deviceRevoked, failure: failure);
        return;
      }
      if (session.deviceStatus == 'PENDING') {
        state = BootState(stage: BootStage.devicePending, session: session);
        return;
      }
      if (session.deviceStatus == 'COMPROMISED') {
        const failure = ApiFailure('STAFF_DEVICE_COMPROMISED', httpStatus: 401);
        await sessionRepository.clear();
        await lifecycleRepository.mark(
          LocalLifecycleState.recoveryRequired,
          reason: failure.safeCode,
        );
        state = BootState(stage: BootStage.deviceCompromised, failure: failure);
        return;
      }
      state = BootState(
        stage: session.isExpired(DateTime.now())
            ? BootStage.sessionRefreshRequired
            : BootStage.pairedLoadingContext,
        session: session,
      );
      final context = await ref.read(sessionManagerProvider).loadContext();
      final current = await sessionRepository.read();
      _lastContextRefresh = DateTime.now().toUtc();
      state = BootState(
        stage: BootStage.pairedReady,
        context: context,
        session: current,
      );
    } on AppFailure catch (failure) {
      _setFailure(failure);
    } on Object {
      _setFailure(const ApiFailure('INTERNAL_ERROR', responseReceived: false));
    }
  }

  Future<void> refreshContext() async {
    if (ref.read(localDemoControllerProvider).active) return;
    if (state.stage != BootStage.pairedReady &&
        state.stage != BootStage.backendUnavailable) {
      return;
    }
    state = BootState(
      stage: BootStage.pairedLoadingContext,
      session: state.session,
    );
    try {
      final context = await ref.read(sessionManagerProvider).loadContext();
      final current = await ref.read(sessionRepositoryProvider).read();
      _lastContextRefresh = DateTime.now().toUtc();
      state = BootState(
        stage: BootStage.pairedReady,
        context: context,
        session: current,
      );
    } on AppFailure catch (failure) {
      _setFailure(failure);
    }
  }

  Future<void> onResume() async {
    if (ref.read(localDemoControllerProvider).active) return;
    final last = _lastContextRefresh;
    if (state.stage == BootStage.pairedReady &&
        (last == null ||
            DateTime.now().toUtc().difference(last) >
                const Duration(minutes: 5))) {
      await refreshContext();
    }
  }

  Future<void> logout() async {
    await ref.read(sessionManagerProvider).logout();
    await ref.read(pendingOperationStoreProvider).clear();
    ref.read(pairingControllerProvider.notifier).reset();
    await ref
        .read(m2OperationControllerProvider.notifier)
        .acknowledgeAndReset();
    state = const BootState(stage: BootStage.unpaired);
  }

  Future<void> exitReviewMode() async {
    if (!ref.read(localDemoControllerProvider).active) {
      throw const LocalSecurityFailure('REVIEW_SESSION_INVALID');
    }
    await ref.read(localDemoControllerProvider.notifier).exit();
    await ref.read(pendingOperationStoreProvider).clear();
    state = const BootState(stage: BootStage.unpaired);
  }

  Future<void> resetForRepair() async {
    await ref.read(sessionRepositoryProvider).clear();
    await ref.read(identityRepositoryProvider).delete();
    await ref.read(pairingTransactionRepositoryProvider).clear();
    await ref.read(pendingOperationStoreProvider).clear();
    await ref.read(preferencesRepositoryProvider).clearSafeContext();
    await ref
        .read(localLifecycleRepositoryProvider)
        .mark(LocalLifecycleState.neverPaired);
    ref.read(pairingControllerProvider.notifier).reset();
    state = const BootState(stage: BootStage.unpaired);
  }

  Future<void> pairAgainAfterRevocation() async {
    if (state.stage != BootStage.deviceRevoked) return;
    await resetForRepair();
  }

  void _setFailure(AppFailure failure) {
    final disposition = classifyFailure(failure);
    if (disposition == FailureDisposition.deviceRevoked ||
        disposition == FailureDisposition.deviceCompromised ||
        disposition == FailureDisposition.sessionExpired ||
        disposition == FailureDisposition.staffUserDeactivated ||
        disposition == FailureDisposition.staffMembershipInactive ||
        disposition == FailureDisposition.staffLocationAssignmentInvalid) {
      unawaited(
        ref.read(m2OperationControllerProvider.notifier).onSessionBlocked(),
      );
    }
    final preserveSession =
        disposition == FailureDisposition.updateRequired ||
        disposition == FailureDisposition.backendUnavailable;
    state = BootState(
      stage: switch (disposition) {
        FailureDisposition.deviceRevoked => BootStage.deviceRevoked,
        FailureDisposition.deviceCompromised => BootStage.deviceCompromised,
        FailureDisposition.staffUserDeactivated =>
          BootStage.staffUserDeactivated,
        FailureDisposition.staffMembershipInactive =>
          BootStage.staffMembershipInactive,
        FailureDisposition.staffLocationAssignmentInvalid =>
          BootStage.staffLocationAssignmentInvalid,
        FailureDisposition.updateRequired => BootStage.appUpdateRequired,
        FailureDisposition.sessionExpired => BootStage.sessionExpired,
        FailureDisposition.backendUnavailable => BootStage.backendUnavailable,
        FailureDisposition.localSecurity => BootStage.fatalLocalSecurityError,
        _ => BootStage.backendUnavailable,
      },
      failure: failure,
      session: preserveSession ? state.session : null,
    );
  }

  BootStage _stageForRecoveryReason(String reason) => switch (reason) {
    'STAFF_DEVICE_REVOKED' => BootStage.deviceRevoked,
    'STAFF_DEVICE_COMPROMISED' => BootStage.deviceCompromised,
    'STAFF_USER_DEACTIVATED' => BootStage.staffUserDeactivated,
    'STAFF_MEMBERSHIP_INACTIVE' => BootStage.staffMembershipInactive,
    'STAFF_LOCATION_ASSIGNMENT_INVALID' =>
      BootStage.staffLocationAssignmentInvalid,
    'STAFF_DEVICE_SESSION_EXPIRED' ||
    'STAFF_DEVICE_NOT_ACTIVE' => BootStage.sessionExpired,
    _ => BootStage.fatalLocalSecurityError,
  };
}
