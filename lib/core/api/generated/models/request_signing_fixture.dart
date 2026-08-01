// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'request_signing_fixture_method.dart';

part 'request_signing_fixture.g.dart';

@JsonSerializable()
class RequestSigningFixture {
  const RequestSigningFixture({
    required this.envelopeVersion,
    required this.algorithm,
    required this.method,
    required this.canonicalPath,
    required this.requestId,
    required this.timestamp,
    required this.nonce,
    required this.bodySha256,
    required this.deviceSessionId,
    required this.organizationId,
    required this.separator,
    required this.containsCredential,
  });

  factory RequestSigningFixture.fromJson(Map<String, Object?> json) =>
      _$RequestSigningFixtureFromJson(json);

  final String envelopeVersion;
  final String algorithm;
  final RequestSigningFixtureMethod method;
  final String canonicalPath;
  final String requestId;
  final DateTime timestamp;
  final String nonce;
  final String bodySha256;
  final String deviceSessionId;
  final String organizationId;
  final String separator;
  final bool containsCredential;

  Map<String, Object?> toJson() => _$RequestSigningFixtureToJson(this);
}
