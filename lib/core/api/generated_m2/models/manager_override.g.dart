// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manager_override.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManagerOverride _$ManagerOverrideFromJson(Map<String, dynamic> json) =>
    ManagerOverride(
      approvalPublicId: json['approvalPublicId'] as String,
      reason: json['reason'] as String,
      dailyCap: json['dailyCap'] as bool? ?? false,
      purchasePolicy: json['purchasePolicy'] as bool? ?? false,
    );

Map<String, dynamic> _$ManagerOverrideToJson(ManagerOverride instance) =>
    <String, dynamic>{
      'approvalPublicId': instance.approvalPublicId,
      'dailyCap': instance.dailyCap,
      'purchasePolicy': instance.purchasePolicy,
      'reason': instance.reason,
    };
