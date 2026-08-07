// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'available_rewards.dart';
import 'location_eligibility.dart';
import 'membership_resolve_result_locale.dart';
import 'membership_resolve_result_membership_status.dart';
import 'operation_limits.dart';
import 'purchase_requirement.dart';
import 'stamp_visuals.dart';

part 'membership_resolve_result.g.dart';

@JsonSerializable()
class MembershipResolveResult {
  const MembershipResolveResult({
    required this.membershipPublicId,
    required this.membershipStatus,
    required this.customerDisplayName,
    required this.programName,
    required this.locale,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
    required this.locationEligibility,
    required this.operationLimits,
    required this.operationalTimezone,
    required this.operationalDate,
    required this.purchaseRequirement,
    required this.stampVisuals,
    required this.availableRewards,
  });

  factory MembershipResolveResult.fromJson(Map<String, Object?> json) =>
      _$MembershipResolveResultFromJson(json);

  final String membershipPublicId;
  final MembershipResolveResultMembershipStatus membershipStatus;
  final String customerDisplayName;
  final String programName;
  final MembershipResolveResultLocale locale;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;
  final LocationEligibility locationEligibility;
  final OperationLimits operationLimits;
  final String operationalTimezone;
  final DateTime operationalDate;
  final PurchaseRequirement purchaseRequirement;
  final StampVisuals stampVisuals;
  final List<AvailableRewards> availableRewards;

  Map<String, Object?> toJson() => _$MembershipResolveResultToJson(this);
}
