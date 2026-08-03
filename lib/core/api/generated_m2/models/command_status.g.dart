// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'command_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandStatus _$CommandStatusFromJson(Map<String, dynamic> json) =>
    CommandStatus(
      commandId: json['commandId'] as String,
      operationPublicId: json['operationPublicId'] as String?,
      operationType: CommandStatusOperationType.fromJson(
        json['operationType'] as String,
      ),
      status: CommandStatusStatus.fromJson(json['status'] as String),
      safeFailureCode: json['safeFailureCode'] as String?,
      result: json['result'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$CommandStatusToJson(
  CommandStatus instance,
) => <String, dynamic>{
  'commandId': instance.commandId,
  'operationPublicId': instance.operationPublicId,
  'operationType': _$CommandStatusOperationTypeEnumMap[instance.operationType]!,
  'status': _$CommandStatusStatusEnumMap[instance.status]!,
  'safeFailureCode': instance.safeFailureCode,
  'result': instance.result,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'requestId': instance.requestId,
};

const _$CommandStatusOperationTypeEnumMap = {
  CommandStatusOperationType.stamp: 'STAMP',
  CommandStatusOperationType.redemption: 'REDEMPTION',
  CommandStatusOperationType.$unknown: r'$unknown',
};

const _$CommandStatusStatusEnumMap = {
  CommandStatusStatus.processing: 'PROCESSING',
  CommandStatusStatus.failed: 'FAILED',
  CommandStatusStatus.completed: 'COMPLETED',
  CommandStatusStatus.$unknown: r'$unknown',
};
