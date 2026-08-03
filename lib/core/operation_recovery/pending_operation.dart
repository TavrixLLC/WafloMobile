import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';

enum PendingOperationType { stamp, redemption }

enum PendingOperationStatus {
  submitting,
  processing,
  completed,
  failed,
  notFound,
}

final class PendingOperationRecord {
  const PendingOperationRecord({
    required this.commandId,
    required this.operationType,
    required this.membershipPublicId,
    required this.createdAt,
    required this.lastCheckedAt,
    required this.status,
    this.stampAmount,
    this.purchaseAmountMinor,
    this.currency,
    this.transactionReferenceHash,
    this.entitlementPublicId,
    this.finalReward,
    this.failureCode,
  });

  static const version = 1;
  static const supportRetention = Duration(days: 7);

  final String commandId;
  final PendingOperationType operationType;
  final String membershipPublicId;
  final DateTime createdAt;
  final DateTime? lastCheckedAt;
  final PendingOperationStatus status;
  final int? stampAmount;
  final int? purchaseAmountMinor;
  final String? currency;
  final String? transactionReferenceHash;
  final String? entitlementPublicId;
  final bool? finalReward;
  final String? failureCode;

  bool isStaleAt(DateTime now) =>
      now.toUtc().difference(createdAt.toUtc()) > supportRetention;

  PendingOperationRecord checked({
    required DateTime at,
    required PendingOperationStatus status,
    String? failureCode,
  }) => PendingOperationRecord(
    commandId: commandId,
    operationType: operationType,
    membershipPublicId: membershipPublicId,
    createdAt: createdAt,
    lastCheckedAt: at.toUtc(),
    status: status,
    stampAmount: stampAmount,
    purchaseAmountMinor: purchaseAmountMinor,
    currency: currency,
    transactionReferenceHash: transactionReferenceHash,
    entitlementPublicId: entitlementPublicId,
    finalReward: finalReward,
    failureCode: failureCode,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'version': version,
    'commandId': commandId,
    'operationType': operationType.name,
    'membershipPublicId': membershipPublicId,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'lastCheckedAt': lastCheckedAt?.toUtc().toIso8601String(),
    'status': status.name,
    if (stampAmount != null) 'stampAmount': stampAmount,
    if (purchaseAmountMinor != null) 'purchaseAmountMinor': purchaseAmountMinor,
    if (currency != null) 'currency': currency,
    if (transactionReferenceHash != null)
      'transactionReferenceHash': transactionReferenceHash,
    if (entitlementPublicId != null) 'entitlementPublicId': entitlementPublicId,
    if (finalReward != null) 'finalReward': finalReward,
    if (failureCode != null) 'failureCode': failureCode,
  };

  static PendingOperationRecord? fromJson(Object? value) {
    if (value is! Map<String, Object?> || value['version'] != version) {
      return null;
    }
    final commandId = value['commandId'];
    final membershipPublicId = value['membershipPublicId'];
    final createdAt = DateTime.tryParse(value['createdAt']?.toString() ?? '');
    final checkedAt = value['lastCheckedAt'] == null
        ? null
        : DateTime.tryParse(value['lastCheckedAt'].toString());
    final operationType = PendingOperationType.values
        .where((candidate) => candidate.name == value['operationType'])
        .firstOrNull;
    final status = PendingOperationStatus.values
        .where((candidate) => candidate.name == value['status'])
        .firstOrNull;
    if (commandId is! String ||
        !isBusinessCommandId(commandId) ||
        membershipPublicId is! String ||
        membershipPublicId.isEmpty ||
        createdAt == null ||
        operationType == null ||
        status == null) {
      return null;
    }
    final record = PendingOperationRecord(
      commandId: commandId,
      operationType: operationType,
      membershipPublicId: membershipPublicId,
      createdAt: createdAt.toUtc(),
      lastCheckedAt: checkedAt?.toUtc(),
      status: status,
      stampAmount: value['stampAmount'] as int?,
      purchaseAmountMinor: value['purchaseAmountMinor'] as int?,
      currency: value['currency'] as String?,
      transactionReferenceHash: value['transactionReferenceHash'] as String?,
      entitlementPublicId: value['entitlementPublicId'] as String?,
      finalReward: value['finalReward'] as bool?,
      failureCode: value['failureCode'] as String?,
    );
    if (record.operationType == PendingOperationType.stamp &&
        (record.stampAmount == null || record.entitlementPublicId != null)) {
      return null;
    }
    if (record.operationType == PendingOperationType.redemption &&
        (record.entitlementPublicId == null || record.stampAmount != null)) {
      return null;
    }
    return record;
  }

  @override
  String toString() =>
      'PendingOperationRecord(type: ${operationType.name}, status: ${status.name}, identifiers: [REDACTED])';
}

abstract interface class PendingOperationStore {
  PendingOperationRecord? read();
  Future<void> write(PendingOperationRecord record);
  Future<void> clear();
}

final class SharedPreferencesPendingOperationStore
    implements PendingOperationStore {
  SharedPreferencesPendingOperationStore(this._preferences);

  static const _key = 'm2.pending_operation.v1';
  final SharedPreferences _preferences;

  @override
  PendingOperationRecord? read() {
    final encoded = _preferences.getString(_key);
    if (encoded == null) {
      return null;
    }
    try {
      return PendingOperationRecord.fromJson(jsonDecode(encoded));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(PendingOperationRecord record) =>
      _preferences.setString(_key, jsonEncode(record.toJson()));

  @override
  Future<void> clear() => _preferences.remove(_key);
}

final class MemoryPendingOperationStore implements PendingOperationStore {
  PendingOperationRecord? value;

  @override
  PendingOperationRecord? read() => value;

  @override
  Future<void> write(PendingOperationRecord record) async => value = record;

  @override
  Future<void> clear() async => value = null;
}
