// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'm1_generic_result.dart';

part 'post_v1_staff_devices_session_logout_response.g.dart';

@JsonSerializable()
class PostV1StaffDevicesSessionLogoutResponse {
  const PostV1StaffDevicesSessionLogoutResponse({
    required this.data,
    required this.requestId,
  });

  factory PostV1StaffDevicesSessionLogoutResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostV1StaffDevicesSessionLogoutResponseFromJson(json);

  final M1GenericResult data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$PostV1StaffDevicesSessionLogoutResponseToJson(this);
}
