import 'dart:math' as math;

import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';

final class M2ContractViolation implements FormatException {
  const M2ContractViolation(this.code);

  final String code;

  @override
  int? get offset => null;

  @override
  String get message => code;

  @override
  Object? get source => null;

  @override
  String toString() => 'M2ContractViolation($code)';
}

enum MembershipStatus { active, suspended, expired, revoked }

enum RewardAvailability { available, partiallyRedeemed }

final class LocationEligibility {
  const LocationEligibility({required this.earning, required this.redemption});

  final bool earning;
  final bool redemption;
}

final class StampArtwork {
  const StampArtwork({
    required this.filledAssetDigest,
    required this.emptyAssetDigest,
  });

  final String? filledAssetDigest;
  final String? emptyAssetDigest;

  static StampArtwork fromJson(Map<String, Object?> json) {
    final filled = _map(json, 'filled');
    final empty = _map(json, 'empty');
    if (_string(filled, 'state') != 'FILLED' ||
        _string(empty, 'state') != 'EMPTY') {
      throw const M2ContractViolation('STAMP_VISUAL_STATES_INVALID');
    }
    return StampArtwork(
      filledAssetDigest: _nullableDigest(filled, 'contentDigest'),
      emptyAssetDigest: _nullableDigest(empty, 'contentDigest'),
    );
  }
}

final class MembershipOperationPolicy {
  const MembershipOperationPolicy({
    required this.maximumStampAmountPerOperation,
    required this.remainingProgressCapacity,
    required this.effectiveMaximumStampAmount,
    required this.dailyLimitEnabled,
    required this.dailyMaximumStampAmount,
    required this.dailyRemainingStampAmount,
    required this.operationalLocalDate,
    required this.operationalTimezone,
    required this.purchaseRequirementEnabled,
    required this.minimumPurchaseAmountMinor,
    required this.purchaseCurrency,
  });

  final int maximumStampAmountPerOperation;
  final int remainingProgressCapacity;
  final int effectiveMaximumStampAmount;
  final bool dailyLimitEnabled;
  final int? dailyMaximumStampAmount;
  final int? dailyRemainingStampAmount;
  final DateTime operationalLocalDate;
  final String operationalTimezone;
  final bool purchaseRequirementEnabled;
  final int? minimumPurchaseAmountMinor;
  final String? purchaseCurrency;

  // The request contract permits an optional reference but does not declare a
  // policy that can make it mandatory. Server validation remains authoritative.
  bool get merchantTransactionReferenceAllowed => true;
  bool get merchantTransactionReferenceRequired => false;
  bool get managerOverridePossibleForRole => false;

  int get selectableMaximumStampAmount => dailyLimitEnabled
      ? math.min(effectiveMaximumStampAmount, dailyRemainingStampAmount!)
      : effectiveMaximumStampAmount;

  static MembershipOperationPolicy fromJson(
    Map<String, Object?> json, {
    required int expectedCapacity,
  }) {
    final limits = _map(json, 'operationLimits');
    final maximum = _positiveInteger(limits, 'maximumStampsPerOperation');
    final dailyMaximum = _nullablePositiveInteger(
      limits,
      'maximumStampsPerCustomerPerDay',
    );
    final dailyRemaining = _nullableNonNegativeInteger(
      limits,
      'dailyRemainingStamps',
    );
    if ((dailyMaximum == null) != (dailyRemaining == null) ||
        (dailyMaximum != null && dailyRemaining! > dailyMaximum)) {
      throw const M2ContractViolation('DAILY_STAMP_POLICY_INVALID');
    }

    final purchase = _map(json, 'purchaseRequirement');
    final purchaseRequired = _boolean(purchase, 'required');
    final minimumPurchase = _nullableNonNegativeInteger(
      purchase,
      'minimumAmountMinor',
    );
    final currencyValue = purchase['currency'];
    final currency = currencyValue == null
        ? null
        : currencyValue is String &&
              RegExp(r'^[A-Z]{3}$').hasMatch(currencyValue)
        ? currencyValue
        : throw const M2ContractViolation('PURCHASE_CURRENCY_INVALID');
    if (purchaseRequired && (minimumPurchase == null || currency == null)) {
      throw const M2ContractViolation('PURCHASE_POLICY_INVALID');
    }
    if (!purchaseRequired && (minimumPurchase != null || currency != null)) {
      throw const M2ContractViolation('PURCHASE_POLICY_INCONSISTENT');
    }

    final operationalDate = _dateTime(json, 'operationalDate');
    if (operationalDate.hour != 0 ||
        operationalDate.minute != 0 ||
        operationalDate.second != 0 ||
        operationalDate.millisecond != 0) {
      throw const M2ContractViolation('OPERATIONAL_DATE_INVALID');
    }
    return MembershipOperationPolicy(
      maximumStampAmountPerOperation: maximum,
      remainingProgressCapacity: expectedCapacity,
      effectiveMaximumStampAmount: math.min(maximum, expectedCapacity),
      dailyLimitEnabled: dailyMaximum != null,
      dailyMaximumStampAmount: dailyMaximum,
      dailyRemainingStampAmount: dailyRemaining,
      operationalLocalDate: operationalDate,
      operationalTimezone: _boundedString(json, 'operationalTimezone', 1, 100),
      purchaseRequirementEnabled: purchaseRequired,
      minimumPurchaseAmountMinor: minimumPurchase,
      purchaseCurrency: currency,
    );
  }
}

