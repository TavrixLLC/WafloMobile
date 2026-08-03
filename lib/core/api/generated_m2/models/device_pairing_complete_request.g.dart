// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_complete_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePairingCompleteRequest _$DevicePairingCompleteRequestFromJson(
  Map<String, dynamic> json,
) => DevicePairingCompleteRequest(
  pairingPublicId: json['pairingPublicId'] as String,
  challenge: json['challenge'] as String,
  signature: json['signature'] as String,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$DevicePairingCompleteRequestToJson(
  DevicePairingCompleteRequest instance,
) => <String, dynamic>{
  'pairingPublicId': instance.pairingPublicId,
  'challenge': instance.challenge,
  'signature': instance.signature,
  'displayName': instance.displayName,
};
