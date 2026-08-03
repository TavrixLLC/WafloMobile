// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_pairing_complete_request.g.dart';

@JsonSerializable()
class DevicePairingCompleteRequest {
  const DevicePairingCompleteRequest({
    required this.pairingPublicId,
    required this.challenge,
    required this.signature,
    this.displayName,
  });

  factory DevicePairingCompleteRequest.fromJson(Map<String, Object?> json) =>
      _$DevicePairingCompleteRequestFromJson(json);

  final String pairingPublicId;
  final String challenge;
  final String signature;
  final String? displayName;

  Map<String, Object?> toJson() => _$DevicePairingCompleteRequestToJson(this);
}
