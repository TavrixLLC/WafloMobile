// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type.dart';
import 'status2.dart';

part 'unlocked_rewards.g.dart';

@JsonSerializable()
class UnlockedRewards {
  const UnlockedRewards({
    required this.entitlementPublicId,
    required this.type,
    required this.finalReward,
    required this.threshold,
    required this.name,
    required this.description,
    required this.status,
    required this.expiresAt,
    required this.requiresManagerApproval,
  });

  factory UnlockedRewards.fromJson(Map<String, Object?> json) =>
      _$UnlockedRewardsFromJson(json);

  final String entitlementPublicId;
  final Type type;
  final bool finalReward;
  final int threshold;
  final String name;
  final String description;
  final Status2 status;
  final DateTime? expiresAt;
  final bool requiresManagerApproval;

  Map<String, Object?> toJson() => _$UnlockedRewardsToJson(this);
}
