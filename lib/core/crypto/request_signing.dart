import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';

abstract interface class Clock {
  DateTime now();
}

final class UtcClock implements Clock {
  const UtcClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

abstract interface class NonceGenerator {
  String next();
}

final class SecureNonceGenerator implements NonceGenerator {
  SecureNonceGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  String next() => _uuid.v4();
}

final class BodyDigestCalculator {
  BodyDigestCalculator({Sha256? algorithm})
    : _algorithm = algorithm ?? Sha256();

  final Sha256 _algorithm;

  Future<String> calculate(List<int> exactBodyBytes) async {
    final hash = await _algorithm.hash(exactBodyBytes);
    return hash.bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

final class SignedRequestEnvelope {
  const SignedRequestEnvelope({
    required this.method,
    required this.canonicalPath,
    required this.requestId,
    required this.timestamp,
    required this.nonce,
    required this.bodyDigest,
    required this.deviceSessionId,
    required this.organizationId,
  });

  static const version = 'waflo-device-request-v1';
  static const _allowedMethods = {'GET', 'POST', 'PUT', 'PATCH', 'DELETE'};

  final String method;
  final String canonicalPath;
  final String requestId;
  final String timestamp;
  final String nonce;
  final String bodyDigest;
  final String deviceSessionId;
  final String organizationId;

  String canonicalize() {
    final normalizedMethod = method.toUpperCase();
    if (!_allowedMethods.contains(normalizedMethod) ||
        !canonicalPath.startsWith('/') ||
        canonicalPath.contains('?') ||
        canonicalPath.contains('#') ||
        canonicalPath.length > 512 ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(bodyDigest)) {
      throw const LocalSecurityFailure('CANONICAL_REQUEST_INVALID');
    }
    for (final value in [
      canonicalPath,
      requestId,
      timestamp,
      nonce,
      deviceSessionId,
      organizationId,
    ]) {
      if (value.isEmpty || value.contains(RegExp(r'[\r\n\u0000]'))) {
        throw const LocalSecurityFailure('CANONICAL_REQUEST_INVALID');
      }
    }
    if (requestId.length > 128 ||
        timestamp.length > 40 ||
        nonce.length > 128 ||
        deviceSessionId.length > 64 ||
        organizationId.length > 64) {
      throw const LocalSecurityFailure('CANONICAL_REQUEST_INVALID');
    }
    return [
      version,
      normalizedMethod,
      canonicalPath,
      requestId,
      timestamp,
      nonce,
      bodyDigest,
      deviceSessionId,
      organizationId,
    ].join('\n');
  }
}

final class SignedRequestHeaders {
  const SignedRequestHeaders({
    required this.authorization,
    required this.deviceId,
    required this.deviceSessionId,
    required this.requestId,
    required this.timestamp,
    required this.nonce,
    required this.bodyDigest,
    required this.signature,
  });

  final String authorization;
  final String deviceId;
  final String deviceSessionId;
  final String requestId;
  final String timestamp;
  final String nonce;
  final String bodyDigest;
  final String signature;

  Map<String, String> toHttpHeaders() => {
    'Authorization': authorization,
    'X-Waflo-Device-Id': deviceId,
    'X-Waflo-Device-Session-Id': deviceSessionId,
    'X-Waflo-Request-Id': requestId,
    'X-Request-Id': requestId,
    'X-Waflo-Timestamp': timestamp,
    'X-Waflo-Nonce': nonce,
    'X-Waflo-Body-Sha256': bodyDigest,
    'X-Waflo-Signature': signature,
  };

  @override
  String toString() => 'SignedRequestHeaders([REDACTED])';
}

final class DeviceRequestSigner {
  DeviceRequestSigner(
    this._identityRepository, {
    Clock? clock,
    NonceGenerator? nonceGenerator,
    BodyDigestCalculator? digestCalculator,
    Uuid? uuid,
  }) : _clock = clock ?? const UtcClock(),
       _nonceGenerator = nonceGenerator ?? SecureNonceGenerator(),
       _digestCalculator = digestCalculator ?? BodyDigestCalculator(),
       _uuid = uuid ?? const Uuid();

  final DeviceIdentityRepository _identityRepository;
  final Clock _clock;
  final NonceGenerator _nonceGenerator;
  final BodyDigestCalculator _digestCalculator;
  final Uuid _uuid;

  Future<SignedRequestHeaders> sign({
    required String method,
    required String canonicalPath,
    required List<int> exactBodyBytes,
    required String accessToken,
    required String devicePublicId,
    required String deviceSessionId,
    required String organizationId,
  }) async {
    final requestId = _uuid.v4();
    final timestamp = _clock.now().toUtc().toIso8601String();
    final nonce = _nonceGenerator.next();
    final digest = await _digestCalculator.calculate(exactBodyBytes);
    final envelope = SignedRequestEnvelope(
      method: method,
      canonicalPath: canonicalPath,
      requestId: requestId,
      timestamp: timestamp,
      nonce: nonce,
      bodyDigest: digest,
      deviceSessionId: deviceSessionId,
      organizationId: organizationId,
    );
    final signature = await _identityRepository.signUtf8(
      envelope.canonicalize(),
    );
    return SignedRequestHeaders(
      authorization: 'Device $accessToken',
      deviceId: devicePublicId,
      deviceSessionId: deviceSessionId,
      requestId: requestId,
      timestamp: timestamp,
      nonce: nonce,
      bodyDigest: digest,
      signature: signature,
    );
  }

  static List<int> utf8Body(String body) => utf8.encode(body);
}
