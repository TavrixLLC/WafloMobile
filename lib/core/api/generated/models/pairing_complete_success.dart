// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pairing_complete_data.dart';

part 'pairing_complete_success.g.dart';

@JsonSerializable()
class PairingCompleteSuccess {
  const PairingCompleteSuccess({required this.data, required this.requestId});

  factory PairingCompleteSuccess.fromJson(Map<String, Object?> json) =>
      _$PairingCompleteSuccessFromJson(json);

  final PairingCompleteData data;
  final String requestId;

  Map<String, Object?> toJson() => _$PairingCompleteSuccessToJson(this);
}
