// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'session2.g.dart';

@JsonSerializable()
class Session2 {
  const Session2({
    required this.id,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory Session2.fromJson(Map<String, Object?> json) =>
      _$Session2FromJson(json);

  final String id;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  Map<String, Object?> toJson() => _$Session2ToJson(this);
}
