// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_qr_token.dart';
import 'platform.dart';

part 'pairing_claim_request.g.dart';

@JsonSerializable()
class PairingClaimRequest {
  const PairingClaimRequest({
    required this.pairingToken,
    required this.installationId,
    required this.publicKey,
    required this.platform,
    required this.appVersion,
    this.osVersion,
    this.model,
  });

  factory PairingClaimRequest.fromJson(Map<String, Object?> json) =>
      _$PairingClaimRequestFromJson(json);

  final PairingQrToken pairingToken;
  final String installationId;
  final String publicKey;
  final Platform platform;
  final String appVersion;
  final String? osVersion;
  final String? model;

  Map<String, Object?> toJson() => _$PairingClaimRequestToJson(this);
}
