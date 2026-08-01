// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_claim_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePairingClaimResponse _$DevicePairingClaimResponseFromJson(
  Map<String, dynamic> json,
) => DevicePairingClaimResponse(
  pairingPublicId: json['pairingPublicId'] as String,
  challenge: json['challenge'] as String,
  challengeExpiresAt: DateTime.parse(json['challengeExpiresAt'] as String),
  signatureAlgorithm: json['signatureAlgorithm'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$DevicePairingClaimResponseToJson(
  DevicePairingClaimResponse instance,
) => <String, dynamic>{
  'pairingPublicId': instance.pairingPublicId,
  'challenge': instance.challenge,
  'challengeExpiresAt': instance.challengeExpiresAt.toIso8601String(),
  'signatureAlgorithm': instance.signatureAlgorithm,
  'message': instance.message,
};
