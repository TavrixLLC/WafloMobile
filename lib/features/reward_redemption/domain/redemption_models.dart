import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';

final class RewardReceipt {
  const RewardReceipt({
    required this.entitlementPublicId,
    required this.kind,
    required this.finalReward,
    required this.name,
    required this.description,
    required this.status,
  });

  final String entitlementPublicId;
  final RewardKind kind;
  final bool finalReward;
  final String name;
  final String description;
  final String status;

  static RewardReceipt fromJson(Map<String, Object?> json) => RewardReceipt(
    entitlementPublicId: _uuid(json, 'entitlementPublicId'),
    kind: _rewardKind(_string(json, 'type')),
    finalReward: _boolean(json, 'finalReward'),
    name: _boundedString(json, 'name', 120),
    description: _boundedString(json, 'description', 240),
    status: switch (_string(json, 'status')) {
      'AVAILABLE' ||
      'PARTIALLY_REDEEMED' ||
      'REDEEMED' => _string(json, 'status'),
      _ => throw const M2ContractViolation('REWARD_STATUS_UNKNOWN'),
    },
  );
}

final class RedemptionOperationInput {
  const RedemptionOperationInput({
    required this.entitlementPublicId,
    required this.finalReward,
  });

  final String entitlementPublicId;
  final bool finalReward;
}

final class RedemptionOperationResult {
  const RedemptionOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.redemptionPublicId,
    required this.reward,
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
  final RewardReceipt reward;
  final StampProgress progress;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final String requestId;

  static RedemptionOperationResult fromJson(Map<String, Object?> json) {
    final rewardJson = json['reward'];
    if (rewardJson is! Map<String, Object?>) {
      throw const M2ContractViolation('REDEMPTION_REWARD_INVALID');
    }
    final reward = RewardReceipt.fromJson(rewardJson);
    final progress = StampProgress.validated(
      progress: _nonNegativeInteger(json, 'progress'),
      goal: _positiveInteger(json, 'goal'),
    );
    final rewardReady = _boolean(json, 'rewardReady');
    if (reward.finalReward &&
        (progress.progress != 0 ||
            rewardReady ||
            reward.status != 'REDEEMED')) {
      throw const M2ContractViolation('FINAL_REDEMPTION_RESET_INVALID');
    }
    if (!reward.finalReward &&
        rewardReady != (progress.progress == progress.goal)) {
      throw const M2ContractViolation('MILESTONE_REDEMPTION_INVALID');
    }
    return RedemptionOperationResult(
      operationPublicId: _uuid(json, 'operationPublicId'),
      commandId: _uuid(json, 'commandId'),
      replayed: _boolean(json, 'replayed'),
      redemptionPublicId: _uuid(json, 'redemptionPublicId'),
      reward: reward,
      progress: progress,
      rewardReady: rewardReady,
      completedCycles: _nonNegativeInteger(json, 'completedCycles'),
      projectionVersion: _nonNegativeInteger(json, 'projectionVersion'),
      requestId: _boundedString(json, 'requestId', 160),
    );
  }
}

RewardKind _rewardKind(String value) => switch (value) {
  'TEXT_REWARD' => RewardKind.textReward,
  'FREE_ITEM' => RewardKind.freeItem,
  'DISCOUNT_DESCRIPTION' => RewardKind.discountDescription,
  'CUSTOM' => RewardKind.custom,
  _ => throw const M2ContractViolation('REWARD_TYPE_UNKNOWN'),
};

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
