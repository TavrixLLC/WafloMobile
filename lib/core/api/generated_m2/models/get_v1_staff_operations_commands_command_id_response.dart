// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'operation_command_status_result.dart';

part 'get_v1_staff_operations_commands_command_id_response.g.dart';

@JsonSerializable()
class GetV1StaffOperationsCommandsCommandIdResponse {
  const GetV1StaffOperationsCommandsCommandIdResponse({
    required this.data,
    required this.requestId,
  });

  factory GetV1StaffOperationsCommandsCommandIdResponse.fromJson(
    Map<String, Object?> json,
  ) => _$GetV1StaffOperationsCommandsCommandIdResponseFromJson(json);

  final OperationCommandStatusResult data;
  final String requestId;

  Map<String, Object?> toJson() =>
      _$GetV1StaffOperationsCommandsCommandIdResponseToJson(this);
}
