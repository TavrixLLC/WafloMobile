// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'api_error_body.g.dart';

@JsonSerializable()
class ApiErrorBody {
  const ApiErrorBody({
    required this.code,
    required this.message,
    required this.requestId,
    this.details,
  });

  factory ApiErrorBody.fromJson(Map<String, Object?> json) =>
      _$ApiErrorBodyFromJson(json);

  final String code;
  final String message;
  final dynamic details;
  final String requestId;

  Map<String, Object?> toJson() => _$ApiErrorBodyToJson(this);
}
