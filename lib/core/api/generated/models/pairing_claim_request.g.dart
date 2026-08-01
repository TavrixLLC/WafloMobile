// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_claim_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PairingClaimRequest _$PairingClaimRequestFromJson(Map<String, dynamic> json) =>
    PairingClaimRequest(
      pairingToken: json['pairingToken'] as String,
      installationId: json['installationId'] as String,
      publicKey: json['publicKey'] as String,
      platform: Platform.fromJson(json['platform'] as String),
      appVersion: json['appVersion'] as String,
      osVersion: json['osVersion'] as String?,
      model: json['model'] as String?,
    );

Map<String, dynamic> _$PairingClaimRequestToJson(
  PairingClaimRequest instance,
) => <String, dynamic>{
  'pairingToken': instance.pairingToken,
  'installationId': instance.installationId,
  'publicKey': instance.publicKey,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'appVersion': instance.appVersion,
  'osVersion': instance.osVersion,
  'model': instance.model,
};

const _$PlatformEnumMap = {
  Platform.ios: 'IOS',
  Platform.android: 'ANDROID',
  Platform.testClient: 'TEST_CLIENT',
  Platform.$unknown: r'$unknown',
};
