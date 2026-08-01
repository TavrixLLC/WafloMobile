// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_signing_fixture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestSigningFixture _$RequestSigningFixtureFromJson(
  Map<String, dynamic> json,
) => RequestSigningFixture(
  envelopeVersion: json['envelopeVersion'] as String,
  algorithm: json['algorithm'] as String,
  method: RequestSigningFixtureMethod.fromJson(json['method'] as String),
  canonicalPath: json['canonicalPath'] as String,
  requestId: json['requestId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  nonce: json['nonce'] as String,
  bodySha256: json['bodySha256'] as String,
  deviceSessionId: json['deviceSessionId'] as String,
  organizationId: json['organizationId'] as String,
  separator: json['separator'] as String,
  containsCredential: json['containsCredential'] as bool,
);

Map<String, dynamic> _$RequestSigningFixtureToJson(
  RequestSigningFixture instance,
) => <String, dynamic>{
  'envelopeVersion': instance.envelopeVersion,
  'algorithm': instance.algorithm,
  'method': _$RequestSigningFixtureMethodEnumMap[instance.method]!,
  'canonicalPath': instance.canonicalPath,
  'requestId': instance.requestId,
  'timestamp': instance.timestamp.toIso8601String(),
  'nonce': instance.nonce,
  'bodySha256': instance.bodySha256,
  'deviceSessionId': instance.deviceSessionId,
  'organizationId': instance.organizationId,
  'separator': instance.separator,
  'containsCredential': instance.containsCredential,
};

const _$RequestSigningFixtureMethodEnumMap = {
  RequestSigningFixtureMethod.valueGet: 'GET',
  RequestSigningFixtureMethod.post: 'POST',
  RequestSigningFixtureMethod.put: 'PUT',
  RequestSigningFixtureMethod.patch: 'PATCH',
  RequestSigningFixtureMethod.delete: 'DELETE',
  RequestSigningFixtureMethod.$unknown: r'$unknown',
};
