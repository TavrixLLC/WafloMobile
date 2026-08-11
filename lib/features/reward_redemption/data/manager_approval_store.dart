import 'dart:convert';

import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';

abstract interface class ManagerApprovalIntentStore {
  Future<ManagerApprovalIntent?> read();
  Future<void> write(ManagerApprovalIntent intent);
  Future<void> clear();
}

final class SecureManagerApprovalIntentStore
    implements ManagerApprovalIntentStore {
  SecureManagerApprovalIntentStore(this._store);

  static const _key = 'loyalty.manager_approval_intent.v1';
  final SecureKeyValueStore _store;

  @override
  Future<ManagerApprovalIntent?> read() async {
    final encoded = await _store.read(_key);
    if (encoded == null) return null;
    try {
      return ManagerApprovalIntent.fromJson(jsonDecode(encoded));
    } on Object {
      throw const LocalSecurityFailure('LOCAL_APPROVAL_INTENT_CORRUPT');
    }
  }

  @override
  Future<void> write(ManagerApprovalIntent intent) async {
    try {
      await _store.write(_key, jsonEncode(intent.toJson()));
      final verified = await read();
      if (verified?.commandId != intent.commandId ||
          verified?.approvalPublicId != intent.approvalPublicId) {
        throw const FormatException('Approval intent verification failed.');
      }
    } on AppFailure {
      rethrow;
    } on Object {
      throw const SecurePersistenceFailure();
    }
  }

  @override
  Future<void> clear() => _store.delete(_key);
}

final class MemoryManagerApprovalIntentStore
    implements ManagerApprovalIntentStore {
  ManagerApprovalIntent? value;

  @override
  Future<ManagerApprovalIntent?> read() async => value;

  @override
  Future<void> write(ManagerApprovalIntent intent) async => value = intent;

  @override
  Future<void> clear() async => value = null;
}
