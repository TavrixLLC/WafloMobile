// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'staff_device_session_refresh_response.dart';

part 'post_v1_staff_devices_session_refresh_response.g.dart';

@JsonSerializable()
class PostV1StaffDevicesSessionRefreshResponse {
  const PostV1StaffDevicesSessionRefreshResponse({
    required this.data,
    required this.requestId,
  });

  factory PostV1StaffDevicesSessionRefreshResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostV1StaffDevicesSessionRefreshResponseFromJson(json);

  final StaffDeviceSessionRefreshResponse data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$PostV1StaffDevicesSessionRefreshResponseToJson(this);
}
