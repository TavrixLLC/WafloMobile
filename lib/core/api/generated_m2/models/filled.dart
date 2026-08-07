// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'filled.g.dart';

@JsonSerializable()
class Filled {
  const Filled({required this.state, required this.contentDigest});

  factory Filled.fromJson(Map<String, Object?> json) => _$FilledFromJson(json);

  final String state;
  final String? contentDigest;

  Map<String, Object?> toJson() => _$FilledToJson(this);
}
