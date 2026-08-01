// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'session2.dart';

part 'staff_device_session_refresh_response.g.dart';

@JsonSerializable()
class StaffDeviceSessionRefreshResponse {
  const StaffDeviceSessionRefreshResponse({required this.session});

  factory StaffDeviceSessionRefreshResponse.fromJson(
    Map<String, Object?> json,
  ) => _$StaffDeviceSessionRefreshResponseFromJson(json);

  final Session2 session;

  Map<String, Object?> toJson() =>
      _$StaffDeviceSessionRefreshResponseToJson(this);
}
