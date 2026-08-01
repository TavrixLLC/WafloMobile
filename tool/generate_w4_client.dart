import 'dart:io';

Future<void> main(List<String> arguments) async {
  final checkOnly = arguments.contains('--check');
  final root = Directory.current;
  final generated = Directory(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
    '${Platform.pathSeparator}api${Platform.pathSeparator}generated',
  );
  final before = checkOnly ? await _hashTree(generated) : null;

  if (generated.existsSync()) {
    generated.deleteSync(recursive: true);
  }

  await _run('dart', [
    'run',
    'swagger_parser',
    '--file',
    'swagger_parser.yaml',
  ]);
  _normalizeKnownGeneratorLimitations(generated);
  await _run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  await _run('dart', ['format', generated.path]);

  if (checkOnly) {
    final after = await _hashTree(generated);
    if (!_sameTree(before!, after)) {
      stderr.writeln(
        'Generated W4 client drift detected. Run dart run tool/generate_w4_client.dart.',
      );
      exitCode = 1;
    }
  }
}

void _normalizeKnownGeneratorLimitations(Directory generated) {
  final client = File(
    '${generated.path}${Platform.pathSeparator}staff_device_pairing'
    '${Platform.pathSeparator}staff_device_pairing_client.dart',
  );
  final source = client.readAsStringSync();
  const duplicate =
      "    @Header('x-waflo-device-id') required String xWafloDeviceId,\n"
      "    @Header('authorization') required String authorization,\n"
      "    @Header('x-waflo-device-id') required String xWafloDeviceId,\n";
  const normalized =
      "    @Header('authorization') required String authorization,\n"
      "    @Header('x-waflo-device-id') required String xWafloDeviceId,\n";
  final occurrences = duplicate.allMatches(source).length;
  if (occurrences != 1) {
    throw StateError(
      'Expected one known duplicate device-id parameter, found $occurrences.',
    );
  }
  client.writeAsStringSync(source.replaceFirst(duplicate, normalized));
}

Future<Map<String, String>> _hashTree(Directory directory) async {
  if (!directory.existsSync()) {
    return const {};
  }
  final result = <String, String>{};
  await for (final entity in directory.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final relative = entity.path.substring(directory.path.length + 1);
    final digest = await Process.run('git', ['hash-object', entity.path]);
    if (digest.exitCode != 0) {
      throw StateError('Unable to hash $relative: ${digest.stderr}');
    }
    result[relative] = (digest.stdout as String).trim();
  }
  return result;
}

bool _sameTree(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

Future<void> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(executable, arguments, '', code);
  }
}
