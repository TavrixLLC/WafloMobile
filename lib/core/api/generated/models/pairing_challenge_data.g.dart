// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_challenge_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingChallengeData _$PairingChallengeDataFromJson(
  Map<String, dynamic> json,
) => PairingChallengeData(
  pairingPublicId: json['pairingPublicId'] as String,
  challenge: json['challenge'] as String,
  challengeExpiresAt: DateTime.parse(json['challengeExpiresAt'] as String),
  message: json['message'] as String,
);

Map<String, dynamic> _$PairingChallengeDataToJson(
  PairingChallengeData instance,
) => <String, dynamic>{
  'pairingPublicId': instance.pairingPublicId,
  'challenge': instance.challenge,
  'challengeExpiresAt': instance.challengeExpiresAt.toIso8601String(),
  'message': instance.message,
};
