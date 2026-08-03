// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reward _$RewardFromJson(Map<String, dynamic> json) => Reward(
  entitlementPublicId: json['entitlementPublicId'] as String,
  type: Type.fromJson(json['type'] as String),
  finalReward: json['finalReward'] as bool,
  name: json['name'] as String,
  description: json['description'] as String,
  status: Status3.fromJson(json['status'] as String),
);

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
  'entitlementPublicId': instance.entitlementPublicId,
  'type': _$TypeEnumMap[instance.type]!,
  'finalReward': instance.finalReward,
  'name': instance.name,
  'description': instance.description,
  'status': _$Status3EnumMap[instance.status]!,
};

const _$TypeEnumMap = {
  Type.textReward: 'TEXT_REWARD',
  Type.freeItem: 'FREE_ITEM',
  Type.discountDescription: 'DISCOUNT_DESCRIPTION',
  Type.custom: 'CUSTOM',
  Type.$unknown: r'$unknown',
};

const _$Status3EnumMap = {
  Status3.available: 'AVAILABLE',
  Status3.partiallyRedeemed: 'PARTIALLY_REDEEMED',
  Status3.redeemed: 'REDEEMED',
  Status3.$unknown: r'$unknown',
};
