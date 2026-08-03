// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_pairing_claim_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DevicePairingClaimRequest _$DevicePairingClaimRequestFromJson(
  Map<String, dynamic> json,
) => DevicePairingClaimRequest(
  pairingToken: json['pairingToken'] as String,
  installationId: json['installationId'] as String,
  publicKey: json['publicKey'] as String,
  platform: DevicePairingClaimRequestPlatform.fromJson(
    json['platform'] as String,
  ),
  appVersion: json['appVersion'] as String,
  osVersion: json['osVersion'] as String?,
  model: json['model'] as String?,
);

Map<String, dynamic> _$DevicePairingClaimRequestToJson(
  DevicePairingClaimRequest instance,
) => <String, dynamic>{
  'pairingToken': instance.pairingToken,
  'installationId': instance.installationId,
  'publicKey': instance.publicKey,
  'platform': _$DevicePairingClaimRequestPlatformEnumMap[instance.platform]!,
  'appVersion': instance.appVersion,
  'osVersion': instance.osVersion,
  'model': instance.model,
};

const _$DevicePairingClaimRequestPlatformEnumMap = {
  DevicePairingClaimRequestPlatform.ios: 'IOS',
  DevicePairingClaimRequestPlatform.android: 'ANDROID',
  DevicePairingClaimRequestPlatform.testClient: 'TEST_CLIENT',
  DevicePairingClaimRequestPlatform.$unknown: r'$unknown',
};
