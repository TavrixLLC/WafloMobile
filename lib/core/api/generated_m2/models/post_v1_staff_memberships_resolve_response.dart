// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'membership_resolve_result.dart';

part 'post_v1_staff_memberships_resolve_response.g.dart';

@JsonSerializable()
class PostV1StaffMembershipsResolveResponse {
  const PostV1StaffMembershipsResolveResponse({
    required this.data,
    required this.requestId,
  });

  factory PostV1StaffMembershipsResolveResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostV1StaffMembershipsResolveResponseFromJson(json);

  final MembershipResolveResult data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$PostV1StaffMembershipsResolveResponseToJson(this);
}
