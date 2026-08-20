import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

void main() {
  test(
    'generates Ed25519 identity and exports standards-compliant SPKI',
    () async {
      final store = MemorySecureKeyValueStore();
      final repository = DeviceIdentityRepository(store);
      final identity = await repository.loadOrCreate();
      final spki = base64.decode(identity.publicKey);

      expect(identity.keyAlgorithm, 'Ed25519');
      expect(spki, hasLength(44));
      expect(spki.take(12), [
        0x30,
        0x2a,
        0x30,
        0x05,
        0x06,
        0x03,
        0x2b,
        0x65,
        0x70,
        0x03,
        0x21,
        0x00,
      ]);
      expect(store.snapshot.keys, ['device.identity.v1']);
      expect(identity.toString(), contains('[REDACTED]'));
    },
  );

  test(
    'signs the approved W4 pairing fixture message with generated key',
    () async {
      final repository = DeviceIdentityRepository(MemorySecureKeyValueStore());
      final identity = await repository.loadOrCreate();
      final fixture = _fixtureMap('pairingMessage');
      final message = fixture['message']! as String;
      final encodedSignature = await repository.signUtf8(message);
      final publicBytes = base64.decode(identity.publicKey).sublist(12);
      final signatureBytes = _base64UrlDecode(encodedSignature);
      final verified = await Ed25519().verify(
        utf8.encode(message),
        signature: Signature(
          signatureBytes,
          publicKey: SimplePublicKey(publicBytes, type: KeyPairType.ed25519),
        ),
      );
      expect(verified, isTrue);
    },
  );

  test('matches canonical provider and M1 refresh fixtures exactly', () {
    for (final name in [
      'providerArtifactCanonicalRequest',
      'm1RefreshDigestAndEnvelope',
    ]) {
      final fixture = _fixtureMap(name);
      final fields = fixture['fields']! as Map<String, Object?>;
      final envelope = SignedRequestEnvelope(
        method: fields['method']! as String,
        canonicalPath: fields['canonicalPath']! as String,
        requestId: fields['requestId']! as String,
        timestamp: fields['timestamp']! as String,
        nonce: fields['nonce']! as String,
        bodyDigest: (fields['bodyDigest'] ?? fields['bodySha256'])! as String,
        deviceSessionId: fields['deviceSessionId']! as String,
        organizationId: fields['organizationId']! as String,
      );
      expect(envelope.canonicalize(), fixture['expectedEnvelope']);
    }
  });

  test('hashes empty and exact transmitted body bytes', () async {
    final calculator = BodyDigestCalculator();
    final constants = _fixtureMap('constants');
    final refresh = _fixtureMap('m1RefreshDigestAndEnvelope');
    expect(await calculator.calculate(const []), constants['emptyBodySha256']);
    expect(
      await calculator.calculate(
        utf8.encode(refresh['exactUtf8Body']! as String),
      ),
      refresh['expectedBodySha256'],
    );
  });

  test('nonce generator is unique and timestamp uses UTC ISO-8601', () async {
    final nonces = List.generate(128, (_) => SecureNonceGenerator().next());
    expect(nonces.toSet(), hasLength(nonces.length));

    final repository = DeviceIdentityRepository(MemorySecureKeyValueStore());
    await repository.loadOrCreate();
    final headers =
        await DeviceRequestSigner(
          repository,
          clock: _FixedClock(DateTime.utc(2026, DateTime.july, 30, 12)),
        ).sign(
          method: 'GET',
          canonicalPath: '/v1/staff/device-context',
          exactBodyBytes: const [],
          accessToken: 'fixture-token',
          devicePublicId: 'device-public-id',
          deviceSessionId: 'device-session-id',
          organizationId: 'organization-id',
        );
    expect(headers.timestamp, '2026-07-30T12:00:00.000Z');
    expect(headers.toString(), isNot(contains('fixture-token')));
  });

  test('global request ID is the signed device request ID', () async {
    final repository = DeviceIdentityRepository(MemorySecureKeyValueStore());
    final identity = await repository.loadOrCreate();
    final headers =
        await DeviceRequestSigner(
          repository,
          clock: _FixedClock(DateTime.utc(2026, DateTime.july, 30, 12)),
        ).sign(
          method: 'GET',
          canonicalPath: '/v1/staff/device-context',
          exactBodyBytes: const [],
          accessToken: 'fixture-token',
          devicePublicId: 'device-public-id',
          deviceSessionId: 'device-session-id',
          organizationId: 'organization-id',
        );
    final httpHeaders = headers.toHttpHeaders();
    final globalRequestId = httpHeaders['X-Request-Id'];

    expect(globalRequestId, isNotNull);
    expect(globalRequestId, httpHeaders['X-Waflo-Request-Id']);
    expect(globalRequestId, headers.requestId);

    final signedEnvelope = SignedRequestEnvelope(
      method: 'GET',
      canonicalPath: '/v1/staff/device-context',
      requestId: globalRequestId!,
      timestamp: headers.timestamp,
      nonce: headers.nonce,
      bodyDigest: headers.bodyDigest,
      deviceSessionId: headers.deviceSessionId,
      organizationId: 'organization-id',
    );
    final publicBytes = base64.decode(identity.publicKey).sublist(12);
    expect(
      await Ed25519().verify(
        utf8.encode(signedEnvelope.canonicalize()),
        signature: Signature(
          _base64UrlDecode(headers.signature),
          publicKey: SimplePublicKey(publicBytes, type: KeyPairType.ed25519),
        ),
      ),
      isTrue,
    );
  });

  test('corrupt identity fails closed', () async {
    final repository = DeviceIdentityRepository(
      MemorySecureKeyValueStore({'device.identity.v1': '{"bad":true}'}),
    );
    expect(
      repository.load,
      throwsA(
        isA<LocalSecurityFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'LOCAL_KEY_CORRUPT',
        ),
      ),
    );
  });
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

Map<String, Object?> _fixtureMap(String name) {
  final root =
      jsonDecode(
            File('contracts/w4/deterministic-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  return root[name]! as Map<String, Object?>;
}

List<int> _base64UrlDecode(String value) =>
    base64Url.decode(value.padRight((value.length + 3) ~/ 4 * 4, '='));
