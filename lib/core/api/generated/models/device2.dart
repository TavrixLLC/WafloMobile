// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'status.dart';
import 'platform.dart';

part 'device2.g.dart';

@JsonSerializable()
class Device2 {
  const Device2({
    required this.publicId,
    required this.displayName,
    required this.status,
    required this.platform,
    required this.appVersion,
  });

  factory Device2.fromJson(Map<String, Object?> json) =>
      _$Device2FromJson(json);

  final String publicId;
  final String displayName;
  final Status status;
  final Platform platform;
  final String appVersion;

  Map<String, Object?> toJson() => _$Device2ToJson(this);
}
