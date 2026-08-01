// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  publicId: json['publicId'] as String,
  displayName: json['displayName'] as String,
  platform: Platform.fromJson(json['platform'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'publicId': instance.publicId,
  'displayName': instance.displayName,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'status': instance.status,
};

const _$PlatformEnumMap = {
  Platform.ios: 'IOS',
  Platform.android: 'ANDROID',
  Platform.testClient: 'TEST_CLIENT',
  Platform.$unknown: r'$unknown',
};
