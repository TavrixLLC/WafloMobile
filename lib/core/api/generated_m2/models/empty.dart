// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'empty.g.dart';

@JsonSerializable()
class Empty {
  const Empty({required this.state, required this.contentDigest});

  factory Empty.fromJson(Map<String, Object?> json) => _$EmptyFromJson(json);

  final String state;
  final String? contentDigest;

  Map<String, Object?> toJson() => _$EmptyToJson(this);
}
