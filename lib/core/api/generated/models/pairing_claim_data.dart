// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'iso_date_time.dart';
import 'uuid.dart';

part 'pairing_claim_data.g.dart';

@JsonSerializable()
class PairingClaimData {
  const PairingClaimData({
    required this.pairingPublicId,
    required this.challenge,
    required this.challengeExpiresAt,
    required this.signatureAlgorithm,
    required this.message,
  });

  factory PairingClaimData.fromJson(Map<String, Object?> json) =>
      _$PairingClaimDataFromJson(json);

  final Uuid pairingPublicId;
  final String challenge;
  final IsoDateTime challengeExpiresAt;
  final String signatureAlgorithm;
  final String message;

  Map<String, Object?> toJson() => _$PairingClaimDataToJson(this);
}
