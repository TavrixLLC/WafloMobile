// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'context.dart';
import 'device.dart';
import 'session.dart';

part 'device_pairing_complete_response.g.dart';

@JsonSerializable()
class DevicePairingCompleteResponse {
  const DevicePairingCompleteResponse({
    required this.device,
    required this.session,
    required this.context,
  });

  factory DevicePairingCompleteResponse.fromJson(Map<String, Object?> json) =>
      _$DevicePairingCompleteResponseFromJson(json);

  final Device device;
  final Session session;
  final Context context;

  Map<String, Object?> toJson() => _$DevicePairingCompleteResponseToJson(this);
}
