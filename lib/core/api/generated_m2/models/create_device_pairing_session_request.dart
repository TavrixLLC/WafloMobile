// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'locations.dart';

part 'create_device_pairing_session_request.g.dart';

@JsonSerializable()
class CreateDevicePairingSessionRequest {
  const CreateDevicePairingSessionRequest({
    required this.staffMemberId,
    required this.locations,
    this.expiresInMinutes = 10,
    this.deviceLabelSuggestion,
  });

  factory CreateDevicePairingSessionRequest.fromJson(
    Map<String, Object?> json,
  ) => _$CreateDevicePairingSessionRequestFromJson(json);

  final String staffMemberId;
  final List<Locations> locations;
  final String? deviceLabelSuggestion;
  final int expiresInMinutes;

  Map<String, Object?> toJson() =>
      _$CreateDevicePairingSessionRequestToJson(this);
}
