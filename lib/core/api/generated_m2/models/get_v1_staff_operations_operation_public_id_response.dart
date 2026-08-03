// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'command_status.dart';

part 'get_v1_staff_operations_operation_public_id_response.g.dart';

@JsonSerializable()
class GetV1StaffOperationsOperationPublicIdResponse {
  const GetV1StaffOperationsOperationPublicIdResponse({
    required this.data,
    required this.requestId,
  });

  factory GetV1StaffOperationsOperationPublicIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetV1StaffOperationsOperationPublicIdResponseFromJson(json);

  final CommandStatus data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$GetV1StaffOperationsOperationPublicIdResponseToJson(this);
}
