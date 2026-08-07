// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_staff_device_context_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1StaffDeviceContextResponse _$GetV1StaffDeviceContextResponseFromJson(
  Map<String, dynamic> json,
) => GetV1StaffDeviceContextResponse(
  data: StaffDeviceContextResult.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$GetV1StaffDeviceContextResponseToJson(
  GetV1StaffDeviceContextResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
