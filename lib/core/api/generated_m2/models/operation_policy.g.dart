// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operation_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperationPolicy _$OperationPolicyFromJson(
  Map<String, dynamic> json,
) => OperationPolicy(
  minimumStampAmount: json['minimumStampAmount'] as num,
  maximumStampAmountPerOperation:
      (json['maximumStampAmountPerOperation'] as num).toInt(),
  remainingProgressCapacity: (json['remainingProgressCapacity'] as num).toInt(),
  effectiveMaximumStampAmount: (json['effectiveMaximumStampAmount'] as num)
      .toInt(),
  dailyLimitEnabled: json['dailyLimitEnabled'] as bool,
  dailyMaximumStampAmount: (json['dailyMaximumStampAmount'] as num?)?.toInt(),
  dailyRemainingStampAmount: (json['dailyRemainingStampAmount'] as num?)
      ?.toInt(),
  operationalLocalDate: DateTime.parse(json['operationalLocalDate'] as String),
  operationalTimezone: json['operationalTimezone'] as String,
  purchaseRequirementEnabled: json['purchaseRequirementEnabled'] as bool,
  minimumPurchaseAmountMinor: (json['minimumPurchaseAmountMinor'] as num?)
      ?.toInt(),
  purchaseCurrency: json['purchaseCurrency'] as String?,
  merchantTransactionReferenceAllowed:
      json['merchantTransactionReferenceAllowed'] as bool,
  merchantTransactionReferenceRequired:
      json['merchantTransactionReferenceRequired'] as bool,
  managerOverridePossibleForRole:
      json['managerOverridePossibleForRole'] as bool,
);

Map<String, dynamic> _$OperationPolicyToJson(OperationPolicy instance) =>
    <String, dynamic>{
      'minimumStampAmount': instance.minimumStampAmount,
      'maximumStampAmountPerOperation': instance.maximumStampAmountPerOperation,
      'remainingProgressCapacity': instance.remainingProgressCapacity,
      'effectiveMaximumStampAmount': instance.effectiveMaximumStampAmount,
      'dailyLimitEnabled': instance.dailyLimitEnabled,
      'dailyMaximumStampAmount': instance.dailyMaximumStampAmount,
      'dailyRemainingStampAmount': instance.dailyRemainingStampAmount,
      'operationalLocalDate': instance.operationalLocalDate.toIso8601String(),
      'operationalTimezone': instance.operationalTimezone,
      'purchaseRequirementEnabled': instance.purchaseRequirementEnabled,
      'minimumPurchaseAmountMinor': instance.minimumPurchaseAmountMinor,
      'purchaseCurrency': instance.purchaseCurrency,
      'merchantTransactionReferenceAllowed':
          instance.merchantTransactionReferenceAllowed,
      'merchantTransactionReferenceRequired':
          instance.merchantTransactionReferenceRequired,
      'managerOverridePossibleForRole': instance.managerOverridePossibleForRole,
    };
