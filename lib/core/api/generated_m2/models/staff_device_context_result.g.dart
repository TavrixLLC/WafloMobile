// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_device_context_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffDeviceContextResult _$StaffDeviceContextResultFromJson(
  Map<String, dynamic> json,
) => StaffDeviceContextResult(
  organizationId: json['organizationId'] as String,
  role: StaffDeviceContextResultRole.fromJson(json['role'] as String),
  locationId: json['locationId'] as String,
  devicePublicId: json['devicePublicId'] as String,
  deviceSessionId: json['deviceSessionId'] as String,
  platform: StaffDeviceContextResultPlatform.fromJson(
    json['platform'] as String,
  ),
  appVersion: json['appVersion'] as String,
  minimumSupportedAppVersion: json['minimumSupportedAppVersion'] as String,
  appVersionSupported: json['appVersionSupported'] as bool,
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$StaffDeviceContextResultToJson(
  StaffDeviceContextResult instance,
) => <String, dynamic>{
  'organizationId': instance.organizationId,
  'role': _$StaffDeviceContextResultRoleEnumMap[instance.role]!,
  'locationId': instance.locationId,
  'devicePublicId': instance.devicePublicId,
  'deviceSessionId': instance.deviceSessionId,
  'platform': _$StaffDeviceContextResultPlatformEnumMap[instance.platform]!,
  'appVersion': instance.appVersion,
  'minimumSupportedAppVersion': instance.minimumSupportedAppVersion,
  'appVersionSupported': instance.appVersionSupported,
  'requestId': instance.requestId,
};

const _$StaffDeviceContextResultRoleEnumMap = {
  StaffDeviceContextResultRole.owner: 'OWNER',
  StaffDeviceContextResultRole.manager: 'MANAGER',
  StaffDeviceContextResultRole.staff: 'STAFF',
  StaffDeviceContextResultRole.$unknown: r'$unknown',
};

const _$StaffDeviceContextResultPlatformEnumMap = {
  StaffDeviceContextResultPlatform.ios: 'IOS',
  StaffDeviceContextResultPlatform.android: 'ANDROID',
  StaffDeviceContextResultPlatform.testClient: 'TEST_CLIENT',
  StaffDeviceContextResultPlatform.$unknown: r'$unknown',
};
