import 'dart:convert';

enum PairingQrProblem { invalid, unsupportedVersion, wrongEnvironment }

final class PairingQrException implements Exception {
  const PairingQrException(this.problem);

  final PairingQrProblem problem;

  @override
  String toString() => 'PairingQrException(${problem.name})';
}

final class PairingQrPayload {
  const PairingQrPayload._({
    required this.version,
    required this.pairingPublicId,
    required this.oneTimeSecret,
    required this.apiEnvironment,
    required this.rawToken,
  });

  final String version;
  final String pairingPublicId;
  final String oneTimeSecret;
  final String apiEnvironment;
  final String rawToken;

  @override
  String toString() =>
      'PairingQrPayload(version: $version, pairingPublicId: [REDACTED], environment: $apiEnvironment)';
}

final class PairingQrParser {
  const PairingQrParser({required this.expectedEnvironment});

  static const supportedVersion = 'waflo-pair-v1';
  static final RegExp _base64Url = RegExp(r'^[A-Za-z0-9_-]+$');
  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _environment = RegExp(r'^[a-zA-Z0-9-]{2,32}$');

  final String expectedEnvironment;

  PairingQrPayload parse(String candidate) {
    if (candidate.length < 80 ||
        candidate.length > 512 ||
        candidate.codeUnits.any((value) => value < 0x21 || value > 0x7e)) {
      throw const PairingQrException(PairingQrProblem.invalid);
    }
    final parts = candidate.split('.');
    if (parts.length != 4) {
      throw const PairingQrException(PairingQrProblem.invalid);
    }
    if (parts[0] != supportedVersion) {
      throw const PairingQrException(PairingQrProblem.unsupportedVersion);
    }
    try {
      final pairingId = utf8.decode(_decode(parts[1], maximumBytes: 64));
      final secret = _decode(parts[2], maximumBytes: 64);
      final environment = utf8.decode(_decode(parts[3], maximumBytes: 32));
      if (!_uuid.hasMatch(pairingId) ||
          secret.length != 32 ||
          !_environment.hasMatch(environment)) {
        throw const PairingQrException(PairingQrProblem.invalid);
      }
      if (environment != expectedEnvironment) {
        throw const PairingQrException(PairingQrProblem.wrongEnvironment);
      }
      return PairingQrPayload._(
        version: parts[0],
        pairingPublicId: pairingId,
        oneTimeSecret: parts[2],
        apiEnvironment: environment,
        rawToken: candidate,
      );
    } on FormatException {
      throw const PairingQrException(PairingQrProblem.invalid);
    }
  }

  static List<int> _decode(String value, {required int maximumBytes}) {
    if (!_base64Url.hasMatch(value) || value.length > maximumBytes * 2) {
      throw const FormatException('Invalid base64url segment.');
    }
    final padded = value.padRight((value.length + 3) ~/ 4 * 4, '=');
    final decoded = base64Url.decode(padded);
    if (decoded.isEmpty || decoded.length > maximumBytes) {
      throw const FormatException('Decoded segment is out of bounds.');
    }
    return decoded;
  }
}
