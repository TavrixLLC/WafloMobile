import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final checkOnly = arguments.contains('--check');
  final root = Directory.current;
  final generatedM1 = Directory(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
    '${Platform.pathSeparator}api${Platform.pathSeparator}generated',
  );
  final generatedM2 = Directory(
    '${root.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
    '${Platform.pathSeparator}api${Platform.pathSeparator}generated_m2',
  );
  final beforeM1 = checkOnly ? await _hashTree(generatedM1) : null;
  final beforeM2 = checkOnly ? await _hashTree(generatedM2) : null;
  final m2GeneratorConfig = await _prepareGeneratorInput(root);

  for (final directory in [generatedM1, generatedM2]) {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }

  await _run('dart', [
    'run',
    'swagger_parser',
    '--file',
    'swagger_parser.yaml',
  ]);
  _normalizeKnownGeneratorLimitations(generatedM1);
  await _run('dart', [
    'run',
    'swagger_parser',
    '--file',
    m2GeneratorConfig.path,
  ]);
  await _run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  await _run('dart', ['format', generatedM1.path, generatedM2.path]);

  if (checkOnly) {
    final afterM1 = await _hashTree(generatedM1);
    final afterM2 = await _hashTree(generatedM2);
    if (!_sameTree(beforeM1!, afterM1) || !_sameTree(beforeM2!, afterM2)) {
      stderr.writeln(
        'Generated W4 client drift detected. Run dart run tool/generate_w4_client.dart.',
      );
      exitCode = 1;
    }
  }
}

Future<File> _prepareGeneratorInput(Directory root) async {
  final source = File(
    '${root.path}${Platform.pathSeparator}contracts${Platform.pathSeparator}w4'
    '${Platform.pathSeparator}m2${Platform.pathSeparator}openapi.m2.json',
  );
  final decoded = jsonDecode(await source.readAsString());
  if (decoded is! Map<String, Object?>) {
    throw const FormatException(
      'The approved M2 OpenAPI root must be an object.',
    );
  }

  var normalizedTupleCount = 0;
  void normalize(Object? node) {
    if (node is List<Object?>) {
      for (final value in node) {
        normalize(value);
      }
      return;
    }
    if (node is! Map<String, Object?>) {
      return;
    }
    final items = node['items'];
    if (node['type'] == 'array' && items is List<Object?>) {
      final constants = items
          .map((item) {
            if (item is! Map<String, Object?> || item['type'] != 'string') {
              throw const FormatException(
                'Unsupported tuple schema in M2 OpenAPI.',
              );
            }
            return item['const'];
          })
          .toList(growable: false);
      if (constants.length != 2 ||
          constants[0] != 'FILLED' ||
          constants[1] != 'EMPTY') {
        throw const FormatException('Unexpected M2 stamp-state tuple.');
      }
      // swagger_parser 1.44 does not accept JSON Schema tuple arrays. This
      // generator-only representation preserves the two approved values; the
      // domain validator still enforces their exact order and cardinality.
      node['items'] = <String, Object?>{'type': 'string', 'enum': constants};
      node['minItems'] = constants.length;
      node['maxItems'] = constants.length;
      normalizedTupleCount += 1;
    }
    for (final value in node.values) {
      normalize(value);
    }
  }

  normalize(decoded);
  if (normalizedTupleCount != 2) {
    throw StateError(
      'Expected two approved stamp-state tuples, found $normalizedTupleCount.',
    );
  }
  _normalizeCommandStatusForGenerator(decoded);

  final temporary = Directory(
    '${root.path}${Platform.pathSeparator}.dart_tool'
    '${Platform.pathSeparator}w4_m2_codegen',
  );
  await temporary.create(recursive: true);
  final openApi = File(
    '${temporary.path}${Platform.pathSeparator}openapi.m2.codegen.json',
  );
  await openApi.writeAsString(jsonEncode(decoded));
  final config = File(
    '${temporary.path}${Platform.pathSeparator}swagger_parser.m2.yaml',
  );
  final normalizedPath = openApi.path.replaceAll(r'\', '/');
  await config.writeAsString('''
swagger_parser:
  schema_path: $normalizedPath
  output_directory: lib/core/api/generated_m2
  name: w4_m2
  language: dart
  json_serializer: json_serializable
  default_content_type: application/json
  extras_parameter_by_default: false
  add_openapi_metadata: true
  dio_options_parameter_by_default: true
  root_client: true
  root_client_name: W4M2ApiClient
  export_file: true
  put_in_folder: false
''');
  return config;
}

void _normalizeCommandStatusForGenerator(Map<String, Object?> openApi) {
  final components = openApi['components'];
  final schemas = components is Map<String, Object?>
      ? components['schemas']
      : null;
  final commandStatus = schemas is Map<String, Object?>
      ? schemas['CommandStatus']
      : null;
  final variants = commandStatus is Map<String, Object?>
      ? commandStatus['anyOf']
      : null;
  if (variants is! List<Object?> || variants.length != 4) {
    throw const FormatException('Unexpected M2 command-status union.');
  }
  final normalizedCommandStatus = commandStatus as Map<String, Object?>;

  final statuses = <Object?>{};
  for (final variant in variants) {
    if (variant is! Map<String, Object?>) {
      throw const FormatException('Malformed M2 command-status variant.');
    }
    final properties = variant['properties'];
    if (properties is! Map<String, Object?>) {
      throw const FormatException('Malformed M2 command-status properties.');
    }
    final status = properties['status'];
    if (status is! Map<String, Object?>) {
      throw const FormatException('Malformed M2 command status.');
    }
    statuses.add(status['const']);
  }
  if (!statuses.containsAll(const ['PROCESSING', 'FAILED', 'COMPLETED'])) {
    throw const FormatException('Unexpected M2 command-status values.');
  }

  // swagger_parser 1.44 cannot generate a valid Dart representation for this
  // four-way JSON Schema union. The generator-only superset contains exactly
  // the union's common fields. Runtime domain parsing validates each variant.
  normalizedCommandStatus
    ..clear()
    ..addAll(<String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'commandId': <String, Object?>{'type': 'string', 'format': 'uuid'},
        'operationPublicId': <String, Object?>{
          'type': 'string',
          'format': 'uuid',
          'nullable': true,
        },
        'operationType': <String, Object?>{
          'type': 'string',
          'enum': <String>['STAMP', 'REDEMPTION'],
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <String>['PROCESSING', 'FAILED', 'COMPLETED'],
        },
        'safeFailureCode': <String, Object?>{
          'type': 'string',
          'nullable': true,
        },
        'result': <String, Object?>{
          'type': 'object',
          'nullable': true,
          'additionalProperties': true,
        },
        'createdAt': <String, Object?>{'type': 'string', 'format': 'date-time'},
        'completedAt': <String, Object?>{
          'type': 'string',
          'format': 'date-time',
          'nullable': true,
        },
        'requestId': <String, Object?>{'type': 'string'},
      },
      'required': <String>[
        'commandId',
        'operationPublicId',
        'operationType',
        'status',
        'safeFailureCode',
        'result',
        'createdAt',
        'completedAt',
        'requestId',
      ],
      'additionalProperties': false,
    });
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
