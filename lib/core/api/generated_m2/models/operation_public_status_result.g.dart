// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_public_status_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationPublicStatusResult _$OperationPublicStatusResultFromJson(
  Map<String, dynamic> json,
) => OperationPublicStatusResult(
  publicId: json['publicId'] as String,
  operationPublicId: json['operationPublicId'] as String,
  commandId: json['commandId'] as String,
  operationType: OperationPublicStatusResultOperationType.fromJson(
    json['operationType'] as String,
  ),
  status: OperationPublicStatusResultStatus.fromJson(json['status'] as String),
  resultProjectionVersion: (json['resultProjectionVersion'] as num?)?.toInt(),
  resultPayload: json['resultPayload'],
  safeFailureCode: json['safeFailureCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$OperationPublicStatusResultToJson(
  OperationPublicStatusResult instance,
) => <String, dynamic>{
  'publicId': instance.publicId,
  'operationPublicId': instance.operationPublicId,
  'commandId': instance.commandId,
  'operationType':
      _$OperationPublicStatusResultOperationTypeEnumMap[instance
          .operationType]!,
  'status': _$OperationPublicStatusResultStatusEnumMap[instance.status]!,
  'resultProjectionVersion': instance.resultProjectionVersion,
  'resultPayload': instance.resultPayload,
  'safeFailureCode': instance.safeFailureCode,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$OperationPublicStatusResultOperationTypeEnumMap = {
  OperationPublicStatusResultOperationType.issueStamp: 'ISSUE_STAMP',
  OperationPublicStatusResultOperationType.redeemReward: 'REDEEM_REWARD',
  OperationPublicStatusResultOperationType.reverseStamp: 'REVERSE_STAMP',
  OperationPublicStatusResultOperationType.reverseRedemption:
      'REVERSE_REDEMPTION',
  OperationPublicStatusResultOperationType.manualAdjustment:
      'MANUAL_ADJUSTMENT',
  OperationPublicStatusResultOperationType.suspendMembership:
      'SUSPEND_MEMBERSHIP',
  OperationPublicStatusResultOperationType.restoreMembership:
      'RESTORE_MEMBERSHIP',
  OperationPublicStatusResultOperationType.revokeMembership:
      'REVOKE_MEMBERSHIP',
  OperationPublicStatusResultOperationType.expireReward: 'EXPIRE_REWARD',
  OperationPublicStatusResultOperationType.$unknown: r'$unknown',
};

const _$OperationPublicStatusResultStatusEnumMap = {
  OperationPublicStatusResultStatus.processing: 'PROCESSING',
  OperationPublicStatusResultStatus.completed: 'COMPLETED',
  OperationPublicStatusResultStatus.failed: 'FAILED',
  OperationPublicStatusResultStatus.$unknown: r'$unknown',
};
