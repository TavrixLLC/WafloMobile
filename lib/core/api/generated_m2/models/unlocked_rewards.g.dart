// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlocked_rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockedRewards _$UnlockedRewardsFromJson(Map<String, dynamic> json) =>
    UnlockedRewards(
      publicId: json['publicId'] as String,
      threshold: (json['threshold'] as num).toInt(),
      status: json['status'] as String,
      finalValue: json['final'] as bool,
    );

Map<String, dynamic> _$UnlockedRewardsToJson(UnlockedRewards instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'threshold': instance.threshold,
      'status': instance.status,
      'final': instance.finalValue,
    };
