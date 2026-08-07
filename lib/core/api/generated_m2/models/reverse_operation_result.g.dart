// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_operation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReverseOperationResult _$ReverseOperationResultFromJson(
  Map<String, dynamic> json,
) => ReverseOperationResult(
  operationPublicId: json['operationPublicId'] as String,
  commandId: json['commandId'] as String,
  reversedOperationPublicId: json['reversedOperationPublicId'] as String,
  replayed: json['replayed'] as bool,
  progress: (json['progress'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  projectionVersion: (json['projectionVersion'] as num).toInt(),
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$ReverseOperationResultToJson(
  ReverseOperationResult instance,
) => <String, dynamic>{
  'operationPublicId': instance.operationPublicId,
  'commandId': instance.commandId,
  'reversedOperationPublicId': instance.reversedOperationPublicId,
  'replayed': instance.replayed,
  'progress': instance.progress,
  'rewardReady': instance.rewardReady,
  'completedCycles': instance.completedCycles,
  'projectionVersion': instance.projectionVersion,
  'requestId': instance.requestId,
};
