import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

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
  final manifestFile = File(
    _join(mobileRoot.path, 'contracts/w4/m2/source-manifest.json'),
  );
  final manifest = jsonDecode(await manifestFile.readAsString());
  if (manifest is! Map<String, Object?> ||
      manifest['backendCommitSha'] is! String ||
      manifest['sourceFiles'] is! List<Object?>) {
    _fail('The authoritative M2 source manifest is malformed.');
  }

  final expectedCommit = manifest['backendCommitSha']! as String;
  final git = await Process.run(
    'git',
    ['rev-parse', 'HEAD'],
    workingDirectory: backendRoot.path,
    runInShell: Platform.isWindows,
  );
  if (git.exitCode != 0 || (git.stdout as String).trim() != expectedCommit) {
    _fail('Approved W4 checkout is not at M2 commit $expectedCommit.');
  }

  final mismatches = <String>[];
  for (final value in manifest['sourceFiles']! as List<Object?>) {
    if (value is! Map<String, Object?> ||
        value['path'] is! String ||
        value['sha256'] is! String) {
      _fail('The authoritative M2 source manifest has an invalid entry.');
    }
    final relative = value['path']! as String;
    final source = File(_join(backendRoot.path, relative));
    if (!source.existsSync()) {
      mismatches.add('$relative (missing)');
      continue;
    }
    final actual = sha256.convert(await source.readAsBytes()).toString();
    if (actual != value['sha256']) mismatches.add('$relative (checksum)');
  }
  if (mismatches.isNotEmpty) {
    _fail(
      'Approved W4 M2 source verification failed: ${mismatches.join(', ')}',
    );
  }
  stdout.writeln(
    'Approved W4 M2 source verified: commit=$expectedCommit files=${(manifest['sourceFiles']! as List<Object?>).length}.',
  );

  final node = Platform.isWindows ? 'node.exe' : 'node';
  final gate = await Process.start(
    node,
    ['scripts/run-m2-quality-gate.mjs'],
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
  if (code != 0) {
    _fail('Approved W4 M2 quality gate failed with exit code $code.');
  }
  stdout.writeln(
    'REAL_W4_M2_CONTRACT_GATE_PASS backend=$expectedCommit cleanup=backend-gate-owned',
  );
}

String? _argument(List<String> arguments, String prefix) {
  for (final value in arguments) {
    if (value.startsWith(prefix)) return value.substring(prefix.length);
  }
  return null;
}

String _join(String root, String relative) =>
    '$root${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';

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
