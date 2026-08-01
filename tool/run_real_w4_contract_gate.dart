import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> arguments) async {
  final backendRoot =
      _argument(arguments, '--backend-root=') ??
      Platform.environment['WAFLO_W4_BACKEND_ROOT'];
  if (backendRoot == null || backendRoot.isEmpty) {
    _fail('Set WAFLO_W4_BACKEND_ROOT to the approved W4 repository checkout.');
  }
  if (Platform.environment['WAFLO_RUN_BACKEND_CONTRACT'] != 'true') {
    _fail(
      'Set WAFLO_RUN_BACKEND_CONTRACT=true to authorize the development-only gate.',
    );
  }

  final mobileRoot = Directory.current.absolute;
  final backend = Directory(backendRoot).absolute;
  await _verifyApprovedBackend(mobileRoot, backend);
  if (!File(_join(backend.path, '.env')).existsSync()) {
    _fail('Approved W4 requires a local development .env file.');
  }

  final apiPort = await _availablePort();
  final controlPort = await _availablePort();
  final controlSecret = _randomSecret();
  final runNamespace = _randomSecret().substring(0, 16);
  final fixtureEnvironment = <String, String>{
    ...Platform.environment,
    'NODE_ENV': 'development',
    'TEST_STAFF_CLIENT_ENABLED': 'true',
    'API_PORT': '$apiPort',
    'SCALE_LOCATION_LIMIT': '100',
    'SCALE_TEAM_LIMIT': '100',
    'RATE_LIMIT_NAMESPACE': 'waflo-m1-contract-$runNamespace',
    'WAFLO_W4_BACKEND_ROOT': backend.path,
    'WAFLO_CONTRACT_API_PORT': '$apiPort',
    'WAFLO_CONTRACT_CONTROL_PORT': '$controlPort',
    'WAFLO_CONTRACT_CONTROL_SECRET': controlSecret,
    'WAFLO_CONTRACT_ALLOW_LOCAL_DATABASE_MUTATION': 'EPHEMERAL_TEST_DATA_ONLY',
  };
  final pnpm = Platform.isWindows ? 'pnpm.cmd' : 'pnpm';
  final build = await Process.run(
    pnpm,
    ['--filter', '@waflo/api...', 'build'],
    workingDirectory: backend.path,
    environment: fixtureEnvironment,
    includeParentEnvironment: true,
    runInShell: Platform.isWindows,
  );
  stdout.write(_redact(build.stdout as String));
  stderr.write(_redact(build.stderr as String));
  if (build.exitCode != 0) {
    _fail('Approved W4 build failed with exit code ${build.exitCode}.');
  }

  final fixture = await Process.start(
    'node',
    [_join(mobileRoot.path, 'tool/w4_contract_fixture.mjs')],
    workingDirectory: backend.path,
    environment: fixtureEnvironment,
    includeParentEnvironment: true,
    runInShell: Platform.isWindows,
  );

  final ready = Completer<void>();
  final fixtureOutput = fixture.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  final fixtureErrors = fixture.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter());
  final outputSubscription = fixtureOutput.listen((line) {
    stdout.writeln(_redact(line));
    if (line.startsWith('W4_CONTRACT_FIXTURE_READY') && !ready.isCompleted) {
      ready.complete();
    }
  });
  final errorSubscription = fixtureErrors.listen(
    (line) => stderr.writeln(_redact(line)),
  );

  var testExitCode = 1;
  try {
    await Future.any<void>([
      ready.future,
      Future<void>.delayed(
        const Duration(seconds: 60),
        () => throw TimeoutException('W4 fixture did not become ready.'),
      ),
      fixture.exitCode.then<void>(
        (code) =>
            throw StateError('W4 fixture exited before readiness ($code).'),
      ),
    ]);

    final testEnvironment = <String, String>{
      ...Platform.environment,
      'WAFLO_RUN_BACKEND_CONTRACT': 'true',
      'WAFLO_CONTRACT_API_URL': 'http://127.0.0.1:$apiPort',
      'WAFLO_CONTRACT_CONTROL_URL': 'http://127.0.0.1:$controlPort',
      'WAFLO_CONTRACT_CONTROL_SECRET': controlSecret,
    };
    final flutter = Platform.isWindows ? 'flutter.bat' : 'flutter';
    final tests = await Process.start(
      flutter,
      [
        'test',
        'test/contract/real_backend_contract_test.dart',
        '--reporter',
        'expanded',
      ],
      workingDirectory: mobileRoot.path,
      environment: testEnvironment,
      includeParentEnvironment: true,
      runInShell: Platform.isWindows,
    );
    final testOut = tests.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) => stdout.writeln(_redact(line)));
    final testErr = tests.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) => stderr.writeln(_redact(line)));
    testExitCode = await tests.exitCode;
    await Future.wait([testOut, testErr]);
    if (testExitCode != 0) {
      throw StateError(
        'Real W4 contract gate failed with exit code $testExitCode.',
      );
    }
    stdout.writeln('REAL_W4_CONTRACT_GATE_PASS tests=11 cleanup=verified');
  } finally {
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/PID', '${fixture.pid}', '/T', '/F']);
    } else {
      fixture.kill(ProcessSignal.sigterm);
      try {
        await fixture.exitCode.timeout(const Duration(seconds: 20));
      } on TimeoutException {
        fixture.kill(ProcessSignal.sigkill);
      }
    }
    await outputSubscription.cancel();
    await errorSubscription.cancel();
  }
  exitCode = testExitCode;
}

