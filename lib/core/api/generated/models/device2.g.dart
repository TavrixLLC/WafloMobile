// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device2 _$Device2FromJson(Map<String, dynamic> json) => Device2(
  publicId: json['publicId'] as String,
  displayName: json['displayName'] as String,
  status: Status.fromJson(json['status'] as String),
  platform: Platform.fromJson(json['platform'] as String),
  appVersion: json['appVersion'] as String,
);

Map<String, dynamic> _$Device2ToJson(Device2 instance) => <String, dynamic>{
  'publicId': instance.publicId,
  'displayName': instance.displayName,
  'status': _$StatusEnumMap[instance.status]!,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'appVersion': instance.appVersion,
};

const _$StatusEnumMap = {
  Status.pending: 'PENDING',
  Status.active: 'ACTIVE',
  Status.revoked: 'REVOKED',
  Status.compromised: 'COMPROMISED',
  Status.$unknown: r'$unknown',
};

const _$PlatformEnumMap = {
  Platform.ios: 'IOS',
  Platform.android: 'ANDROID',
  Platform.testClient: 'TEST_CLIENT',
  Platform.$unknown: r'$unknown',
};
