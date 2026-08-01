// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'app_policy.g.dart';

@JsonSerializable()
class AppPolicy {
  const AppPolicy({
    required this.minimumSupportedVersion,
    required this.updateRequired,
  });

  factory AppPolicy.fromJson(Map<String, Object?> json) =>
      _$AppPolicyFromJson(json);

  final String minimumSupportedVersion;
  final bool updateRequired;

  Map<String, Object?> toJson() => _$AppPolicyToJson(this);
}
