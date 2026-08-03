import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';

enum CommandOperationType { stamp, redemption }

enum CommandRecoveryStatus { processing, completed, failed }

final class CommandRecoveryResult {
  const CommandRecoveryResult({
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

  final String commandId;
  final String? operationPublicId;
  final CommandOperationType operationType;
  final CommandRecoveryStatus status;
  final String? safeFailureCode;
  final Map<String, Object?>? result;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String requestId;

  static CommandRecoveryResult fromJson(Map<String, Object?> json) {
    final status = switch (_string(json, 'status')) {
      'PROCESSING' => CommandRecoveryStatus.processing,
      'COMPLETED' => CommandRecoveryStatus.completed,
      'FAILED' => CommandRecoveryStatus.failed,
      _ => throw const M2ContractViolation('COMMAND_STATUS_UNKNOWN'),
    };
    final operationType = switch (_string(json, 'operationType')) {
      'STAMP' => CommandOperationType.stamp,
      'REDEMPTION' => CommandOperationType.redemption,
      _ => throw const M2ContractViolation('COMMAND_TYPE_UNKNOWN'),
    };
    final operationIdValue = json['operationPublicId'];
    final operationId = operationIdValue == null
        ? null
        : operationIdValue is String && _isUuid(operationIdValue)
        ? operationIdValue
        : throw const M2ContractViolation('OPERATION_PUBLIC_ID_INVALID');
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
        (failureCode == null || result != null)) {
      throw const M2ContractViolation('COMMAND_FAILED_INVALID');
    }
    if (status == CommandRecoveryStatus.completed &&
        (result == null || operationId == null || failureCode != null)) {
      throw const M2ContractViolation('COMMAND_COMPLETED_INVALID');
    }
    return CommandRecoveryResult(
      commandId: _uuid(json, 'commandId'),
      operationPublicId: operationId,
      operationType: operationType,
      status: status,
      safeFailureCode: failureCode,
      result: result,
      createdAt: _dateTime(json, 'createdAt'),
      completedAt: completedAt,
      requestId: _boundedString(json, 'requestId', 160),
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

String _boundedString(Map<String, Object?> json, String key, int maximum) {
  final value = _string(json, key);
  if (value.isEmpty || value.length > maximum) {
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
