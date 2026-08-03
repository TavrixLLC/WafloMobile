// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedemptionResult _$RedemptionResultFromJson(Map<String, dynamic> json) =>
    RedemptionResult(
      operationPublicId: json['operationPublicId'] as String,
      commandId: json['commandId'] as String,
      replayed: json['replayed'] as bool,
      redemptionPublicId: json['redemptionPublicId'] as String,
      reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      progress: (json['progress'] as num).toInt(),
      goal: (json['goal'] as num).toInt(),
      rewardReady: json['rewardReady'] as bool,
      completedCycles: (json['completedCycles'] as num).toInt(),
      projectionVersion: (json['projectionVersion'] as num).toInt(),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$RedemptionResultToJson(RedemptionResult instance) =>
    <String, dynamic>{
      'operationPublicId': instance.operationPublicId,
      'commandId': instance.commandId,
      'replayed': instance.replayed,
      'redemptionPublicId': instance.redemptionPublicId,
      'reward': instance.reward,
      'progress': instance.progress,
      'goal': instance.goal,
      'rewardReady': instance.rewardReady,
      'completedCycles': instance.completedCycles,
      'projectionVersion': instance.projectionVersion,
      'requestId': instance.requestId,
    };