final class AvailableReward {
  const AvailableReward({
    required this.entitlementPublicId,
    required this.finalReward,
    required this.threshold,
    required this.name,
    required this.description,
    required this.status,
    required this.redemptionCount,
    required this.maximumRedemptionCount,
    required this.expiresAt,
    required this.requiresManagerApproval,
  });

  final String entitlementPublicId;
  final bool finalReward;
  final int threshold;
  final String name;
  final String description;
  final RewardAvailability status;
  final int redemptionCount;
  final int maximumRedemptionCount;
  final DateTime? expiresAt;
  final bool requiresManagerApproval;

  bool isRedeemableAt(DateTime now) =>
      !requiresManagerApproval &&
      redemptionCount < maximumRedemptionCount &&
      (expiresAt == null || expiresAt!.isAfter(now.toUtc()));

  static AvailableReward fromJson(Map<String, Object?> json) {
    final count = _nonNegativeInteger(json, 'redemptionCount');
    final maximum = _positiveInteger(json, 'maximumRedemptionCount');
    if (count >= maximum) {
      throw const M2ContractViolation('REWARD_COUNT_INVALID');
    }
    return AvailableReward(
      entitlementPublicId: _uuid(json, 'publicId'),
      finalReward: _boolean(json, 'finalReward'),
      threshold: _positiveInteger(json, 'threshold'),
      name: _boundedString(json, 'name', 1, 120),
      description: _boundedString(json, 'description', 0, 240),
      status: switch (_string(json, 'status')) {
        'AVAILABLE' => RewardAvailability.available,
        'PARTIALLY_REDEEMED' => RewardAvailability.partiallyRedeemed,
        _ => throw const M2ContractViolation('REWARD_STATUS_UNKNOWN'),
      },
      redemptionCount: count,
      maximumRedemptionCount: maximum,
      expiresAt: _nullableDateTime(json, 'expiresAt'),
      requiresManagerApproval: _boolean(json, 'requiresManagerApproval'),
    );
  }
}

final class ResolvedMembership {
  const ResolvedMembership({
    required this.membershipPublicId,
    required this.customerDisplayName,
    required this.programName,
    required this.locale,
    required this.status,
    required this.progress,
    required this.completedCycles,
    required this.projectionVersion,
    required this.rewardReady,
    required this.locationEligibility,
    required this.operationPolicy,
    required this.stampArtwork,
    required this.availableRewards,
    required this.resolvedAt,
    required this.requestId,
  });

  final String membershipPublicId;
  final String customerDisplayName;
  final String programName;
  final String locale;
  final MembershipStatus status;
  final StampProgress progress;
  final int completedCycles;
  final int projectionVersion;
  final bool rewardReady;
  final LocationEligibility locationEligibility;
  final MembershipOperationPolicy operationPolicy;
  final StampArtwork stampArtwork;
  final List<AvailableReward> availableRewards;
  final DateTime resolvedAt;
  final String? requestId;

  bool get operational => status == MembershipStatus.active;
  bool get earningAllowed =>
      operational &&
      locationEligibility.earning &&
      !rewardReady &&
      operationPolicy.selectableMaximumStampAmount > 0;
  bool get redemptionAllowed => operational && locationEligibility.redemption;

  bool isFreshAt(
    DateTime now, {
    Duration maximumAge = const Duration(minutes: 2),
  }) => now.toUtc().difference(resolvedAt.toUtc()).abs() <= maximumAge;

