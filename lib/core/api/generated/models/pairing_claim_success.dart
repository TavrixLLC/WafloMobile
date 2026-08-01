// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_claim_data.dart';

part 'pairing_claim_success.g.dart';

@JsonSerializable()
class PairingClaimSuccess {
  const PairingClaimSuccess({required this.data, required this.requestId});

  factory PairingClaimSuccess.fromJson(Map<String, Object?> json) =>
      _$PairingClaimSuccessFromJson(json);

  final PairingClaimData data;
  final String requestId;

  Map<String, Object?> toJson() => _$PairingClaimSuccessToJson(this);
}
