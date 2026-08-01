// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'uuid.dart';

part 'pairing_challenge_request.g.dart';

@JsonSerializable()
class PairingChallengeRequest {
  const PairingChallengeRequest({required this.pairingPublicId});

  factory PairingChallengeRequest.fromJson(Map<String, Object?> json) =>
      _$PairingChallengeRequestFromJson(json);

  final Uuid pairingPublicId;

  Map<String, Object?> toJson() => _$PairingChallengeRequestToJson(this);
}
