// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'operation_command_status_result_operation_type.dart';
import 'operation_command_status_result_status.dart';

part 'operation_command_status_result.g.dart';

@JsonSerializable()
class OperationCommandStatusResult {
  const OperationCommandStatusResult({
    required this.commandId,
    required this.operationPublicId,
    required this.operationType,
    required this.status,
    required this.result,
    required this.safeFailureCode,
    required this.createdAt,
    required this.completedAt,
  });

  factory OperationCommandStatusResult.fromJson(Map<String, Object?> json) =>
      _$OperationCommandStatusResultFromJson(json);

  final String commandId;
  final String operationPublicId;
  final OperationCommandStatusResultOperationType operationType;
  final OperationCommandStatusResultStatus status;
  final dynamic result;
  final String? safeFailureCode;
  final DateTime createdAt;
  final DateTime? completedAt;

  Map<String, Object?> toJson() => _$OperationCommandStatusResultToJson(this);
}
