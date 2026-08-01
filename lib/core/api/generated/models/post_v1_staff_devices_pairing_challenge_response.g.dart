// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_devices_pairing_challenge_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffDevicesPairingChallengeResponse
_$PostV1StaffDevicesPairingChallengeResponseFromJson(
  Map<String, dynamic> json,
) => PostV1StaffDevicesPairingChallengeResponse(
  data: DevicePairingRecoveryResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$PostV1StaffDevicesPairingChallengeResponseToJson(
  PostV1StaffDevicesPairingChallengeResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
