// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceSummary _$DeviceSummaryFromJson(Map<String, dynamic> json) =>
    DeviceSummary(
      publicId: json['publicId'] as String,
      displayName: json['displayName'] as String,
      platform: Platform.fromJson(json['platform'] as String),
      status: DeviceSummaryStatus.fromJson(json['status'] as String),
    );

Map<String, dynamic> _$DeviceSummaryToJson(DeviceSummary instance) =>
    <String, dynamic>{
      'publicId': instance.publicId,
      'displayName': instance.displayName,
      'platform': _$PlatformEnumMap[instance.platform]!,
      'status': _$DeviceSummaryStatusEnumMap[instance.status]!,
    };

const _$PlatformEnumMap = {
  Platform.ios: 'IOS',
  Platform.android: 'ANDROID',
  Platform.testClient: 'TEST_CLIENT',
  Platform.$unknown: r'$unknown',
};

const _$DeviceSummaryStatusEnumMap = {
  DeviceSummaryStatus.active: 'ACTIVE',
  DeviceSummaryStatus.$unknown: r'$unknown',
};
