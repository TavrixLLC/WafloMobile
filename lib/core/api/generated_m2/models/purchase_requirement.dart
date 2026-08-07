// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'purchase_requirement.g.dart';

@JsonSerializable()
class PurchaseRequirement {
  const PurchaseRequirement({
    required this.requiredValue,
    required this.minimumAmountMinor,
    required this.currency,
  });

  factory PurchaseRequirement.fromJson(Map<String, Object?> json) =>
      _$PurchaseRequirementFromJson(json);

  /// The name has been replaced because it contains a keyword. Original name: `required`.
  @JsonKey(name: 'required')
  final bool requiredValue;
  final int? minimumAmountMinor;
  final String? currency;

  Map<String, Object?> toJson() => _$PurchaseRequirementToJson(this);
}
