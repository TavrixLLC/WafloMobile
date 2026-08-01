// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_session_credentials.dart';
import 'device_summary.dart';
import 'pairing_complete_context.dart';

part 'pairing_complete_data.g.dart';

@JsonSerializable()
class PairingCompleteData {
  const PairingCompleteData({
    required this.device,
    required this.session,
    required this.context,
  });

  factory PairingCompleteData.fromJson(Map<String, Object?> json) =>
      _$PairingCompleteDataFromJson(json);

  final DeviceSummary device;
  final DeviceSessionCredentials session;
  final PairingCompleteContext context;

  Map<String, Object?> toJson() => _$PairingCompleteDataToJson(this);
}
