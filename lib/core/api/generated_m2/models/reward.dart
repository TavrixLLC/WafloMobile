// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'type.dart';
import 'status3.dart';

part 'reward.g.dart';

@JsonSerializable()
class Reward {
  const Reward({
    required this.entitlementPublicId,
    required this.type,
    required this.finalReward,
    required this.name,
    required this.description,
    required this.status,
  });

  factory Reward.fromJson(Map<String, Object?> json) => _$RewardFromJson(json);

  final String entitlementPublicId;
  final Type type;
  final bool finalReward;
  final String name;
  final String description;
  final Status3 status;

  Map<String, Object?> toJson() => _$RewardToJson(this);
}
