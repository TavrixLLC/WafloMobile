// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_limits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationLimits _$OperationLimitsFromJson(Map<String, dynamic> json) =>
    OperationLimits(
      maximumStampsPerOperation: (json['maximumStampsPerOperation'] as num)
          .toInt(),
      maximumStampsPerCustomerPerDay:
          (json['maximumStampsPerCustomerPerDay'] as num?)?.toInt(),
      dailyRemainingStamps: (json['dailyRemainingStamps'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OperationLimitsToJson(OperationLimits instance) =>
    <String, dynamic>{
      'maximumStampsPerOperation': instance.maximumStampsPerOperation,
      'maximumStampsPerCustomerPerDay': instance.maximumStampsPerCustomerPerDay,
      'dailyRemainingStamps': instance.dailyRemainingStamps,
    };
