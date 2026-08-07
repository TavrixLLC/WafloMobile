// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redemption_operation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RedemptionOperationResult _$RedemptionOperationResultFromJson(
  Map<String, dynamic> json,
) => RedemptionOperationResult(
  operationPublicId: json['operationPublicId'] as String,
  commandId: json['commandId'] as String,
  replayed: json['replayed'] as bool,
  redemptionPublicId: json['redemptionPublicId'] as String,
  rewardStatus: RedemptionOperationResultRewardStatus.fromJson(
    json['rewardStatus'] as String,
  ),
  finalReward: json['finalReward'] as bool,
  beforeProgress: (json['beforeProgress'] as num).toInt(),
  progress: (json['progress'] as num).toInt(),
  goal: (json['goal'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  projectionVersion: (json['projectionVersion'] as num).toInt(),
  requestId: json['requestId'] as String?,
);

Map<String, dynamic> _$RedemptionOperationResultToJson(
  RedemptionOperationResult instance,
) => <String, dynamic>{
  'operationPublicId': instance.operationPublicId,
  'commandId': instance.commandId,
  'replayed': instance.replayed,
  'redemptionPublicId': instance.redemptionPublicId,
  'rewardStatus':
      _$RedemptionOperationResultRewardStatusEnumMap[instance.rewardStatus]!,
  'finalReward': instance.finalReward,
  'beforeProgress': instance.beforeProgress,
  'progress': instance.progress,
  'goal': instance.goal,
  'rewardReady': instance.rewardReady,
  'completedCycles': instance.completedCycles,
  'projectionVersion': instance.projectionVersion,
  'requestId': instance.requestId,
};

const _$RedemptionOperationResultRewardStatusEnumMap = {
  RedemptionOperationResultRewardStatus.redeemed: 'REDEEMED',
  RedemptionOperationResultRewardStatus.partiallyRedeemed: 'PARTIALLY_REDEEMED',
  RedemptionOperationResultRewardStatus.$unknown: r'$unknown',
};
