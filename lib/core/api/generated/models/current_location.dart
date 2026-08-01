// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'current_location.g.dart';

@JsonSerializable()
class CurrentLocation {
  const CurrentLocation({
    required this.publicId,
    required this.displayName,
    required this.earningAllowed,
    required this.redemptionAllowed,
  });

  factory CurrentLocation.fromJson(Map<String, Object?> json) =>
      _$CurrentLocationFromJson(json);

  final String publicId;
  final String displayName;
  final bool earningAllowed;
  final bool redemptionAllowed;

  Map<String, Object?> toJson() => _$CurrentLocationToJson(this);
}
