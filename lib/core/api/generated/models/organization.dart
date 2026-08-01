// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  const Organization({required this.publicId, required this.displayName});

  factory Organization.fromJson(Map<String, Object?> json) =>
      _$OrganizationFromJson(json);

  final String publicId;
  final String displayName;

  Map<String, Object?> toJson() => _$OrganizationToJson(this);
}
