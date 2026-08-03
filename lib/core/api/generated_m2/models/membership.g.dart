// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Membership _$MembershipFromJson(Map<String, dynamic> json) => Membership(
  publicId: json['publicId'] as String,
  status: Status.fromJson(json['status'] as String),
  customerDisplayName: json['customerDisplayName'] as String,
  programName: json['programName'] as String,
  progress: (json['progress'] as num).toInt(),
  goal: (json['goal'] as num).toInt(),
  rewardReady: json['rewardReady'] as bool,
  completedCycles: (json['completedCycles'] as num).toInt(),
  projectionVersion: (json['projectionVersion'] as num).toInt(),
);

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'status': _$StatusEnumMap[instance.status]!,
      'customerDisplayName': instance.customerDisplayName,
      'programName': instance.programName,
      'progress': instance.progress,
      'goal': instance.goal,
      'rewardReady': instance.rewardReady,
      'completedCycles': instance.completedCycles,
      'projectionVersion': instance.projectionVersion,
    };

const _$StatusEnumMap = {
  Status.active: 'ACTIVE',
  Status.suspended: 'SUSPENDED',
  Status.expired: 'EXPIRED',
  Status.revoked: 'REVOKED',
  Status.$unknown: r'$unknown',
};
