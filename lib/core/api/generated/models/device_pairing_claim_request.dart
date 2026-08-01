// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_pairing_claim_request_platform.dart';

part 'device_pairing_claim_request.g.dart';

@JsonSerializable()
class DevicePairingClaimRequest {
  const DevicePairingClaimRequest({
    required this.pairingToken,
    required this.installationId,
    required this.publicKey,
    required this.platform,
    required this.appVersion,
    this.osVersion,
    this.model,
  });

  factory DevicePairingClaimRequest.fromJson(Map<String, Object?> json) =>
      _$DevicePairingClaimRequestFromJson(json);

  final String pairingToken;
  final String installationId;
  final String publicKey;
  final DevicePairingClaimRequestPlatform platform;
  final String appVersion;
  final String? osVersion;
  final String? model;

  Map<String, Object?> toJson() => _$DevicePairingClaimRequestToJson(this);
}
