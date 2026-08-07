// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'redemption_operation_result_reward_status.dart';

part 'redemption_operation_result.g.dart';

@JsonSerializable()
class RedemptionOperationResult {
  const RedemptionOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.redemptionPublicId,
    required this.rewardStatus,
    required this.finalReward,
    required this.beforeProgress,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.requestId,
  });

  factory RedemptionOperationResult.fromJson(Map<String, Object?> json) =>
      _$RedemptionOperationResultFromJson(json);

  final String operationPublicId;
  final String commandId;
  final bool replayed;
  final String redemptionPublicId;
  final RedemptionOperationResultRewardStatus rewardStatus;
  final bool finalReward;
  final int beforeProgress;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final String? requestId;

  Map<String, Object?> toJson() => _$RedemptionOperationResultToJson(this);
}
