// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'command_status_operation_type.dart';
import 'command_status_status.dart';

part 'command_status.g.dart';

@JsonSerializable()
class CommandStatus {
  const CommandStatus({
    required this.commandId,
    required this.operationPublicId,
    required this.operationType,
    required this.status,
    required this.safeFailureCode,
    required this.result,
    required this.createdAt,
    required this.completedAt,
    required this.requestId,
  });

  factory CommandStatus.fromJson(Map<String, Object?> json) =>
      _$CommandStatusFromJson(json);

  final String commandId;
  final String? operationPublicId;
  final CommandStatusOperationType operationType;
  final CommandStatusStatus status;
  final String? safeFailureCode;
  final dynamic result;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String requestId;

  Map<String, Object?> toJson() => _$CommandStatusToJson(this);
}
