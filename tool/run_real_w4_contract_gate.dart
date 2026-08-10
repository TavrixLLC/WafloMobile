import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'real_w4_backend_verifier.dart';

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
  await verifyApprovedRealW4Backend(
    mobileRoot: mobileRoot,
    backendRoot: backend,
    outputLabel: 'Approved W4 source',
  );
  if (!File(_join(backend.path, '.env')).existsSync()) {
    _fail('Approved W4 requires a local development .env file.');
  }
  final baseDatabaseUrl = _readDatabaseUrl(File(_join(backend.path, '.env')));
  final testDatabaseName = _testDatabaseName();
  final testDatabaseUrl = _testDatabaseUrl(baseDatabaseUrl, testDatabaseName);

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
    'RATE_LIMIT_NAMESPACE': 'waflo-m2-contract-$runNamespace',
    'STAFF_MOBILE_MINIMUM_APP_VERSION': '1.0.0',
    'WAFLO_W4_BACKEND_ROOT': backend.path,
    'WAFLO_CONTRACT_API_PORT': '$apiPort',
    'WAFLO_CONTRACT_CONTROL_PORT': '$controlPort',
    'WAFLO_CONTRACT_CONTROL_SECRET': controlSecret,
    'WAFLO_CONTRACT_ALLOW_LOCAL_DATABASE_MUTATION': 'EPHEMERAL_TEST_DATA_ONLY',
    'DATABASE_URL': testDatabaseUrl,
    'WAFLO_TEST_DATABASE_NAME': testDatabaseName,
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

  Process? fixture;
  StreamSubscription<String>? outputSubscription;
  StreamSubscription<String>? errorSubscription;
  var databaseCreated = false;
  var testExitCode = 1;
  try {
    await _manageDatabase(
      mobileRoot: mobileRoot,
      backend: backend,
      baseDatabaseUrl: baseDatabaseUrl,
      databaseName: testDatabaseName,
      mode: 'create',
    );
    databaseCreated = true;
    await _prepareDatabase(backend, fixtureEnvironment);

    fixture = await Process.start(
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
    outputSubscription = fixtureOutput.listen((line) {
      stdout.writeln(_redact(line));
      if (line.startsWith('W4_CONTRACT_FIXTURE_READY') && !ready.isCompleted) {
        ready.complete();
      }
    });
    errorSubscription = fixtureErrors.listen(
      (line) => stderr.writeln(_redact(line)),
    );

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
  } finally {
    if (fixture != null) {
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
    }
    await outputSubscription?.cancel();
    await errorSubscription?.cancel();
    if (databaseCreated) {
      await _manageDatabase(
        mobileRoot: mobileRoot,
        backend: backend,
        baseDatabaseUrl: baseDatabaseUrl,
        databaseName: testDatabaseName,
        mode: 'drop',
      );
    }
  }
  stdout.writeln(
    'REAL_W4_CONTRACT_GATE_PASS tests=26 cleanup=isolated-database-dropped',
  );
  exitCode = testExitCode;
}

Future<void> _prepareDatabase(
  Directory backend,
  Map<String, String> environment,
) async {
  final pnpm = Platform.isWindows ? 'pnpm.cmd' : 'pnpm';
  for (final task in const ['migrate:deploy', 'seed']) {
    final result = await Process.run(
      pnpm,
      ['--filter', '@waflo/database', task],
      workingDirectory: backend.path,
      environment: environment,
      includeParentEnvironment: true,
      runInShell: Platform.isWindows,
    );
    stdout.write(_redact(result.stdout as String));
    stderr.write(_redact(result.stderr as String));
    if (result.exitCode != 0) {
      throw StateError(
        'Approved W4 isolated database $task failed with exit code '
        '${result.exitCode}.',
      );
    }
  }
}

Future<void> _manageDatabase({
  required Directory mobileRoot,
  required Directory backend,
  required String baseDatabaseUrl,
  required String databaseName,
  required String mode,
}) async {
  final result = await Process.run(
    'node',
    [
      _join(mobileRoot.path, 'tool/w4_isolated_database.mjs'),
      mode,
      databaseName,
    ],
    workingDirectory: backend.path,
    environment: {
      ...Platform.environment,
      'WAFLO_W4_BACKEND_ROOT': backend.path,
      'WAFLO_W4_BASE_DATABASE_URL': baseDatabaseUrl,
    },
    includeParentEnvironment: true,
    runInShell: Platform.isWindows,
  );
  if (result.exitCode != 0) {
    stderr.write(_redact(result.stderr as String));
    throw StateError('Unable to $mode the isolated Real W4 database.');
  }
}

String _readDatabaseUrl(File environmentFile) {
  for (final rawLine in environmentFile.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator < 1 ||
        line.substring(0, separator).trim() != 'DATABASE_URL') {
      continue;
    }
    var value = line.substring(separator + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'postgres' && uri.scheme != 'postgresql') ||
        !const {'localhost', '127.0.0.1', '::1'}.contains(uri.host) ||
        uri.pathSegments.isEmpty) {
      _fail('Approved W4 DATABASE_URL is not dedicated local PostgreSQL.');
    }
    return value;
  }
  _fail('Approved W4 .env does not define DATABASE_URL.');
}

String _testDatabaseName() {
  final suffix = List<int>.generate(
    6,
    (_) => Random.secure().nextInt(256),
  ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return 'waflo_test_mobile_${DateTime.now().millisecondsSinceEpoch}_$suffix';
}

String _testDatabaseUrl(String baseUrl, String databaseName) {
  final base = Uri.parse(baseUrl);
  return base
      .replace(
        path: '/$databaseName',
        queryParameters: {...base.queryParameters, 'schema': 'public'},
      )
      .toString();
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
