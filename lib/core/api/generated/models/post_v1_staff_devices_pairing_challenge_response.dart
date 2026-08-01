// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_pairing_recovery_response.dart';

part 'post_v1_staff_devices_pairing_challenge_response.g.dart';

@JsonSerializable()
class PostV1StaffDevicesPairingChallengeResponse {
  const PostV1StaffDevicesPairingChallengeResponse({
    required this.data,
    required this.requestId,
  });

  factory PostV1StaffDevicesPairingChallengeResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostV1StaffDevicesPairingChallengeResponseFromJson(json);

  final DevicePairingRecoveryResponse data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$PostV1StaffDevicesPairingChallengeResponseToJson(this);
}
