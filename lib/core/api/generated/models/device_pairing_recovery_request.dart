// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'device_pairing_recovery_request.g.dart';

@JsonSerializable()
class DevicePairingRecoveryRequest {
  const DevicePairingRecoveryRequest({required this.pairingPublicId});

  factory DevicePairingRecoveryRequest.fromJson(Map<String, Object?> json) =>
      _$DevicePairingRecoveryRequestFromJson(json);

  final String pairingPublicId;

  Map<String, Object?> toJson() => _$DevicePairingRecoveryRequestToJson(this);
}
