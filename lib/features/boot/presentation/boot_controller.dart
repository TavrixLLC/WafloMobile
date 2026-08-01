import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

enum BootStage {
  initializing,
  unpaired,
  pairingInProgress,
  pairedLoadingContext,
  pairedReady,
  sessionRefreshRequired,
  sessionExpired,
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
      final session = await sessionRepository.read();
      final identity = await identityRepository.load();
      final transaction = await transactionRepository.readStage();
      if (session == null) {
        if (transaction == PairingTransactionStage.completing ||
            transaction == PairingTransactionStage.persisting) {
          state = const BootState(
            stage: BootStage.fatalLocalSecurityError,
            failure: SecurePersistenceFailure(),
          );
          return;
        }
        if (transaction != null) {
          await transactionRepository.clear();
        }
        state = const BootState(stage: BootStage.unpaired);
        return;
      }
      if (identity == null) {
        state = const BootState(
          stage: BootStage.fatalLocalSecurityError,
          failure: LocalSecurityFailure('LOCAL_KEY_MISSING'),
        );
        return;
      }
      if (session.deviceStatus == 'REVOKED') {
        state = BootState(
          stage: BootStage.deviceRevoked,
          session: session,
          failure: const ApiFailure('DEVICE_REVOKED'),
        );
        return;
      }
      if (session.deviceStatus == 'COMPROMISED') {
        state = BootState(
          stage: BootStage.deviceCompromised,
          session: session,
          failure: const ApiFailure('DEVICE_COMPROMISED'),
        );
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
    ref.read(pairingControllerProvider.notifier).reset();
    state = const BootState(stage: BootStage.unpaired);
  }

  Future<void> resetForRepair() async {
    await ref.read(sessionRepositoryProvider).clear();
    await ref.read(identityRepositoryProvider).delete();
    await ref.read(pairingTransactionRepositoryProvider).clear();
    await ref.read(preferencesRepositoryProvider).clearSafeContext();
    ref.read(pairingControllerProvider.notifier).reset();
    state = const BootState(stage: BootStage.unpaired);
  }

  void _setFailure(AppFailure failure) {
    state = BootState(
      stage: switch (classifyFailure(failure)) {
        FailureDisposition.deviceRevoked => BootStage.deviceRevoked,
        FailureDisposition.deviceCompromised => BootStage.deviceCompromised,
        FailureDisposition.updateRequired => BootStage.appUpdateRequired,
        FailureDisposition.sessionExpired => BootStage.sessionExpired,
        FailureDisposition.backendUnavailable => BootStage.backendUnavailable,
        FailureDisposition.localSecurity => BootStage.fatalLocalSecurityError,
        _ => BootStage.backendUnavailable,
      },
      failure: failure,
      session: state.session,
    );
  }
}