Future<void> _verifyApprovedBackend(
  Directory mobileRoot,
  Directory backendRoot,
) async {
  if (!backendRoot.existsSync()) _fail('Approved W4 checkout does not exist.');
  final manifestFile = File(
    _join(mobileRoot.path, 'contracts/w4/source-manifest.json'),
  );
  final manifest = jsonDecode(await manifestFile.readAsString());
  if (manifest is! Map<String, Object?> || manifest['sourceFiles'] is! List) {
    _fail('The authoritative W4 source manifest is invalid.');
  }
  final mismatches = <String>[];
  for (final entry in manifest['sourceFiles'] as List<Object?>) {
    if (entry is! Map<String, Object?> ||
        entry['path'] is! String ||
        entry['sha256'] is! String) {
      _fail('The authoritative W4 source manifest contains an invalid entry.');
    }
    final relative = entry['path'] as String;
    final file = File(_join(backendRoot.path, relative));
    if (!file.existsSync()) {
      mismatches.add('$relative (missing)');
      continue;
    }
    final actual = sha256.convert(await file.readAsBytes()).toString();
    if (actual != entry['sha256']) mismatches.add('$relative (checksum)');
  }
  if (mismatches.isNotEmpty) {
    _fail(
      'W4 checkout does not match the authoritative source manifest: '
      '${mismatches.join(', ')}',
    );
  }
  stdout.writeln(
    'Approved W4 source verified: ${manifest['backendCommitSha']} + manifest checksums.',
  );
}

String? _argument(List<String> arguments, String prefix) {
  for (final value in arguments) {
    if (value.startsWith(prefix)) return value.substring(prefix.length);
  }
  return null;
}

Future<int> _availablePort() async {
  final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = socket.port;
  await socket.close();
  return port;
}

String _randomSecret() {
  final random = Random.secure();
  return base64Url
      .encode(List<int>.generate(32, (_) => random.nextInt(256)))
      .replaceAll('=', '');
}

String _join(String root, String relative) {
  final separator = Platform.pathSeparator;
  return '$root$separator${relative.replaceAll('/', separator)}';
}

String _redact(String input) => input
    .replaceAll(RegExp(r'wfp1\.[A-Za-z0-9_.-]+'), '[REDACTED_PAIRING_QR]')
    .replaceAll(
      RegExp(
        r'("(?:pairingQr|accessToken|refreshToken|token|privateKey)"\s*:\s*")[^"]+(")',
        caseSensitive: false,
      ),
      r'$1[REDACTED]$2',
    )
    .replaceAll(RegExp(r'Device\s+[A-Za-z0-9_.-]+'), 'Device [REDACTED]');

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
