// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'operation_limits.g.dart';

@JsonSerializable()
class OperationLimits {
  const OperationLimits({
    required this.maximumStampsPerOperation,
    required this.maximumStampsPerCustomerPerDay,
    required this.dailyRemainingStamps,
  });

  factory OperationLimits.fromJson(Map<String, Object?> json) =>
      _$OperationLimitsFromJson(json);

  final int maximumStampsPerOperation;
  final int? maximumStampsPerCustomerPerDay;
  final int? dailyRemainingStamps;

  Map<String, Object?> toJson() => _$OperationLimitsToJson(this);
}
