// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';

part 'context.g.dart';

@JsonSerializable()
class Context {
  const Context({
    required this.organizationId,
    required this.role,
    required this.locationId,
  });

  factory Context.fromJson(Map<String, Object?> json) =>
      _$ContextFromJson(json);

  final String organizationId;
  final Role role;
  final String locationId;

  Map<String, Object?> toJson() => _$ContextToJson(this);
}
