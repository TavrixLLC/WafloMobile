// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_recovery_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePairingRecoveryResponse _$DevicePairingRecoveryResponseFromJson(
  Map<String, dynamic> json,
) => DevicePairingRecoveryResponse(
  pairingPublicId: json['pairingPublicId'] as String,
  challenge: json['challenge'] as String,
  challengeExpiresAt: DateTime.parse(json['challengeExpiresAt'] as String),
  signatureAlgorithm: json['signatureAlgorithm'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$DevicePairingRecoveryResponseToJson(
  DevicePairingRecoveryResponse instance,
) => <String, dynamic>{
  'pairingPublicId': instance.pairingPublicId,
  'challenge': instance.challenge,
  'challengeExpiresAt': instance.challengeExpiresAt.toIso8601String(),
  'signatureAlgorithm': instance.signatureAlgorithm,
  'message': instance.message,
};
