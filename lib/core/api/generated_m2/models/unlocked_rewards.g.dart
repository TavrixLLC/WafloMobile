// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlocked_rewards.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockedRewards _$UnlockedRewardsFromJson(Map<String, dynamic> json) =>
    UnlockedRewards(
      entitlementPublicId: json['entitlementPublicId'] as String,
      type: Type.fromJson(json['type'] as String),
      finalReward: json['finalReward'] as bool,
      threshold: (json['threshold'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      status: Status2.fromJson(json['status'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      requiresManagerApproval: json['requiresManagerApproval'] as bool,
    );

Map<String, dynamic> _$UnlockedRewardsToJson(UnlockedRewards instance) =>
    <String, dynamic>{
      'entitlementPublicId': instance.entitlementPublicId,
      'type': _$TypeEnumMap[instance.type]!,
      'finalReward': instance.finalReward,
      'threshold': instance.threshold,
      'name': instance.name,
      'description': instance.description,
      'status': _$Status2EnumMap[instance.status]!,
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
