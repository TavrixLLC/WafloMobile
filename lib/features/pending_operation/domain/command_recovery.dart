import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

enum CommandOperationType { stamp, redemption }

enum CommandRecoveryStatus { processing, completed, failed }

final class CommandRecoveryResult {
  const CommandRecoveryResult({
    required this.commandId,
    required this.operationPublicId,
    required this.operationType,
    required this.status,
    required this.safeFailureCode,
    required this.stampResult,
    required this.redemptionResult,
    required this.createdAt,
    required this.completedAt,
    required this.requestId,
  });

  final String commandId;
  final String operationPublicId;
  final CommandOperationType operationType;
  final CommandRecoveryStatus status;
  final String? safeFailureCode;
  final StampOperationResult? stampResult;
  final RedemptionOperationResult? redemptionResult;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? requestId;

  static CommandRecoveryResult fromJson(
    Map<String, Object?> json, {
    String? responseRequestId,
  }) {
    final commandId = _uuid(json, 'commandId');
    final operationPublicId = _uuid(json, 'operationPublicId');
    final status = switch (_string(json, 'status')) {
      'PROCESSING' => CommandRecoveryStatus.processing,
      'COMPLETED' => CommandRecoveryStatus.completed,
      'FAILED' => CommandRecoveryStatus.failed,
      _ => throw const M2ContractViolation('COMMAND_STATUS_UNKNOWN'),
    };
    final operationType = switch (_string(json, 'operationType')) {
      'ISSUE_STAMP' => CommandOperationType.stamp,
      'REDEEM_REWARD' => CommandOperationType.redemption,
      _ => throw const M2ContractViolation('COMMAND_TYPE_UNSUPPORTED'),
    };
    final failureValue = json['safeFailureCode'];
    final failureCode = failureValue == null
        ? null
        : failureValue is String && failureValue.isNotEmpty
        ? failureValue
        : throw const M2ContractViolation('SAFE_FAILURE_CODE_INVALID');
    final resultValue = json['result'];
    final result = resultValue == null
        ? null
        : resultValue is Map<String, Object?>
        ? resultValue
        : throw const M2ContractViolation('COMMAND_RESULT_INVALID');
    final completedValue = json['completedAt'];
    final completedAt = completedValue == null
        ? null
        : completedValue is String
        ? DateTime.tryParse(completedValue)?.toUtc()
        : null;
    if (completedValue != null && completedAt == null) {
      throw const M2ContractViolation('COMMAND_COMPLETED_AT_INVALID');
    }
    if (status == CommandRecoveryStatus.processing &&
        (failureCode != null || result != null || completedAt != null)) {
      throw const M2ContractViolation('COMMAND_PROCESSING_INVALID');
    }
    if (status == CommandRecoveryStatus.failed &&
        (failureCode == null || result != null || completedAt == null)) {
      throw const M2ContractViolation('COMMAND_FAILED_INVALID');
    }
    if (status == CommandRecoveryStatus.completed &&
        (result == null || failureCode != null || completedAt == null)) {
      throw const M2ContractViolation('COMMAND_COMPLETED_INVALID');
    }

    StampOperationResult? stampResult;
    RedemptionOperationResult? redemptionResult;
    if (status == CommandRecoveryStatus.completed) {
      switch (operationType) {
        case CommandOperationType.stamp:
          stampResult = StampOperationResult.fromJson(
            result!,
            responseRequestId: responseRequestId,
          );
          if (stampResult.commandId != commandId ||
              stampResult.operationPublicId != operationPublicId) {
            throw const M2ContractViolation('COMMAND_RESULT_ID_MISMATCH');
          }
        case CommandOperationType.redemption:
          redemptionResult = RedemptionOperationResult.fromJson(
            result!,
            responseRequestId: responseRequestId,
          );
          if (redemptionResult.commandId != commandId ||
              redemptionResult.operationPublicId != operationPublicId) {
            throw const M2ContractViolation('COMMAND_RESULT_ID_MISMATCH');
          }
      }
    }
    return CommandRecoveryResult(
      commandId: commandId,
      operationPublicId: operationPublicId,
      operationType: operationType,
      status: status,
      safeFailureCode: failureCode,
      stampResult: stampResult,
      redemptionResult: redemptionResult,
      createdAt: _dateTime(json, 'createdAt'),
      completedAt: completedAt,
      requestId: responseRequestId,
    );
  }
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

bool _isUuid(String value) => RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
).hasMatch(value);

String _uuid(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (!_isUuid(value)) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

DateTime _dateTime(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return parsed.toUtc();
}
