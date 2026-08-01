import 'dart:io';

Future<void> main() async {
  final tracked = await _trackedFiles();
  final problems = <String>[];
  final forbiddenNames = RegExp(
    r'(^|/)(\.env($|\.)|node_modules|\.dart_tool|build|Pods|DerivedData)(/|$)|\.(pem|p12|pfx|key|jks|keystore|sqlite|sqlite3|db)$',
    caseSensitive: false,
  );
  final forbiddenBackendPaths = RegExp(
    r'(^|/)(apps/api|packages/staff-device-security|prisma|migrations)(/|$)',
    caseSensitive: false,
  );
  final privateKeyMarker = RegExp(r'-----BEGIN (?:RSA |EC )?PRIVATE KEY-----');
  final credentialLiteral = RegExp(
    r'(?:accessToken|refreshToken|pairingSecret)\s*[:=]\s*["\x27][A-Za-z0-9_\-\.]{32,}',
  );
  final usablePairingQr = RegExp(
    r'waflo-pair-v1\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]{40,}\.[A-Za-z0-9_-]+',
  );

  for (final path in tracked) {
    final normalized = path.replaceAll('\\', '/');
    if (forbiddenNames.hasMatch(normalized)) {
      problems.add('Forbidden artifact path: $normalized');
    }
    if (forbiddenBackendPaths.hasMatch(normalized)) {
      problems.add('Backend runtime path copied into mobile repo: $normalized');
    }
    final file = File(path);
    if (!file.existsSync() || _isBinary(path)) {
      continue;
    }
    final text = await file.readAsString();
    if (privateKeyMarker.hasMatch(text)) {
      problems.add('Private-key marker: $normalized');
    }
    final fixtureOrEvidence =
        normalized.startsWith('contracts/w4/') ||
        normalized.startsWith('test/') ||
        normalized.startsWith('integration_test/') ||
        normalized.startsWith('docs/') ||
        normalized.startsWith('artifacts/handoff-m1/') ||
        normalized.startsWith('artifacts/handoff-m1-round-1/');
    if (!fixtureOrEvidence && credentialLiteral.hasMatch(text)) {
      problems.add('Credential-like literal in runtime source: $normalized');
    }
    if (!fixtureOrEvidence && usablePairingQr.hasMatch(text)) {
      problems.add('Pairing QR literal in runtime source: $normalized');
    }
  }

  if (problems.isNotEmpty) {
    stderr.writeln(problems.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Security scan passed: ${tracked.length} tracked files; no forbidden backend artifacts, private keys, or runtime credential literals.',
  );
}

Future<List<String>> _trackedFiles() async {
  final result = await Process.run('git', [
    'ls-files',
    '-co',
    '--exclude-standard',
  ]);
  if (result.exitCode != 0) {
    throw StateError('Unable to enumerate repository files safely.');
  }
  return (result.stdout as String)
      .split(RegExp(r'[\r\n]+'))
      .where((path) => path.isNotEmpty)
      .toList(growable: false);
}

bool _isBinary(String path) => RegExp(
  r'\.(png|jpg|jpeg|gif|webp|ico|zip|apk|aab|ttf|otf)$',
  caseSensitive: false,
).hasMatch(path);
