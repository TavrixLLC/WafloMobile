// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_devices_pairing_complete_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffDevicesPairingCompleteResponse
_$PostV1StaffDevicesPairingCompleteResponseFromJson(
  Map<String, dynamic> json,
) => PostV1StaffDevicesPairingCompleteResponse(
  data: DevicePairingCompleteResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$PostV1StaffDevicesPairingCompleteResponseToJson(
  PostV1StaffDevicesPairingCompleteResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
