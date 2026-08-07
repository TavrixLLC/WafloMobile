// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseRequirement _$PurchaseRequirementFromJson(Map<String, dynamic> json) =>
    PurchaseRequirement(
      requiredValue: json['required'] as bool,
      minimumAmountMinor: (json['minimumAmountMinor'] as num?)?.toInt(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$PurchaseRequirementToJson(
  PurchaseRequirement instance,
) => <String, dynamic>{
  'required': instance.requiredValue,
  'minimumAmountMinor': instance.minimumAmountMinor,
  'currency': instance.currency,
};
