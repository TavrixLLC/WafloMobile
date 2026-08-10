import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';

final class RedemptionOperationInput {
  const RedemptionOperationInput({
    required this.entitlementPublicId,
    required this.finalReward,
  });

  final String entitlementPublicId;
  final bool finalReward;
}

enum RedemptionRewardStatus { redeemed, partiallyRedeemed }

final class RedemptionOperationResult {
  const RedemptionOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.redemptionPublicId,
    required this.rewardStatus,
    required this.finalReward,
    required this.beforeProgress,
    required this.progress,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.requestId,
  });

  final String operationPublicId;
  final String commandId;
  final bool replayed;
  final String redemptionPublicId;
  final RedemptionRewardStatus rewardStatus;
  final bool finalReward;
  final int beforeProgress;
  final StampProgress progress;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final String? requestId;

  static RedemptionOperationResult fromJson(
    Map<String, Object?> json, {
    String? responseRequestId,
  }) {
    final beforeProgress = _nonNegativeInteger(json, 'beforeProgress');
    final progress = StampProgress.validated(
      progress: _nonNegativeInteger(json, 'progress'),
      goal: _positiveInteger(json, 'goal'),
    );
    final rewardStatus = switch (_string(json, 'rewardStatus')) {
      'REDEEMED' => RedemptionRewardStatus.redeemed,
      'PARTIALLY_REDEEMED' => RedemptionRewardStatus.partiallyRedeemed,
      _ => throw const M2ContractViolation('REWARD_STATUS_UNKNOWN'),
    };
    final finalReward = _boolean(json, 'finalReward');
    final rewardReady = _boolean(json, 'rewardReady');
    if (finalReward &&
        (beforeProgress != progress.goal ||
            progress.progress != 0 ||
            rewardReady ||
            rewardStatus != RedemptionRewardStatus.redeemed)) {
      throw const M2ContractViolation('FINAL_REDEMPTION_RESET_INVALID');
    }
    if (!finalReward &&
        (progress.progress != beforeProgress ||
            rewardReady != (progress.progress == progress.goal))) {
      throw const M2ContractViolation('MILESTONE_REDEMPTION_INVALID');
    }
    final embeddedRequestId = _nullableBoundedString(json, 'requestId', 160);
    return RedemptionOperationResult(
      operationPublicId: _uuid(json, 'operationPublicId'),
      commandId: _uuid(json, 'commandId'),
      replayed: _boolean(json, 'replayed'),
      redemptionPublicId: _uuid(json, 'redemptionPublicId'),
      rewardStatus: rewardStatus,
      finalReward: finalReward,
      beforeProgress: beforeProgress,
      progress: progress,
      rewardReady: rewardReady,
      completedCycles: _nonNegativeInteger(json, 'completedCycles'),
      projectionVersion: _nonNegativeInteger(json, 'projectionVersion'),
      requestId: responseRequestId ?? embeddedRequestId,
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

String? _nullableBoundedString(
  Map<String, Object?> json,
  String key,
  int maximum,
) {
  if (json[key] == null) {
    return null;
  }
  return _boundedString(json, key, maximum);
}

bool _boolean(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! bool) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

int _positiveInteger(Map<String, Object?> json, String key) {
  final value = _integer(json, key);
  if (value <= 0) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

int _nonNegativeInteger(Map<String, Object?> json, String key) {
  final value = _integer(json, key);
  if (value < 0) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

String _uuid(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  if (!RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value)) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}
