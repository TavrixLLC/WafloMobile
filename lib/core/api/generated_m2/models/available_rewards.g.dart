// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableRewards _$AvailableRewardsFromJson(Map<String, dynamic> json) =>
    AvailableRewards(
      entitlementPublicId: json['entitlementPublicId'] as String,
      type: Type.fromJson(json['type'] as String),
      finalReward: json['finalReward'] as bool,
      threshold: (json['threshold'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      redemptionInstructions: json['redemptionInstructions'] as String?,
      status: Status2.fromJson(json['status'] as String),
      redemptionCount: (json['redemptionCount'] as num).toInt(),
      maximumRedemptionCount: (json['maximumRedemptionCount'] as num).toInt(),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      requiresManagerApproval: json['requiresManagerApproval'] as bool,
    );

Map<String, dynamic> _$AvailableRewardsToJson(AvailableRewards instance) =>
    <String, dynamic>{
      'entitlementPublicId': instance.entitlementPublicId,
      'type': _$TypeEnumMap[instance.type]!,
      'finalReward': instance.finalReward,
      'threshold': instance.threshold,
      'name': instance.name,
      'description': instance.description,
      'redemptionInstructions': instance.redemptionInstructions,
      'status': _$Status2EnumMap[instance.status]!,
      'redemptionCount': instance.redemptionCount,
      'maximumRedemptionCount': instance.maximumRedemptionCount,
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'requiresManagerApproval': instance.requiresManagerApproval,
    };

const _$TypeEnumMap = {
  Type.textReward: 'TEXT_REWARD',
  Type.freeItem: 'FREE_ITEM',
  Type.discountDescription: 'DISCOUNT_DESCRIPTION',
  Type.custom: 'CUSTOM',
  Type.$unknown: r'$unknown',
};

const _$Status2EnumMap = {
  Status2.available: 'AVAILABLE',
  Status2.partiallyRedeemed: 'PARTIALLY_REDEEMED',
  Status2.$unknown: r'$unknown',
};
