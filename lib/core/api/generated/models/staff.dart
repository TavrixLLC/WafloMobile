// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'role.dart';

part 'staff.g.dart';

@JsonSerializable()
class Staff {
  const Staff({
    required this.publicId,
    required this.displayName,
    required this.role,
  });

  factory Staff.fromJson(Map<String, Object?> json) => _$StaffFromJson(json);

  final String publicId;
  final String displayName;
  final Role role;

  Map<String, Object?> toJson() => _$StaffToJson(this);
}
