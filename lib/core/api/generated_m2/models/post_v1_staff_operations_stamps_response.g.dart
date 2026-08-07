// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_operations_stamps_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffOperationsStampsResponse
_$PostV1StaffOperationsStampsResponseFromJson(Map<String, dynamic> json) =>
    PostV1StaffOperationsStampsResponse(
      data: StampOperationResult.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PostV1StaffOperationsStampsResponseToJson(
  PostV1StaffOperationsStampsResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
