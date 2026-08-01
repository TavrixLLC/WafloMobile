// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceContext _$DeviceContextFromJson(Map<String, dynamic> json) =>
    DeviceContext(
      organizationId: json['organizationId'] as String,
      organizationMemberId: json['organizationMemberId'] as String,
      role: Role.fromJson(json['role'] as String),
      locationId: json['locationId'] as String,
      deviceId: json['deviceId'] as String,
      devicePublicId: json['devicePublicId'] as String,
      deviceSessionId: json['deviceSessionId'] as String,
      platform: Platform.fromJson(json['platform'] as String),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$DeviceContextToJson(DeviceContext instance) =>
    <String, dynamic>{
      'organizationId': instance.organizationId,
      'organizationMemberId': instance.organizationMemberId,
      'role': _$RoleEnumMap[instance.role]!,
      'locationId': instance.locationId,
      'deviceId': instance.deviceId,
      'devicePublicId': instance.devicePublicId,
      'deviceSessionId': instance.deviceSessionId,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'requestId': instance.requestId,
    };

const _$RoleEnumMap = {
  Role.owner: 'OWNER',
  Role.manager: 'MANAGER',
  Role.staff: 'STAFF',
  Role.$unknown: r'$unknown',
};

const _$PlatformEnumMap = {
  Platform.ios: 'IOS',
  Platform.android: 'ANDROID',
  Platform.testClient: 'TEST_CLIENT',
  Platform.$unknown: r'$unknown',
};
