// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'uuid.dart';

part 'pairing_complete_request.g.dart';

@JsonSerializable()
class PairingCompleteRequest {
  const PairingCompleteRequest({
    required this.pairingPublicId,
    required this.challenge,
    required this.signature,
    this.displayName,
  });

  factory PairingCompleteRequest.fromJson(Map<String, Object?> json) =>
      _$PairingCompleteRequestFromJson(json);

  final Uuid pairingPublicId;
  final String challenge;
  final String signature;
  final String? displayName;

  Map<String, Object?> toJson() => _$PairingCompleteRequestToJson(this);
}
