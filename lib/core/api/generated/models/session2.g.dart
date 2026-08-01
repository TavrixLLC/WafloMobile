// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session2 _$Session2FromJson(Map<String, dynamic> json) => Session2(
  id: json['id'] as String,
  token: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$Session2ToJson(Session2 instance) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'refreshToken': instance.refreshToken,
  'expiresAt': instance.expiresAt.toIso8601String(),
};
