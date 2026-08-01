// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_devices_session_refresh_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffDevicesSessionRefreshResponse
_$PostV1StaffDevicesSessionRefreshResponseFromJson(Map<String, dynamic> json) =>
    PostV1StaffDevicesSessionRefreshResponse(
      data: StaffDeviceSessionRefreshResponse.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PostV1StaffDevicesSessionRefreshResponseToJson(
  PostV1StaffDevicesSessionRefreshResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
