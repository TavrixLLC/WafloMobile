// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reverse_operation_result.g.dart';

@JsonSerializable()
class ReverseOperationResult {
  const ReverseOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.reversedOperationPublicId,
    required this.replayed,
    required this.progress,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.requestId,
  });

  factory ReverseOperationResult.fromJson(Map<String, Object?> json) =>
      _$ReverseOperationResultFromJson(json);

  final String operationPublicId;
  final String commandId;
  final String reversedOperationPublicId;
  final bool replayed;
  final int progress;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final String? requestId;

  Map<String, Object?> toJson() => _$ReverseOperationResultToJson(this);
}
