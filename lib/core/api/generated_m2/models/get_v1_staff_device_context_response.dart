// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'staff_device_context_result.dart';

part 'get_v1_staff_device_context_response.g.dart';

@JsonSerializable()
class GetV1StaffDeviceContextResponse {
  const GetV1StaffDeviceContextResponse({
    required this.data,
    required this.requestId,
  });

  factory GetV1StaffDeviceContextResponse.fromJson(Map<String, Object?> json) =>
      _$GetV1StaffDeviceContextResponseFromJson(json);

  final StaffDeviceContextResult data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$GetV1StaffDeviceContextResponseToJson(this);
}
