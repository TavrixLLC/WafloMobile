// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'iso_date_time.dart';
import 'uuid.dart';

part 'device_session_credentials.g.dart';

@JsonSerializable()
class DeviceSessionCredentials {
  const DeviceSessionCredentials({
    required this.id,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory DeviceSessionCredentials.fromJson(Map<String, Object?> json) =>
      _$DeviceSessionCredentialsFromJson(json);

  final Uuid id;
  final String token;
  final String refreshToken;
  final IsoDateTime expiresAt;

  Map<String, Object?> toJson() => _$DeviceSessionCredentialsToJson(this);
}
