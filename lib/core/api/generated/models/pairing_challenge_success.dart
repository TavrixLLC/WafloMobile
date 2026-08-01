// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_challenge_data.dart';

part 'pairing_challenge_success.g.dart';

@JsonSerializable()
class PairingChallengeSuccess {
  const PairingChallengeSuccess({required this.data, required this.requestId});

  factory PairingChallengeSuccess.fromJson(Map<String, Object?> json) =>
      _$PairingChallengeSuccessFromJson(json);

  final PairingChallengeData data;
  final String requestId;

  Map<String, Object?> toJson() => _$PairingChallengeSuccessToJson(this);
}
