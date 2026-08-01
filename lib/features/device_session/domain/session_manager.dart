import 'dart:async';

import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
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
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final StaffDeviceSessionRepository _sessionRepository;
  final DeviceSessionApi _api;
  final DeviceIdentityRepository _identityRepository;
  final PreferencesRepository _preferencesRepository;
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
    final replacement = await _api.refresh(current);
    try {
      await _sessionRepository.replaceAtomically(replacement);
      return replacement;
    } on SecurePersistenceFailure {
      await _sessionRepository.clear();
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
    if (refreshIfExpired && session.isExpired(_now())) {
      session = await refreshSingleFlight();
    }
    final context = await _api.getContext(session);
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
    await _preferencesRepository.clearSafeContext();
    return LogoutResult(serverReached: serverReached);
  }
}
