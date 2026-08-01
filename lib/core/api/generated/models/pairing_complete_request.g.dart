// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_complete_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingCompleteRequest _$PairingCompleteRequestFromJson(
  Map<String, dynamic> json,
) => PairingCompleteRequest(
  pairingPublicId: json['pairingPublicId'] as String,
  challenge: json['challenge'] as String,
  signature: json['signature'] as String,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$PairingCompleteRequestToJson(
  PairingCompleteRequest instance,
) => <String, dynamic>{
  'pairingPublicId': instance.pairingPublicId,
  'challenge': instance.challenge,
  'signature': instance.signature,
  'displayName': instance.displayName,
};
