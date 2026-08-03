// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stamp_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StampResult _$StampResultFromJson(Map<String, dynamic> json) => StampResult(
  operationPublicId: json['operationPublicId'] as String,
  commandId: json['commandId'] as String,
  replayed: json['replayed'] as bool,
  beforeProgress: (json['beforeProgress'] as num).toInt(),
  progress: (json['progress'] as num).toInt(),
  goal: (json['goal'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  projectionVersion: (json['projectionVersion'] as num).toInt(),
  unlockedRewards: (json['unlockedRewards'] as List<dynamic>)
      .map((e) => UnlockedRewards.fromJson(e as Map<String, dynamic>))
      .toList(),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$StampResultToJson(StampResult instance) =>
    <String, dynamic>{
      'operationPublicId': instance.operationPublicId,
      'commandId': instance.commandId,
      'replayed': instance.replayed,
      'beforeProgress': instance.beforeProgress,
      'progress': instance.progress,
      'goal': instance.goal,
      'rewardReady': instance.rewardReady,
      'completedCycles': instance.completedCycles,
      'projectionVersion': instance.projectionVersion,
      'unlockedRewards': instance.unlockedRewards,
      'requestId': instance.requestId,
    };
