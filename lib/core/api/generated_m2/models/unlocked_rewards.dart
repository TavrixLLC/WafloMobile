// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'unlocked_rewards.g.dart';

@JsonSerializable()
class UnlockedRewards {
  const UnlockedRewards({
    required this.publicId,
    required this.threshold,
    required this.status,
    required this.finalValue,
  });

  factory UnlockedRewards.fromJson(Map<String, Object?> json) =>
      _$UnlockedRewardsFromJson(json);

  final String publicId;
  final int threshold;
  final String status;

  /// The name has been replaced because it contains a keyword. Original name: `final`.
  @JsonKey(name: 'final')
  final bool finalValue;

  Map<String, Object?> toJson() => _$UnlockedRewardsToJson(this);
}
