// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'staff_device_context_result_platform.dart';
import 'staff_device_context_result_role.dart';

part 'staff_device_context_result.g.dart';

@JsonSerializable()
class StaffDeviceContextResult {
  const StaffDeviceContextResult({
    required this.organizationId,
    required this.role,
    required this.locationId,
    required this.devicePublicId,
    required this.deviceSessionId,
    required this.platform,
    required this.appVersion,
    required this.minimumSupportedAppVersion,
    required this.appVersionSupported,
    required this.requestId,
  });

  factory StaffDeviceContextResult.fromJson(Map<String, Object?> json) =>
      _$StaffDeviceContextResultFromJson(json);

  final String organizationId;
  final StaffDeviceContextResultRole role;
  final String locationId;
  final String devicePublicId;
  final String deviceSessionId;
  final StaffDeviceContextResultPlatform platform;
  final String appVersion;
  final String minimumSupportedAppVersion;
  final bool appVersionSupported;
  final String requestId;

  Map<String, Object?> toJson() => _$StaffDeviceContextResultToJson(this);
}
