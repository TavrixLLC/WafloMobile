// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_memberships_resolve_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffMembershipsResolveResponse
_$PostV1StaffMembershipsResolveResponseFromJson(Map<String, dynamic> json) =>
    PostV1StaffMembershipsResolveResponse(
      data: MembershipResolveResult.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PostV1StaffMembershipsResolveResponseToJson(
  PostV1StaffMembershipsResolveResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
