// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_resolve_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipResolveResult _$MembershipResolveResultFromJson(
  Map<String, dynamic> json,
) => MembershipResolveResult(
  membership: Membership.fromJson(json['membership'] as Map<String, dynamic>),
  membershipPublicId: json['membershipPublicId'] as String,
  customerDisplayName: json['customerDisplayName'] as String,
  programName: json['programName'] as String,
  progress: (json['progress'] as num).toInt(),
  goal: (json['goal'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  membershipStatus: MembershipResolveResultMembershipStatus.fromJson(
    json['membershipStatus'] as String,
  ),
  locationEligibility: LocationEligibility.fromJson(
    json['locationEligibility'] as Map<String, dynamic>,
  ),
  operationPolicy: OperationPolicy.fromJson(
    json['operationPolicy'] as Map<String, dynamic>,
  ),
  stampVisual: StampVisual.fromJson(
    json['stampVisual'] as Map<String, dynamic>,
  ),
  availableRewards: (json['availableRewards'] as List<dynamic>)
      .map((e) => AvailableRewards.fromJson(e as Map<String, dynamic>))
      .toList(),
  resolvedAt: DateTime.parse(json['resolvedAt'] as String),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$MembershipResolveResultToJson(
  MembershipResolveResult instance,
) => <String, dynamic>{
  'membership': instance.membership,
  'membershipPublicId': instance.membershipPublicId,
  'customerDisplayName': instance.customerDisplayName,
  'programName': instance.programName,
  'progress': instance.progress,
  'goal': instance.goal,
  'rewardReady': instance.rewardReady,
  'completedCycles': instance.completedCycles,
  'membershipStatus':
      _$MembershipResolveResultMembershipStatusEnumMap[instance
          .membershipStatus]!,
  'locationEligibility': instance.locationEligibility,
  'operationPolicy': instance.operationPolicy,
  'stampVisual': instance.stampVisual,
  'availableRewards': instance.availableRewards,
  'resolvedAt': instance.resolvedAt.toIso8601String(),
  'requestId': instance.requestId,
};

const _$MembershipResolveResultMembershipStatusEnumMap = {
  MembershipResolveResultMembershipStatus.active: 'ACTIVE',
  MembershipResolveResultMembershipStatus.suspended: 'SUSPENDED',
  MembershipResolveResultMembershipStatus.expired: 'EXPIRED',
  MembershipResolveResultMembershipStatus.revoked: 'REVOKED',
  MembershipResolveResultMembershipStatus.$unknown: r'$unknown',
};
