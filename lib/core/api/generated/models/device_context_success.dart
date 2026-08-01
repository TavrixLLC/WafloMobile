// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'device_context.dart';

part 'device_context_success.g.dart';

@JsonSerializable()
class DeviceContextSuccess {
  const DeviceContextSuccess({required this.data, required this.requestId});

  factory DeviceContextSuccess.fromJson(Map<String, Object?> json) =>
      _$DeviceContextSuccessFromJson(json);

  final DeviceContext data;
  final String requestId;

  Map<String, Object?> toJson() => _$DeviceContextSuccessToJson(this);
}
