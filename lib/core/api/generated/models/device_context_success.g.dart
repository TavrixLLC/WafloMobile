// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_context_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceContextSuccess _$DeviceContextSuccessFromJson(
  Map<String, dynamic> json,
) => DeviceContextSuccess(
  data: DeviceContext.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$DeviceContextSuccessToJson(
  DeviceContextSuccess instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
