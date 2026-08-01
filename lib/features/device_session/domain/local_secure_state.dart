import 'dart:convert';

import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

enum LocalLifecycleState {
  neverPaired,
  pairing,
  paired,
  recoveryRequired,
  loggedOut,
}

final class LocalLifecycleMarker {
  const LocalLifecycleMarker({
    required this.state,
    required this.updatedAt,
    this.reason,
    this.requestId,
  });

  final LocalLifecycleState state;
  final DateTime updatedAt;
  final String? reason;
  final String? requestId;
}

final class LocalLifecycleRepository {
  LocalLifecycleRepository(this._store, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _key = 'staff_device.lifecycle.v1';
  static const _recordVersion = 1;

  final SecureKeyValueStore _store;
  final DateTime Function() _now;

  Future<LocalLifecycleMarker?> read() async {
    final raw = await _store.read(_key);
    if (raw == null) {
      return null;
    }
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> ||
          value['recordVersion'] != _recordVersion) {
        return _corruptMarker();
      }
      final stateName = value['state'];
      final updatedAt = DateTime.tryParse(value['updatedAt'] as String? ?? '');
      if (stateName is! String || updatedAt == null) {
        return _corruptMarker();
      }
      final state = LocalLifecycleState.values.firstWhere(
        (candidate) => candidate.name == stateName,
        orElse: () => LocalLifecycleState.recoveryRequired,
      );
      return LocalLifecycleMarker(
        state: state,
        updatedAt: updatedAt.toUtc(),
        reason: value['reason'] as String?,
        requestId: value['requestId'] as String?,
      );
    } on Object {
      return _corruptMarker();
    }
  }

  Future<void> mark(
    LocalLifecycleState state, {
    String? reason,
    String? requestId,
  }) async {
    try {
      await _store.write(
        _key,
        jsonEncode({
          'recordVersion': _recordVersion,
          'state': state.name,
          'reason': ?reason,
          'requestId': ?requestId,
          'updatedAt': _now().toUtc().toIso8601String(),
        }),
      );
      final verified = await read();
      if (verified == null || verified.state != state) {
        throw const FormatException('Lifecycle verification failed.');
      }
    } on SecurePersistenceFailure {
      rethrow;
    } on Object {
      throw const SecurePersistenceFailure();
    }
  }

  LocalLifecycleMarker _corruptMarker() => LocalLifecycleMarker(
    state: LocalLifecycleState.recoveryRequired,
    updatedAt: _now().toUtc(),
    reason: 'LOCAL_LIFECYCLE_CORRUPT',
  );
}
