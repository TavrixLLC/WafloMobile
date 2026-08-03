// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type.dart';
import 'status2.dart';

part 'available_rewards.g.dart';

@JsonSerializable()
class AvailableRewards {
  const AvailableRewards({
    required this.entitlementPublicId,
    required this.type,
    required this.finalReward,
    required this.threshold,
    required this.name,
    required this.description,
    required this.redemptionInstructions,
    required this.status,
    required this.redemptionCount,
    required this.maximumRedemptionCount,
    required this.expiresAt,
    required this.requiresManagerApproval,
  });

  factory AvailableRewards.fromJson(Map<String, Object?> json) =>
      _$AvailableRewardsFromJson(json);

  final String entitlementPublicId;
  final Type type;
  final bool finalReward;
  final int threshold;
  final String name;
  final String description;
  final String? redemptionInstructions;
  final Status2 status;
  final int redemptionCount;
  final int maximumRedemptionCount;
  final DateTime? expiresAt;
  final bool requiresManagerApproval;

  Map<String, Object?> toJson() => _$AvailableRewardsToJson(this);
}
