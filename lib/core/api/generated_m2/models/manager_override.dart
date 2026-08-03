// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'manager_override.g.dart';

@JsonSerializable()
class ManagerOverride {
  const ManagerOverride({
    required this.approvalPublicId,
    required this.reason,
    this.dailyCap = false,
    this.purchasePolicy = false,
  });

  factory ManagerOverride.fromJson(Map<String, Object?> json) =>
      _$ManagerOverrideFromJson(json);

  final String approvalPublicId;
  final bool dailyCap;
  final bool purchasePolicy;
  final String reason;

  Map<String, Object?> toJson() => _$ManagerOverrideToJson(this);
}
