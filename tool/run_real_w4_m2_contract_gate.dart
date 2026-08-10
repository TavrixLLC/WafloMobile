import 'dart:convert';
import 'dart:io';

import 'real_w4_backend_verifier.dart';

Future<void> main(List<String> arguments) async {
  if (Platform.environment['WAFLO_RUN_BACKEND_CONTRACT'] != 'true') {
    _fail(
      'WAFLO_RUN_BACKEND_CONTRACT=true is required on the approved runner.',
    );
  }
  final configured =
      _argument(arguments, '--backend-root=') ??
      Platform.environment['WAFLO_W4_BACKEND_ROOT'];
  if (configured == null || configured.trim().isEmpty) {
    _fail('WAFLO_W4_BACKEND_ROOT is required on the approved runner.');
  }

  final mobileRoot = Directory.current.absolute;
  final backendRoot = Directory(configured).absolute;
  final expectedCommit = await verifyApprovedRealW4Backend(
    mobileRoot: mobileRoot,
    backendRoot: backendRoot,
    outputLabel: 'Approved W4 M2 source',
  );

  final node = Platform.isWindows ? 'node.exe' : 'node';
  const focusedGates = <(String, List<String>, int)>[
    (
      'mobile contract unit',
      ['unit', 'tests/unit/m2-mobile-contracts.test.ts'],
      5,
    ),
    (
      'signed Staff HTTP',
      ['http', 'tests/http/w4-staff-operations.test.ts'],
      6,
    ),
    (
      'loyalty lifecycle',
      [
        'integration',
        'tests/integration/w4-operational-domain.test.ts',
        'tests/integration/w4-loyalty-lifecycle.test.ts',
      ],
      2,
    ),
    (
      'loyalty concurrency',
      ['concurrency', 'tests/concurrency/w4-loyalty-concurrency.test.ts'],
      3,
    ),
  ];
  var backendTestCount = 0;
  for (final (label, arguments, testCount) in focusedGates) {
    final code = await _runFocusedGate(
      node: node,
      backendRoot: backendRoot,
      label: label,
      arguments: arguments,
    );
    if (code != 0) {
      _fail('Approved W4 M2 $label gate failed with exit code $code.');
    }
    backendTestCount += testCount;
  }
  stdout.writeln(
    'REAL_W4_M2_CONTRACT_GATE_PASS backend=$expectedCommit tests=$backendTestCount cleanup=isolated-databases-dropped',
  );
}

Future<int> _runFocusedGate({
  required String node,
  required Directory backendRoot,
  required String label,
  required List<String> arguments,
}) async {
  stdout.writeln('Starting approved W4 M2 $label gate.');
  final gate = await Process.start(
    node,
    ['scripts/run-isolated-vitest.mjs', ...arguments],
    workingDirectory: backendRoot.path,
    environment: {
      ...Platform.environment,
      'WAFLO_RUN_BACKEND_CONTRACT': 'true',
    },
    includeParentEnvironment: true,
    runInShell: Platform.isWindows,
  );
  final stdoutDone = gate.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) => stdout.writeln(_redact(line)));
  final stderrDone = gate.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) => stderr.writeln(_redact(line)));
  final code = await gate.exitCode;
  await Future.wait([stdoutDone, stderrDone]);
  return code;
}

String? _argument(List<String> arguments, String prefix) {
  for (final value in arguments) {
    if (value.startsWith(prefix)) return value.substring(prefix.length);
  }
  return null;
}

String _redact(String input) => input
    .replaceAll(
      RegExp(
        r'("(?:qrPayload|pairingQr|accessToken|refreshToken|token|signature|nonce|privateKey)"\s*:\s*")[^"]+(" )?',
        caseSensitive: false,
      ),
      r'$1[REDACTED]$2',
    )
    .replaceAll(
      RegExp(r'(?:waflo-(?:pair|membership|customer)[A-Za-z0-9_.-]*)'),
      '[REDACTED_QR]',
    );

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