  static ResolvedMembership fromJson(
    Map<String, Object?> json, {
    required bool allowInsecureAssets,
    String? responseRequestId,
    DateTime? receivedAt,
  }) {
    // Kept in the signature for flavor-compatible callers. The repaired
    // contract exposes no asset URL, so insecure remote artwork is impossible.
    assert(allowInsecureAssets || !allowInsecureAssets);
    final progressValue = _nonNegativeInteger(json, 'progress');
    final goal = _positiveInteger(json, 'goal');
    final progress = StampProgress.validated(
      progress: progressValue,
      goal: goal,
    );
    final rewardReady = _boolean(json, 'rewardReady');
    if (rewardReady != (progressValue == goal)) {
      throw const M2ContractViolation('REWARD_READY_INCONSISTENT');
    }
    final locale = _string(json, 'locale');
    if (locale != 'en' && locale != 'ar') {
      throw const M2ContractViolation('LOCALE_INVALID');
    }
    final eligibilityJson = _map(json, 'locationEligibility');
    final rewardsValue = json['availableRewards'];
    if (rewardsValue is! List<Object?>) {
      throw const M2ContractViolation('REWARD_LIST_INVALID');
    }
    final rewards = rewardsValue
        .map((value) {
          if (value is! Map<String, Object?>) {
            throw const M2ContractViolation('REWARD_INVALID');
          }
          return AvailableReward.fromJson(value);
        })
        .toList(growable: false);
    for (final reward in rewards) {
      if (reward.threshold > goal ||
          (reward.finalReward && reward.threshold != goal)) {
        throw const M2ContractViolation('REWARD_THRESHOLD_INVALID');
      }
    }
    if (rewardReady && !rewards.any((reward) => reward.finalReward)) {
      throw const M2ContractViolation('FINAL_REWARD_MISSING');
    }
    return ResolvedMembership(
      membershipPublicId: _boundedString(json, 'membershipPublicId', 8, 80),
      customerDisplayName: _boundedString(json, 'customerDisplayName', 1, 160),
      programName: _boundedString(json, 'programName', 1, 120),
      locale: locale,
      status: _membershipStatus(_string(json, 'membershipStatus')),
      progress: progress,
      completedCycles: _nonNegativeInteger(json, 'completedCycles'),
      projectionVersion: _nonNegativeInteger(json, 'projectionVersion'),
      rewardReady: rewardReady,
      locationEligibility: LocationEligibility(
        earning: _boolean(eligibilityJson, 'earning'),
        redemption: _boolean(eligibilityJson, 'redemption'),
      ),
      operationPolicy: MembershipOperationPolicy.fromJson(
        json,
        expectedCapacity: goal - progressValue,
      ),
      stampArtwork: StampArtwork.fromJson(_map(json, 'stampVisuals')),
      availableRewards: rewards,
      resolvedAt: (receivedAt ?? DateTime.now()).toUtc(),
      requestId: responseRequestId,
    );
  }

  @override
  String toString() =>
      'ResolvedMembership(status: ${status.name}, progress: ${progress.progress}/${progress.goal}, identifiers: [REDACTED])';
}

MembershipStatus _membershipStatus(String value) => switch (value) {
  'ACTIVE' => MembershipStatus.active,
  'SUSPENDED' => MembershipStatus.suspended,
  'EXPIRED' => MembershipStatus.expired,
  'REVOKED' => MembershipStatus.revoked,
  _ => throw const M2ContractViolation('MEMBERSHIP_STATUS_UNKNOWN'),
};

Map<String, Object?> _map(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is Map<String, Object?>) {
    return value;
  }
  throw M2ContractViolation('${key.toUpperCase()}_INVALID');
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) {
    return value;
  }
  throw M2ContractViolation('${key.toUpperCase()}_INVALID');
}

String _boundedString(
  Map<String, Object?> json,
  String key,
  int minimum,
  int maximum,
) {
  final value = _string(json, key);
  if (value.length < minimum || value.length > maximum) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return value;
}

bool _boolean(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  throw M2ContractViolation('${key.toUpperCase()}_INVALID');
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  throw M2ContractViolation('${key.toUpperCase()}_INVALID');
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

int? _nullablePositiveInteger(Map<String, Object?> json, String key) {
  if (json[key] == null) {
    return null;
  }
  return _positiveInteger(json, key);
}

int? _nullableNonNegativeInteger(Map<String, Object?> json, String key) {
  if (json[key] == null) {
    return null;
  }
  return _nonNegativeInteger(json, key);
}

DateTime _dateTime(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return parsed;
}

DateTime? _nullableDateTime(Map<String, Object?> json, String key) {
  if (json[key] == null) {
    return null;
  }
  return _dateTime(json, key).toUtc();
}

String? _nullableDigest(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
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
