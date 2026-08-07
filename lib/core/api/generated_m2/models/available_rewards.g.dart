// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableRewards _$AvailableRewardsFromJson(Map<String, dynamic> json) =>
    AvailableRewards(
      publicId: json['publicId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      threshold: (json['threshold'] as num).toInt(),
      finalReward: json['finalReward'] as bool,
      status: Status.fromJson(json['status'] as String),
      redemptionCount: (json['redemptionCount'] as num).toInt(),
      maximumRedemptionCount: (json['maximumRedemptionCount'] as num).toInt(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      requiresManagerApproval: json['requiresManagerApproval'] as bool,
    );

Map<String, dynamic> _$AvailableRewardsToJson(AvailableRewards instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'name': instance.name,
      'description': instance.description,
      'threshold': instance.threshold,
      'finalReward': instance.finalReward,
      'status': _$StatusEnumMap[instance.status]!,
      'redemptionCount': instance.redemptionCount,
      'maximumRedemptionCount': instance.maximumRedemptionCount,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'requiresManagerApproval': instance.requiresManagerApproval,
    };

const _$StatusEnumMap = {
  Status.available: 'AVAILABLE',
  Status.partiallyRedeemed: 'PARTIALLY_REDEEMED',
  Status.$unknown: r'$unknown',
};
