// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'unlocked_rewards.dart';

part 'stamp_operation_result.g.dart';

@JsonSerializable()
class StampOperationResult {
  const StampOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.beforeProgress,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.unlockedRewards,
    required this.requestId,
  });

  factory StampOperationResult.fromJson(Map<String, Object?> json) =>
      _$StampOperationResultFromJson(json);

  final String operationPublicId;
  final String commandId;
  final bool replayed;
  final int beforeProgress;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final List<UnlockedRewards> unlockedRewards;
  final String? requestId;

  Map<String, Object?> toJson() => _$StampOperationResultToJson(this);
}
