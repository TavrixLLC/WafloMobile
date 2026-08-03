// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class Locations {
  const Locations({
    required this.locationId,
    required this.earningAllowed,
    required this.redemptionAllowed,
  });

  factory Locations.fromJson(Map<String, Object?> json) =>
      _$LocationsFromJson(json);

  final String locationId;
  final bool earningAllowed;
  final bool redemptionAllowed;

  Map<String, Object?> toJson() => _$LocationsToJson(this);
}
