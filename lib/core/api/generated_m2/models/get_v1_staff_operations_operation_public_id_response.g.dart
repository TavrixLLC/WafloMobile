// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_v1_staff_operations_operation_public_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetV1StaffOperationsOperationPublicIdResponse
_$GetV1StaffOperationsOperationPublicIdResponseFromJson(
  Map<String, dynamic> json,
) => GetV1StaffOperationsOperationPublicIdResponse(
  data: CommandStatus.fromJson(json['data'] as Map<String, dynamic>),
  requestId: json['requestId'] as String,
);

Map<String, dynamic> _$GetV1StaffOperationsOperationPublicIdResponseToJson(
  GetV1StaffOperationsOperationPublicIdResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
