// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_pairing_challenge_request.g.dart';

@JsonSerializable()
class DevicePairingChallengeRequest {
  const DevicePairingChallengeRequest({required this.pairingPublicId});

  factory DevicePairingChallengeRequest.fromJson(Map<String, Object?> json) =>
      _$DevicePairingChallengeRequestFromJson(json);

  final String pairingPublicId;

  Map<String, Object?> toJson() => _$DevicePairingChallengeRequestToJson(this);
}
