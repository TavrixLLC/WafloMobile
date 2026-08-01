// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_challenge_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingChallengeSuccess _$PairingChallengeSuccessFromJson(
  Map<String, dynamic> json,
) => PairingChallengeSuccess(
  data: PairingChallengeData.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$PairingChallengeSuccessToJson(
  PairingChallengeSuccess instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
