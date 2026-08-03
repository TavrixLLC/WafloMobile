// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_v1_staff_operations_redeem_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostV1StaffOperationsRedeemResponse
_$PostV1StaffOperationsRedeemResponseFromJson(Map<String, dynamic> json) =>
    PostV1StaffOperationsRedeemResponse(
      data: RedemptionResult.fromJson(json['data'] as Map<String, dynamic>),
      requestId: json['requestId'] as String,
    );

Map<String, dynamic> _$PostV1StaffOperationsRedeemResponseToJson(
  PostV1StaffOperationsRedeemResponse instance,
) => <String, dynamic>{'data': instance.data, 'requestId': instance.requestId};
