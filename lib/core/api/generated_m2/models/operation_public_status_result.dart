// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'operation_public_status_result_operation_type.dart';
import 'operation_public_status_result_status.dart';

part 'operation_public_status_result.g.dart';

@JsonSerializable()
class OperationPublicStatusResult {
  const OperationPublicStatusResult({
    required this.publicId,
    required this.operationPublicId,
    required this.commandId,
    required this.operationType,
    required this.status,
    required this.resultProjectionVersion,
    required this.resultPayload,
    required this.safeFailureCode,
    required this.createdAt,
    required this.completedAt,
  });

  factory OperationPublicStatusResult.fromJson(Map<String, Object?> json) =>
      _$OperationPublicStatusResultFromJson(json);

  final String publicId;
  final String operationPublicId;
  final String commandId;
  final OperationPublicStatusResultOperationType operationType;
  final OperationPublicStatusResultStatus status;
  final int? resultProjectionVersion;
  final dynamic resultPayload;
  final String? safeFailureCode;
  final DateTime createdAt;
  final DateTime? completedAt;

  Map<String, Object?> toJson() => _$OperationPublicStatusResultToJson(this);
}
