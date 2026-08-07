// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_command_status_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationCommandStatusResult _$OperationCommandStatusResultFromJson(
  Map<String, dynamic> json,
) => OperationCommandStatusResult(
  commandId: json['commandId'] as String,
  operationPublicId: json['operationPublicId'] as String,
  operationType: OperationCommandStatusResultOperationType.fromJson(
    json['operationType'] as String,
  ),
  status: OperationCommandStatusResultStatus.fromJson(json['status'] as String),
  result: json['result'],
  safeFailureCode: json['safeFailureCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$OperationCommandStatusResultToJson(
  OperationCommandStatusResult instance,
) => <String, dynamic>{
  'commandId': instance.commandId,
  'operationPublicId': instance.operationPublicId,
  'operationType':
      _$OperationCommandStatusResultOperationTypeEnumMap[instance
          .operationType]!,
  'status': _$OperationCommandStatusResultStatusEnumMap[instance.status]!,
  'result': instance.result,
  'safeFailureCode': instance.safeFailureCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$OperationCommandStatusResultOperationTypeEnumMap = {
  OperationCommandStatusResultOperationType.issueStamp: 'ISSUE_STAMP',
  OperationCommandStatusResultOperationType.redeemReward: 'REDEEM_REWARD',
  OperationCommandStatusResultOperationType.reverseStamp: 'REVERSE_STAMP',
  OperationCommandStatusResultOperationType.reverseRedemption:
      'REVERSE_REDEMPTION',
  OperationCommandStatusResultOperationType.manualAdjustment:
      'MANUAL_ADJUSTMENT',
  OperationCommandStatusResultOperationType.suspendMembership:
      'SUSPEND_MEMBERSHIP',
  OperationCommandStatusResultOperationType.restoreMembership:
      'RESTORE_MEMBERSHIP',
  OperationCommandStatusResultOperationType.revokeMembership:
      'REVOKE_MEMBERSHIP',
  OperationCommandStatusResultOperationType.expireReward: 'EXPIRE_REWARD',
  OperationCommandStatusResultOperationType.$unknown: r'$unknown',
};

const _$OperationCommandStatusResultStatusEnumMap = {
  OperationCommandStatusResultStatus.processing: 'PROCESSING',
  OperationCommandStatusResultStatus.completed: 'COMPLETED',
  OperationCommandStatusResultStatus.failed: 'FAILED',
  OperationCommandStatusResultStatus.$unknown: r'$unknown',
};
