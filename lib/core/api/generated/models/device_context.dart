// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'platform.dart';
import 'role.dart';
import 'uuid.dart';

part 'device_context.g.dart';

@JsonSerializable()
class DeviceContext {
  const DeviceContext({
    required this.organizationId,
    required this.organizationMemberId,
    required this.role,
    required this.locationId,
    required this.deviceId,
    required this.devicePublicId,
    required this.deviceSessionId,
    required this.platform,
    required this.requestId,
  });

  factory DeviceContext.fromJson(Map<String, Object?> json) =>
      _$DeviceContextFromJson(json);

  final Uuid organizationId;
  final Uuid organizationMemberId;
  final Role role;
  final Uuid locationId;
  final Uuid deviceId;
  final Uuid devicePublicId;
  final Uuid deviceSessionId;
  final Platform platform;
  final String requestId;

  Map<String, Object?> toJson() => _$DeviceContextToJson(this);
}
