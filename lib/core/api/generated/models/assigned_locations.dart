// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'assigned_locations.g.dart';

@JsonSerializable()
class AssignedLocations {
  const AssignedLocations({
    required this.publicId,
    required this.displayName,
    required this.earningAllowed,
    required this.redemptionAllowed,
  });

  factory AssignedLocations.fromJson(Map<String, Object?> json) =>
      _$AssignedLocationsFromJson(json);

  final String publicId;
  final String displayName;
  final bool earningAllowed;
  final bool redemptionAllowed;

  Map<String, Object?> toJson() => _$AssignedLocationsToJson(this);
}
