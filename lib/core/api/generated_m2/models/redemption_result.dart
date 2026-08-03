// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'reward.dart';

part 'redemption_result.g.dart';

@JsonSerializable()
class RedemptionResult {
  const RedemptionResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.redemptionPublicId,
    required this.reward,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.requestId,
  });

  factory RedemptionResult.fromJson(Map<String, Object?> json) =>
      _$RedemptionResultFromJson(json);

  final String operationPublicId;
  final String commandId;
  final bool replayed;
  final String redemptionPublicId;
  final Reward reward;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final String requestId;

  Map<String, Object?> toJson() => _$RedemptionResultToJson(this);
}
