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

enum RewardKind { textReward, freeItem, discountDescription, custom }

final class LocationEligibility {
  const LocationEligibility({required this.earning, required this.redemption});

  final bool earning;
  final bool redemption;
}

final class StampArtwork {
  const StampArtwork({
    required this.filledAssetUrl,
    required this.emptyAssetUrl,
    required this.filledAssetDigest,
    required this.emptyAssetDigest,
    required this.accessibleLabel,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Uri filledAssetUrl;
  final Uri emptyAssetUrl;
  final String filledAssetDigest;
  final String emptyAssetDigest;
  final String accessibleLabel;
  final String backgroundColor;
  final String foregroundColor;

  static StampArtwork fromJson(
    Map<String, Object?> json, {
    required bool allowInsecureAssets,
  }) {
    final states = json['states'];
    if (states is! List<Object?> ||
        states.length != 2 ||
        states[0] != 'FILLED' ||
        states[1] != 'EMPTY') {
      throw const M2ContractViolation('STAMP_VISUAL_STATES_INVALID');
    }
    final filledUrl = _uri(json, 'filledAssetUrl');
    final emptyUrl = _uri(json, 'emptyAssetUrl');
    if (!allowInsecureAssets &&
        (filledUrl.scheme != 'https' || emptyUrl.scheme != 'https')) {
      throw const M2ContractViolation('STAMP_VISUAL_HTTPS_REQUIRED');
    }
    final filledDigest = _digest(json, 'filledAssetDigest');
    final emptyDigest = _digest(json, 'emptyAssetDigest');
    if (filledUrl.pathSegments.lastOrNull != filledDigest ||
        emptyUrl.pathSegments.lastOrNull != emptyDigest) {
      throw const M2ContractViolation('STAMP_VISUAL_DIGEST_URL_MISMATCH');
    }
    final background = _string(json, 'backgroundColor');
    final foreground = _string(json, 'foregroundColor');
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(background) ||
        !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(foreground)) {
      throw const M2ContractViolation('STAMP_VISUAL_COLOR_INVALID');
    }
    return StampArtwork(
      filledAssetUrl: filledUrl,
      emptyAssetUrl: emptyUrl,
      filledAssetDigest: filledDigest,
      emptyAssetDigest: emptyDigest,
      accessibleLabel: _boundedString(json, 'accessibleLabel', 1, 240),
      backgroundColor: background,
      foregroundColor: foreground,
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
    required this.merchantTransactionReferenceAllowed,
    required this.merchantTransactionReferenceRequired,
    required this.managerOverridePossibleForRole,
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
  final bool merchantTransactionReferenceAllowed;
  final bool merchantTransactionReferenceRequired;
  final bool managerOverridePossibleForRole;

  int get selectableMaximumStampAmount => dailyLimitEnabled
      ? math.min(effectiveMaximumStampAmount, dailyRemainingStampAmount!)
      : effectiveMaximumStampAmount;

  static MembershipOperationPolicy fromJson(
    Map<String, Object?> json, {
    required int expectedCapacity,
  }) {
    if (_integer(json, 'minimumStampAmount') != 1) {
      throw const M2ContractViolation('STAMP_MINIMUM_INVALID');
    }
    final maximum = _positiveInteger(json, 'maximumStampAmountPerOperation');
    final capacity = _nonNegativeInteger(json, 'remainingProgressCapacity');
    final effective = _nonNegativeInteger(json, 'effectiveMaximumStampAmount');
    if (capacity != expectedCapacity) {
      throw const M2ContractViolation('STAMP_CAPACITY_INCONSISTENT');
    }
    final dailyEnabled = _boolean(json, 'dailyLimitEnabled');
    final dailyMaximum = _nullableInteger(json, 'dailyMaximumStampAmount');
    final dailyRemaining = _nullableInteger(json, 'dailyRemainingStampAmount');
    if (dailyEnabled &&
        (dailyMaximum == null ||
            dailyMaximum <= 0 ||
            dailyRemaining == null ||
            dailyRemaining < 0 ||
            dailyRemaining > dailyMaximum)) {
      throw const M2ContractViolation('DAILY_STAMP_POLICY_INVALID');
    }
    if (!dailyEnabled && (dailyMaximum != null || dailyRemaining != null)) {
      throw const M2ContractViolation('DAILY_STAMP_POLICY_INCONSISTENT');
    }
    final expectedEffective = math.min(maximum, capacity);
    if (effective != expectedEffective) {
      throw const M2ContractViolation('STAMP_EFFECTIVE_MAX_INCONSISTENT');
    }

    final purchaseEnabled = _boolean(json, 'purchaseRequirementEnabled');
    final minimumPurchase = _nullableInteger(
      json,
      'minimumPurchaseAmountMinor',
    );
    final currencyValue = json['purchaseCurrency'];
    final currency = currencyValue == null
        ? null
        : currencyValue is String
        ? currencyValue
        : throw const M2ContractViolation('PURCHASE_CURRENCY_INVALID');
    if (purchaseEnabled &&
        (minimumPurchase == null ||
            minimumPurchase <= 0 ||
            currency == null ||
            !RegExp(r'^[A-Z]{3}$').hasMatch(currency))) {
      throw const M2ContractViolation('PURCHASE_POLICY_INVALID');
    }
    if (!purchaseEnabled && (minimumPurchase != null || currency != null)) {
      throw const M2ContractViolation('PURCHASE_POLICY_INCONSISTENT');
    }
    final referenceAllowed = _boolean(
      json,
      'merchantTransactionReferenceAllowed',
    );
    final referenceRequired = _boolean(
      json,
      'merchantTransactionReferenceRequired',
    );
    if (referenceRequired && !referenceAllowed) {
      throw const M2ContractViolation('TRANSACTION_REFERENCE_POLICY_INVALID');
    }
    final operationalDate = _dateTime(json, 'operationalLocalDate');
    if (operationalDate.hour != 0 ||
        operationalDate.minute != 0 ||
        operationalDate.second != 0) {
      throw const M2ContractViolation('OPERATIONAL_DATE_INVALID');
    }
    return MembershipOperationPolicy(
      maximumStampAmountPerOperation: maximum,
      remainingProgressCapacity: capacity,
      effectiveMaximumStampAmount: effective,
      dailyLimitEnabled: dailyEnabled,
      dailyMaximumStampAmount: dailyMaximum,
      dailyRemainingStampAmount: dailyRemaining,
      operationalLocalDate: operationalDate,
      operationalTimezone: _boundedString(json, 'operationalTimezone', 1, 80),
      purchaseRequirementEnabled: purchaseEnabled,
      minimumPurchaseAmountMinor: minimumPurchase,
      purchaseCurrency: currency,
      merchantTransactionReferenceAllowed: referenceAllowed,
      merchantTransactionReferenceRequired: referenceRequired,
      managerOverridePossibleForRole: _boolean(
        json,
        'managerOverridePossibleForRole',
      ),
    );
  }
}

final class AvailableReward {
  const AvailableReward({
    required this.entitlementPublicId,
    required this.kind,
    required this.finalReward,
    required this.threshold,
    required this.name,
    required this.description,
    required this.redemptionInstructions,
    required this.status,
    required this.redemptionCount,
    required this.maximumRedemptionCount,
    required this.expiresAt,
    required this.requiresManagerApproval,
  });

  final String entitlementPublicId;
  final RewardKind kind;
  final bool finalReward;
  final int threshold;
  final String name;
  final String description;
  final String? redemptionInstructions;
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
      entitlementPublicId: _uuid(json, 'entitlementPublicId'),
      kind: _rewardKind(_string(json, 'type')),
      finalReward: _boolean(json, 'finalReward'),
      threshold: _positiveInteger(json, 'threshold'),
      name: _boundedString(json, 'name', 1, 120),
      description: _boundedString(json, 'description', 1, 240),
      redemptionInstructions: _nullableBoundedString(
        json,
        'redemptionInstructions',
        1,
        240,
      ),
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
  final String requestId;

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
  }) {
    final membership = _map(json, 'membership');
    final publicId = _string(json, 'membershipPublicId');
    final customerName = _boundedString(json, 'customerDisplayName', 1, 160);
    final programName = _boundedString(json, 'programName', 1, 160);
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
    final status = _membershipStatus(_string(json, 'membershipStatus'));
    final completedCycles = _nonNegativeInteger(json, 'completedCycles');
    final projectionVersion = _nonNegativeInteger(
      membership,
      'projectionVersion',
    );
    if (_string(membership, 'publicId') != publicId ||
        _string(membership, 'customerDisplayName') != customerName ||
        _string(membership, 'programName') != programName ||
        _nonNegativeInteger(membership, 'progress') != progressValue ||
        _positiveInteger(membership, 'goal') != goal ||
        _boolean(membership, 'rewardReady') != rewardReady ||
        _nonNegativeInteger(membership, 'completedCycles') != completedCycles ||
        _membershipStatus(_string(membership, 'status')) != status) {
      throw const M2ContractViolation('MEMBERSHIP_PROJECTION_MISMATCH');
    }
    final eligibilityJson = _map(json, 'locationEligibility');
    final eligibility = LocationEligibility(
      earning: _boolean(eligibilityJson, 'earning'),
      redemption: _boolean(eligibilityJson, 'redemption'),
    );
    final policy = MembershipOperationPolicy.fromJson(
      _map(json, 'operationPolicy'),
      expectedCapacity: goal - progressValue,
    );
    final rewardsJson = json['availableRewards'];
    if (rewardsJson is! List<Object?>) {
      throw const M2ContractViolation('REWARD_LIST_INVALID');
    }
    final rewards = rewardsJson
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
      membershipPublicId: publicId,
      customerDisplayName: customerName,
      programName: programName,
      status: status,
      progress: progress,
      completedCycles: completedCycles,
      projectionVersion: projectionVersion,
      rewardReady: rewardReady,
      locationEligibility: eligibility,
      operationPolicy: policy,
      stampArtwork: StampArtwork.fromJson(
        _map(json, 'stampVisual'),
        allowInsecureAssets: allowInsecureAssets,
      ),
      availableRewards: rewards,
      resolvedAt: _dateTime(json, 'resolvedAt').toUtc(),
      requestId: _boundedString(json, 'requestId', 1, 160),
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

RewardKind _rewardKind(String value) => switch (value) {
  'TEXT_REWARD' => RewardKind.textReward,
  'FREE_ITEM' => RewardKind.freeItem,
  'DISCOUNT_DESCRIPTION' => RewardKind.discountDescription,
  'CUSTOM' => RewardKind.custom,
  _ => throw const M2ContractViolation('REWARD_TYPE_UNKNOWN'),
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

String? _nullableBoundedString(
  Map<String, Object?> json,
  String key,
  int minimum,
  int maximum,
) {
  if (json[key] == null) {
    return null;
  }
  return _boundedString(json, key, minimum, maximum);
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

int? _nullableInteger(Map<String, Object?> json, String key) {
  if (json[key] == null) {
    return null;
  }
  return _integer(json, key);
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

Uri _uri(Map<String, Object?> json, String key) {
  final value = _string(json, key);
  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw M2ContractViolation('${key.toUpperCase()}_INVALID');
  }
  return uri;
}

String _digest(Map<String, Object?> json, String key) {
  final value = _string(json, key).toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
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
