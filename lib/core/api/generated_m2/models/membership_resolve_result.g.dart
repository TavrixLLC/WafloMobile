// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_resolve_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipResolveResult _$MembershipResolveResultFromJson(
  Map<String, dynamic> json,
) => MembershipResolveResult(
  membershipPublicId: json['membershipPublicId'] as String,
  membershipStatus: MembershipResolveResultMembershipStatus.fromJson(
    json['membershipStatus'] as String,
  ),
  customerDisplayName: json['customerDisplayName'] as String,
  programName: json['programName'] as String,
  locale: MembershipResolveResultLocale.fromJson(json['locale'] as String),
  progress: (json['progress'] as num).toInt(),
  goal: (json['goal'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  projectionVersion: (json['projectionVersion'] as num).toInt(),
  locationEligibility: LocationEligibility.fromJson(
    json['locationEligibility'] as Map<String, dynamic>,
  ),
  operationLimits: OperationLimits.fromJson(
    json['operationLimits'] as Map<String, dynamic>,
  ),
  operationalTimezone: json['operationalTimezone'] as String,
  operationalDate: DateTime.parse(json['operationalDate'] as String),
  purchaseRequirement: PurchaseRequirement.fromJson(
    json['purchaseRequirement'] as Map<String, dynamic>,
  ),
  stampVisuals: StampVisuals.fromJson(
    json['stampVisuals'] as Map<String, dynamic>,
  ),
  availableRewards: (json['availableRewards'] as List<dynamic>)
      .map((e) => AvailableRewards.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MembershipResolveResultToJson(
  MembershipResolveResult instance,
) => <String, dynamic>{
  'membershipPublicId': instance.membershipPublicId,
  'membershipStatus':
      _$MembershipResolveResultMembershipStatusEnumMap[instance
          .membershipStatus]!,
  'customerDisplayName': instance.customerDisplayName,
  'programName': instance.programName,
  'locale': _$MembershipResolveResultLocaleEnumMap[instance.locale]!,
  'progress': instance.progress,
  'goal': instance.goal,
  'rewardReady': instance.rewardReady,
  'completedCycles': instance.completedCycles,
  'projectionVersion': instance.projectionVersion,
  'locationEligibility': instance.locationEligibility,
  'operationLimits': instance.operationLimits,
  'operationalTimezone': instance.operationalTimezone,
  'operationalDate': instance.operationalDate.toIso8601String(),
  'purchaseRequirement': instance.purchaseRequirement,
  'stampVisuals': instance.stampVisuals,
  'availableRewards': instance.availableRewards,
};

const _$MembershipResolveResultMembershipStatusEnumMap = {
  MembershipResolveResultMembershipStatus.active: 'ACTIVE',
  MembershipResolveResultMembershipStatus.suspended: 'SUSPENDED',
  MembershipResolveResultMembershipStatus.expired: 'EXPIRED',
  MembershipResolveResultMembershipStatus.revoked: 'REVOKED',
  MembershipResolveResultMembershipStatus.$unknown: r'$unknown',
};

const _$MembershipResolveResultLocaleEnumMap = {
  MembershipResolveResultLocale.en: 'en',
  MembershipResolveResultLocale.ar: 'ar',
  MembershipResolveResultLocale.$unknown: r'$unknown',
};
