import 'dart:async';

import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

final class LogoutResult {
  const LogoutResult({required this.serverReached});

  final bool serverReached;
}

final class SessionManager {
  SessionManager(
    this._sessionRepository,
    this._api,
    this._identityRepository,
    this._preferencesRepository, {
    required LocalLifecycleRepository lifecycleRepository,
    required PairingTransactionRepository transactionRepository,
    DateTime Function()? now,
  }) : // Public named parameters intentionally initialize private fields.
       // ignore: prefer_initializing_formals
       _lifecycleRepository = lifecycleRepository,
       // ignore: prefer_initializing_formals
       _transactionRepository = transactionRepository,
       _now = now ?? DateTime.now;

  final StaffDeviceSessionRepository _sessionRepository;
  final DeviceSessionApi _api;
  final DeviceIdentityRepository _identityRepository;
  final PreferencesRepository _preferencesRepository;
  final LocalLifecycleRepository _lifecycleRepository;
  final PairingTransactionRepository _transactionRepository;
  final DateTime Function() _now;
  Future<StaffDeviceSession>? _refreshInFlight;

  Future<StaffDeviceSession> refreshSingleFlight() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final operation = _performRefresh();
    _refreshInFlight = operation;
    unawaited(
      operation.then<void>(
        (_) {
          if (identical(_refreshInFlight, operation)) {
            _refreshInFlight = null;
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_refreshInFlight, operation)) {
            _refreshInFlight = null;
          }
        },
      ),
    );
    return operation;
  }

  Future<StaffDeviceSession> _performRefresh() async {
    final current = await _sessionRepository.read();
    if (current == null) {
      throw const ApiFailure('STAFF_DEVICE_NOT_ACTIVE', httpStatus: 401);
    }
    if (!current.accessExpiresAt.isAfter(_now().toUtc())) {
      const failure = ApiFailure(
        'STAFF_DEVICE_SESSION_EXPIRED',
        httpStatus: 401,
      );
      await _handleConclusiveBlockedFailure(failure);
      throw failure;
    }
    late final StaffDeviceSession replacement;
    try {
      replacement = await _api.refresh(current);
    } on AppFailure catch (failure) {
      await _handleConclusiveBlockedFailure(failure);
      rethrow;
    }
    try {
      await _sessionRepository.replaceAtomically(replacement);
      await _lifecycleRepository.mark(LocalLifecycleState.paired);
      return replacement;
    } on SecurePersistenceFailure {
      await _sessionRepository.clear();
      await _lifecycleRepository.mark(
        LocalLifecycleState.recoveryRequired,
        reason: 'REFRESH_ROTATED_LOCAL_REPLACEMENT_FAILED',
      );
      rethrow;
    }
  }

  Future<AuthoritativeDeviceContext> loadContext({
    bool refreshIfExpired = true,
  }) async {
    var session = await _sessionRepository.read();
    if (session == null) {
      throw const ApiFailure('STAFF_DEVICE_NOT_ACTIVE', httpStatus: 401);
    }
    if (!session.accessExpiresAt.isAfter(_now().toUtc())) {
      const failure = ApiFailure(
        'STAFF_DEVICE_SESSION_EXPIRED',
        httpStatus: 401,
      );
      await _handleConclusiveBlockedFailure(failure);
      throw failure;
    }
    if (refreshIfExpired &&
        session.accessExpiresAt.difference(_now().toUtc()) <=
            const Duration(minutes: 5)) {
      session = await refreshSingleFlight();
    }
    late final AuthoritativeDeviceContext context;
    try {
      context = await _api.getContext(session);
    } on AppFailure catch (failure) {
      await _handleConclusiveBlockedFailure(failure);
      rethrow;
    }
    await _preferencesRepository.setSafeContext(
      SafeContextCache(
        role: context.role,
        platform: context.platform,
        deviceDisplayName: session.deviceDisplayName,
        lastSynchronizedAt: context.synchronizedAt,
      ),
    );
    return context;
  }

  Future<LogoutResult> logout() async {
    final current = await _sessionRepository.read();
    var serverReached = false;
    if (current != null) {
      try {
        await _api.logout(current);
        serverReached = true;
      } on AppFailure {
        serverReached = false;
      }
    }
    await _sessionRepository.clear();
    await _identityRepository.delete();
    await _transactionRepository.clear();
    await _preferencesRepository.clearSafeContext();
    await _lifecycleRepository.mark(LocalLifecycleState.loggedOut);
    return LogoutResult(serverReached: serverReached);
  }

  Future<void> _handleConclusiveBlockedFailure(AppFailure failure) async {
    final disposition = classifyFailure(failure);
    if (disposition != FailureDisposition.deviceRevoked &&
        disposition != FailureDisposition.deviceCompromised &&
        disposition != FailureDisposition.sessionExpired &&
        disposition != FailureDisposition.staffUserDeactivated &&
        disposition != FailureDisposition.staffMembershipInactive &&
        disposition != FailureDisposition.staffLocationAssignmentInvalid) {
      return;
    }
    await _sessionRepository.clear();
    await _lifecycleRepository.mark(
      LocalLifecycleState.recoveryRequired,
      reason: failure.safeCode,
      requestId: failure.requestId,
    );
  }
}
