// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'operation_policy.g.dart';

@JsonSerializable()
class OperationPolicy {
  const OperationPolicy({
    required this.minimumStampAmount,
    required this.maximumStampAmountPerOperation,
    required this.remainingProgressCapacity,
    required this.effectiveMaximumStampAmount,
    required this.dailyLimitEnabled,
    required this.dailyMaximumStampAmount,
    required this.dailyRemainingStampAmount,
    required this.operationalLocalDate,
    required this.operationalTimezone,
    required this.purchaseRequirementEnabled,
    required this.minimumPurchaseAmountMinor,
    required this.purchaseCurrency,
    required this.merchantTransactionReferenceAllowed,
    required this.merchantTransactionReferenceRequired,
    required this.managerOverridePossibleForRole,
  });

  factory OperationPolicy.fromJson(Map<String, Object?> json) =>
      _$OperationPolicyFromJson(json);

  final num minimumStampAmount;
  final int maximumStampAmountPerOperation;
  final int remainingProgressCapacity;
  final int effectiveMaximumStampAmount;
  final bool dailyLimitEnabled;
  final int? dailyMaximumStampAmount;
  final int? dailyRemainingStampAmount;
  final DateTime operationalLocalDate;
  final String operationalTimezone;
  final bool purchaseRequirementEnabled;
  final int? minimumPurchaseAmountMinor;
  final String? purchaseCurrency;
  final bool merchantTransactionReferenceAllowed;
  final bool merchantTransactionReferenceRequired;
  final bool managerOverridePossibleForRole;

  Map<String, Object?> toJson() => _$OperationPolicyToJson(this);
}
