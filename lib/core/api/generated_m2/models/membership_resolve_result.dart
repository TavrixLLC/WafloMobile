// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'available_rewards.dart';
import 'location_eligibility.dart';
import 'membership.dart';
import 'membership_resolve_result_membership_status.dart';
import 'operation_policy.dart';
import 'stamp_visual.dart';

part 'membership_resolve_result.g.dart';

@JsonSerializable()
class MembershipResolveResult {
  const MembershipResolveResult({
    required this.membership,
    required this.membershipPublicId,
    required this.customerDisplayName,
    required this.programName,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.membershipStatus,
    required this.locationEligibility,
    required this.operationPolicy,
    required this.stampVisual,
    required this.availableRewards,
    required this.resolvedAt,
    required this.requestId,
  });

  factory MembershipResolveResult.fromJson(Map<String, Object?> json) =>
      _$MembershipResolveResultFromJson(json);

  final Membership membership;
  final String membershipPublicId;
  final String customerDisplayName;
  final String programName;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final MembershipResolveResultMembershipStatus membershipStatus;
  final LocationEligibility locationEligibility;
  final OperationPolicy operationPolicy;
  final StampVisual stampVisual;
  final List<AvailableRewards> availableRewards;
  final DateTime resolvedAt;
  final String requestId;

  Map<String, Object?> toJson() => _$MembershipResolveResultToJson(this);
}
