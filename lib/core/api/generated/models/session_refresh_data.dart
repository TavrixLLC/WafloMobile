// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_session_credentials.dart';

part 'session_refresh_data.g.dart';

@JsonSerializable()
class SessionRefreshData {
  const SessionRefreshData({required this.session});

  factory SessionRefreshData.fromJson(Map<String, Object?> json) =>
      _$SessionRefreshDataFromJson(json);

  final DeviceSessionCredentials session;

  Map<String, Object?> toJson() => _$SessionRefreshDataToJson(this);
}
