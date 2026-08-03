// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'location_eligibility.g.dart';

@JsonSerializable()
class LocationEligibility {
  const LocationEligibility({required this.earning, required this.redemption});

  factory LocationEligibility.fromJson(Map<String, Object?> json) =>
      _$LocationEligibilityFromJson(json);

  final bool earning;
  final bool redemption;

  Map<String, Object?> toJson() => _$LocationEligibilityToJson(this);
}
