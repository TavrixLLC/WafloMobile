// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_summary_status.dart';
import 'platform.dart';
import 'uuid.dart';

part 'device_summary.g.dart';

@JsonSerializable()
class DeviceSummary {
  const DeviceSummary({
    required this.publicId,
    required this.displayName,
    required this.platform,
    required this.status,
  });

  factory DeviceSummary.fromJson(Map<String, Object?> json) =>
      _$DeviceSummaryFromJson(json);

  final Uuid publicId;
  final String displayName;
  final Platform platform;
  final DeviceSummaryStatus status;

  Map<String, Object?> toJson() => _$DeviceSummaryToJson(this);
}
