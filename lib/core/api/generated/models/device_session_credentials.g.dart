// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_session_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceSessionCredentials _$DeviceSessionCredentialsFromJson(
  Map<String, dynamic> json,
) => DeviceSessionCredentials(
  id: json['id'] as String,
  token: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$DeviceSessionCredentialsToJson(
  DeviceSessionCredentials instance,
) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'refreshToken': instance.refreshToken,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
