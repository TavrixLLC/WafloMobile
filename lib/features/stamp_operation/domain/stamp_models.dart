import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';

final class StampOperationInput {
  const StampOperationInput({
    required this.amount,
    this.purchaseAmountMinor,
    this.purchaseCurrency,
    this.merchantTransactionReference,
  });

  final int amount;
  final int? purchaseAmountMinor;
  final String? purchaseCurrency;
  final String? merchantTransactionReference;
}

final class UnlockedReward {
  const UnlockedReward({
    required this.publicId,
    required this.threshold,
    required this.status,
    required this.finalReward,
  });

  final String publicId;
  final int threshold;
  final String status;
  final bool finalReward;

  static UnlockedReward fromJson(Map<String, Object?> json) {
    final status = _boundedString(json, 'status', 40);
    return UnlockedReward(
      publicId: _uuid(json, 'publicId'),
      threshold: _positiveInteger(json, 'threshold'),
      status: status,
      finalReward: _boolean(json, 'final'),
    );
  }
}

final class StampOperationResult {
  const StampOperationResult({
    required this.operationPublicId,
    required this.commandId,
    required this.replayed,
    required this.beforeProgress,
    required this.progress,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.unlockedRewards,
    required this.requestId,
  });

  final String operationPublicId;
  final String commandId;
  final bool replayed;
  final int beforeProgress;
  final StampProgress progress;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final List<UnlockedReward> unlockedRewards;
  final String? requestId;

  static StampOperationResult fromJson(
    Map<String, Object?> json, {
    String? responseRequestId,
  }) {
    final before = _nonNegativeInteger(json, 'beforeProgress');
    final progress = StampProgress.validated(
      progress: _nonNegativeInteger(json, 'progress'),
      goal: _positiveInteger(json, 'goal'),
    );
    if (before > progress.progress) {
      throw const M2ContractViolation('STAMP_RESULT_REGRESSION');
    }
    final rewardReady = _boolean(json, 'rewardReady');
    if (rewardReady != (progress.progress == progress.goal)) {
      throw const M2ContractViolation('STAMP_REWARD_READY_INCONSISTENT');
    }
    final rewardsValue = json['unlockedRewards'];
    if (rewardsValue is! List<Object?>) {
      throw const M2ContractViolation('STAMP_REWARDS_INVALID');
    }
    final rewards = rewardsValue
        .map((value) {
          if (value is! Map<String, Object?>) {
            throw const M2ContractViolation('STAMP_REWARD_INVALID');
          }
          return UnlockedReward.fromJson(value);
        })
        .toList(growable: false);
    final embeddedRequestId = _nullableBoundedString(json, 'requestId', 160);
    return StampOperationResult(
      operationPublicId: _uuid(json, 'operationPublicId'),
      commandId: _uuid(json, 'commandId'),
      replayed: _boolean(json, 'replayed'),
      beforeProgress: before,
      progress: progress,
      rewardReady: rewardReady,
      completedCycles: _nonNegativeInteger(json, 'completedCycles'),
      projectionVersion: _nonNegativeInteger(json, 'projectionVersion'),
      unlockedRewards: rewards,
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
