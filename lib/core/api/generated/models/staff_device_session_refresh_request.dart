// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'staff_device_session_refresh_request.g.dart';

@JsonSerializable()
class StaffDeviceSessionRefreshRequest {
  const StaffDeviceSessionRefreshRequest({required this.refreshToken});

  factory StaffDeviceSessionRefreshRequest.fromJson(
    Map<String, Object?> json,
  ) => _$StaffDeviceSessionRefreshRequestFromJson(json);

  final String refreshToken;

  Map<String, Object?> toJson() =>
      _$StaffDeviceSessionRefreshRequestToJson(this);
}
