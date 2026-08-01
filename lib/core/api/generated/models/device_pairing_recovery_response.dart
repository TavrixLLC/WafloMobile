// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_pairing_recovery_response.g.dart';

@JsonSerializable()
class DevicePairingRecoveryResponse {
  const DevicePairingRecoveryResponse({
    required this.pairingPublicId,
    required this.challenge,
    required this.challengeExpiresAt,
    required this.signatureAlgorithm,
    required this.message,
  });

  factory DevicePairingRecoveryResponse.fromJson(Map<String, Object?> json) =>
      _$DevicePairingRecoveryResponseFromJson(json);

  final String pairingPublicId;
  final String challenge;
  final DateTime challengeExpiresAt;
  final String signatureAlgorithm;
  final String message;

  Map<String, Object?> toJson() => _$DevicePairingRecoveryResponseToJson(this);
}
