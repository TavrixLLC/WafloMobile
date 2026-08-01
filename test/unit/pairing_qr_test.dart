import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

void main() {
  final fixture = _fixtureToken();

  test('parses the approved W4 pairing QR shape', () {
    final parsed = const PairingQrParser(
      expectedEnvironment: 'test',
    ).parse(fixture);
    expect(parsed.version, PairingQrParser.supportedVersion);
    expect(parsed.pairingPublicId, '00000000-0000-4000-8000-000000000100');
    expect(parsed.apiEnvironment, 'test');
    expect(parsed.oneTimeSecret, hasLength(43));
    expect(parsed.toString(), isNot(contains(parsed.oneTimeSecret)));
  });

  test('rejects unsupported version', () {
    final unsupported = fixture.replaceFirst('waflo-pair-v1', 'waflo-pair-v2');
    expect(
      () =>
          const PairingQrParser(expectedEnvironment: 'test').parse(unsupported),
      throwsA(
        isA<PairingQrException>().having(
          (error) => error.problem,
          'problem',
          PairingQrProblem.unsupportedVersion,
        ),
      ),
    );
  });

  test('rejects QR for a different environment', () {
    expect(
      () => const PairingQrParser(
        expectedEnvironment: 'development',
      ).parse(fixture),
      throwsA(
        isA<PairingQrException>().having(
          (error) => error.problem,
          'problem',
          PairingQrProblem.wrongEnvironment,
        ),
      ),
    );
  });

  test('enforces total length and printable ASCII limits', () {
    const parser = PairingQrParser(expectedEnvironment: 'test');
    expect(() => parser.parse('x' * 79), throwsA(isA<PairingQrException>()));
    expect(() => parser.parse('x' * 513), throwsA(isA<PairingQrException>()));
    expect(
      () =>
          parser.parse('${fixture.substring(0, 90)}\n${fixture.substring(91)}'),
      throwsA(isA<PairingQrException>()),
    );
  });
}

String _fixtureToken() {
  final root =
      jsonDecode(
            File('contracts/w4/deterministic-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  final shape = root['pairingQrShape']! as Map<String, Object?>;
  return shape['token']! as String;
}
