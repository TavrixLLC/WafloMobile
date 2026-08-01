// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_devices_pairing_claim_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffDevicesPairingClaimResponse
_$PostV1StaffDevicesPairingClaimResponseFromJson(Map<String, dynamic> json) =>
    PostV1StaffDevicesPairingClaimResponse(
      data: DevicePairingClaimResponse.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PostV1StaffDevicesPairingClaimResponseToJson(
  PostV1StaffDevicesPairingClaimResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
