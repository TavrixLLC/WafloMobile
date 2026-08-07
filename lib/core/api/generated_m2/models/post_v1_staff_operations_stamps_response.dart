// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'stamp_operation_result.dart';

part 'post_v1_staff_operations_stamps_response.g.dart';

@JsonSerializable()
class PostV1StaffOperationsStampsResponse {
  const PostV1StaffOperationsStampsResponse({
    required this.data,
    required this.requestId,
  });

  factory PostV1StaffOperationsStampsResponse.fromJson(
    Map<String, Object?> json,
  ) => _$PostV1StaffOperationsStampsResponseFromJson(json);

  final StampOperationResult data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$PostV1StaffOperationsStampsResponseToJson(this);
}
