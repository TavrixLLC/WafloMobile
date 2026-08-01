// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'platform.dart';

part 'device.g.dart';

@JsonSerializable()
class Device {
  const Device({
    required this.publicId,
    required this.displayName,
    required this.platform,
    required this.status,
  });

  factory Device.fromJson(Map<String, Object?> json) => _$DeviceFromJson(json);

  final String publicId;
  final String displayName;
  final Platform platform;
  final String status;

  Map<String, Object?> toJson() => _$DeviceToJson(this);
}
