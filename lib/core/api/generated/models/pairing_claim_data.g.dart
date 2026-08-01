// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_claim_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingClaimData _$PairingClaimDataFromJson(Map<String, dynamic> json) =>
    PairingClaimData(
      pairingPublicId: json['pairingPublicId'] as String,
      challenge: json['challenge'] as String,
      challengeExpiresAt: DateTime.parse(json['challengeExpiresAt'] as String),
      signatureAlgorithm: json['signatureAlgorithm'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$PairingClaimDataToJson(PairingClaimData instance) =>
    <String, dynamic>{
      'pairingPublicId': instance.pairingPublicId,
      'challenge': instance.challenge,
      'challengeExpiresAt': instance.challengeExpiresAt.toIso8601String(),
      'signatureAlgorithm': instance.signatureAlgorithm,
      'message': instance.message,
    };
