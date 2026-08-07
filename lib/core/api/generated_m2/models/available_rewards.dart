// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'status.dart';

part 'available_rewards.g.dart';

@JsonSerializable()
class AvailableRewards {
  const AvailableRewards({
    required this.publicId,
    required this.name,
    required this.description,
    required this.threshold,
    required this.finalReward,
    required this.status,
    required this.redemptionCount,
    required this.maximumRedemptionCount,
    required this.expiresAt,
    required this.requiresManagerApproval,
  });

  factory AvailableRewards.fromJson(Map<String, Object?> json) =>
      _$AvailableRewardsFromJson(json);

  final String publicId;
  final String name;
  final String description;
  final int threshold;
  final bool finalReward;
  final Status status;
  final int redemptionCount;
  final int maximumRedemptionCount;
  final DateTime? expiresAt;
  final bool requiresManagerApproval;

  Map<String, Object?> toJson() => _$AvailableRewardsToJson(this);
}
