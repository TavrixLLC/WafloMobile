// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'error.g.dart';

@JsonSerializable()
class Error {
  const Error({
    required this.code,
    required this.message,
    required this.requestId,
    this.details,
  });

  factory Error.fromJson(Map<String, Object?> json) => _$ErrorFromJson(json);

  final String code;

  /// Diagnostic only; never mobile UI copy.
  final String message;
  final dynamic details;
  final String requestId;

  Map<String, Object?> toJson() => _$ErrorToJson(this);
}
