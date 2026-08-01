// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Flutter production builds use IOS or ANDROID.
@JsonEnum()
enum Platform {
  @JsonValue('IOS')
  ios('IOS'),
  @JsonValue('ANDROID')
  android('ANDROID'),
  @JsonValue('TEST_CLIENT')
  testClient('TEST_CLIENT'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const Platform(this.json);

  factory Platform.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<Platform> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
