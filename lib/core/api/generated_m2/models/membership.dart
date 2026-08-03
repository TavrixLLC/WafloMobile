// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'status.dart';

part 'membership.g.dart';

@JsonSerializable()
class Membership {
  const Membership({
    required this.publicId,
    required this.status,
    required this.customerDisplayName,
    required this.programName,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.completedCycles,
    required this.projectionVersion,
  });

  factory Membership.fromJson(Map<String, Object?> json) =>
      _$MembershipFromJson(json);

  final String publicId;
  final Status status;
  final String customerDisplayName;
  final String programName;
  final int progress;
  final int goal;
  final bool rewardReady;
  final int completedCycles;
  final int projectionVersion;

  Map<String, Object?> toJson() => _$MembershipToJson(this);
}
