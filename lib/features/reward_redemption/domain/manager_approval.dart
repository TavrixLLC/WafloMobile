import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';

enum ManagerApprovalState {
  required,
  pending,
  checking,
  rejected,
  expired,
  consumed,
  mismatch,
  invalid,
  notApplicable,
  alreadyDecided,
  stale,
  approverInactive;

  bool get canCheck => this == required || this == pending;

  bool get requiresNewIntent => this == rejected || this == expired;

  bool get requiresAuthoritativeRefresh => switch (this) {
    consumed ||
    mismatch ||
    invalid ||
    notApplicable ||
    alreadyDecided ||
    stale ||
    approverInactive => true,
    _ => false,
  };

  static ManagerApprovalState? fromMachineCode(String code) => switch (code) {
    'MANAGER_APPROVAL_REQUIRED' => ManagerApprovalState.required,
    'MANAGER_APPROVAL_PENDING' => ManagerApprovalState.pending,
    'MANAGER_APPROVAL_REJECTED' => ManagerApprovalState.rejected,
    'MANAGER_APPROVAL_EXPIRED' => ManagerApprovalState.expired,
    'MANAGER_APPROVAL_CONSUMED' => ManagerApprovalState.consumed,
    'MANAGER_APPROVAL_MISMATCH' => ManagerApprovalState.mismatch,
    'MANAGER_APPROVAL_INVALID' => ManagerApprovalState.invalid,
    'MANAGER_APPROVAL_NOT_APPLICABLE' => ManagerApprovalState.notApplicable,
    'MANAGER_APPROVAL_ALREADY_DECIDED' => ManagerApprovalState.alreadyDecided,
    'MANAGER_APPROVAL_STALE' => ManagerApprovalState.stale,
    'MANAGER_APPROVAL_APPROVER_INACTIVE' =>
      ManagerApprovalState.approverInactive,
    _ => null,
  };
}

final class ManagerApprovalRequestData {
  const ManagerApprovalRequestData({
    required this.publicId,
    required this.status,
    required this.expiresAt,
  });

  final String publicId;
  final String status;
  final DateTime expiresAt;

  static ManagerApprovalRequestData fromFailure(ApiFailure failure) {
    final details = failure.details;
    final request = details?['approvalRequest'];
    if (details?['operationType'] != 'REDEEM' ||
        details?['retryWithSameIdempotencyKey'] != true ||
        request is! Map) {
      throw const FormatException('Approval response details are invalid.');
    }
    final normalized = request.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final publicId = normalized['publicId'];
    final status = normalized['status'];
    final expiresAt = DateTime.tryParse(
      normalized['expiresAt']?.toString() ?? '',
    );
    if (publicId is! String ||
        !_uuidPattern.hasMatch(publicId) ||
        status is! String ||
        !const {
          'PENDING',
          'APPROVED',
          'REJECTED',
          'EXPIRED',
          'CONSUMED',
        }.contains(status) ||
        expiresAt == null) {
      throw const FormatException('Approval response details are invalid.');
    }
    return ManagerApprovalRequestData(
      publicId: publicId,
      status: status,
      expiresAt: expiresAt.toUtc(),
    );
  }
}

final class ManagerApprovalIntent {
  const ManagerApprovalIntent({
    required this.commandId,
    required this.membershipPublicId,
    required this.qrPayload,
    required this.entitlementPublicId,
    required this.finalReward,
    required this.note,
    required this.approvalPublicId,
    required this.expiresAt,
    required this.createdAt,
  });

  static const recordVersion = 1;

  final String commandId;
  final String membershipPublicId;
  final String qrPayload;
  final String entitlementPublicId;
  final bool finalReward;
  final String? note;
  final String approvalPublicId;
  final DateTime expiresAt;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'recordVersion': recordVersion,
    'commandId': commandId,
    'membershipPublicId': membershipPublicId,
    'qrPayload': qrPayload,
    'entitlementPublicId': entitlementPublicId,
    'finalReward': finalReward,
    if (note != null) 'note': note,
    'approvalPublicId': approvalPublicId,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static ManagerApprovalIntent fromJson(Object? value) {
    if (value is! Map<String, Object?> ||
        value['recordVersion'] != recordVersion) {
      throw const FormatException('Unsupported approval intent.');
    }
    final commandId = value['commandId'];
    final membershipPublicId = value['membershipPublicId'];
    final qrPayload = value['qrPayload'];
    final entitlementPublicId = value['entitlementPublicId'];
    final finalReward = value['finalReward'];
    final note = value['note'];
    final approvalPublicId = value['approvalPublicId'];
    final expiresAt = DateTime.tryParse(value['expiresAt']?.toString() ?? '');
    final createdAt = DateTime.tryParse(value['createdAt']?.toString() ?? '');
    if (commandId is! String ||
        !isBusinessCommandId(commandId) ||
        membershipPublicId is! String ||
        membershipPublicId.isEmpty ||
        qrPayload is! String ||
        qrPayload.length < 40 ||
        qrPayload.length > 220 ||
        entitlementPublicId is! String ||
        !_uuidPattern.hasMatch(entitlementPublicId) ||
        finalReward is! bool ||
        (note != null && (note is! String || note.length > 240)) ||
        approvalPublicId is! String ||
        !_uuidPattern.hasMatch(approvalPublicId) ||
        expiresAt == null ||
        createdAt == null) {
      throw const FormatException('Approval intent is invalid.');
    }
    return ManagerApprovalIntent(
      commandId: commandId,
      membershipPublicId: membershipPublicId,
      qrPayload: qrPayload,
      entitlementPublicId: entitlementPublicId,
      finalReward: finalReward,
      note: note as String?,
      approvalPublicId: approvalPublicId,
      expiresAt: expiresAt.toUtc(),
      createdAt: createdAt.toUtc(),
    );
  }

  @override
  String toString() =>
      'ManagerApprovalIntent(command: [REDACTED], approval: [REDACTED], payload: [REDACTED])';
}

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);
