// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_claim_success.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingClaimSuccess _$PairingClaimSuccessFromJson(Map<String, dynamic> json) =>
    PairingClaimSuccess(
      data: PairingClaimData.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PairingClaimSuccessToJson(
  PairingClaimSuccess instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
