// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_staff_operations_commands_command_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1StaffOperationsCommandsCommandIdResponse
_$GetV1StaffOperationsCommandsCommandIdResponseFromJson(
  Map<String, dynamic> json,
) => GetV1StaffOperationsCommandsCommandIdResponse(
  data: CommandStatus.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$GetV1StaffOperationsCommandsCommandIdResponseToJson(
  GetV1StaffOperationsCommandsCommandIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
