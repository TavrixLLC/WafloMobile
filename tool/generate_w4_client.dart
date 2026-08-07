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
  final beforeM1 = checkOnly ? await _readTree(generatedM1) : null;
  final beforeM2 = checkOnly ? await _readTree(generatedM2) : null;
  final m2GeneratorConfig = await _prepareGeneratorInput(root);

  try {
    for (final directory in [generatedM1, generatedM2]) {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }

    await _run(Platform.resolvedExecutable, [
      'run',
      'swagger_parser',
      '--file',
      'swagger_parser.yaml',
    ]);
    _normalizeKnownGeneratorLimitations(generatedM1);
    await _run(Platform.resolvedExecutable, [
      'run',
      'swagger_parser',
      '--file',
      m2GeneratorConfig.path,
    ]);
    await _run(Platform.resolvedExecutable, [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
    await _run(Platform.resolvedExecutable, [
      'format',
      generatedM1.path,
      generatedM2.path,
    ]);

    if (checkOnly) {
      final afterM1 = await _readTree(generatedM1);
      final afterM2 = await _readTree(generatedM2);
      if (!_sameTree(beforeM1!, afterM1) || !_sameTree(beforeM2!, afterM2)) {
        stderr.writeln(
          'Generated W4 client drift detected. Run dart run tool/generate_w4_client.dart.',
        );
        exitCode = 1;
      }
    }
  } finally {
    if (checkOnly) {
      await _restoreTree(generatedM1, beforeM1!);
      await _restoreTree(generatedM2, beforeM2!);
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
  if (normalizedTupleCount != 0 && normalizedTupleCount != 2) {
    throw StateError(
      'Expected zero or two approved stamp-state tuples, found '
      '$normalizedTupleCount.',
    );
  }
  _validateStampVisualStates(decoded);
  _normalizeCommandStatusForGenerator(decoded);
  _normalizeOperationPublicStatusForGenerator(decoded);

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

void _normalizeOperationPublicStatusForGenerator(Map<String, Object?> openApi) {
  final components = openApi['components'];
  final schemas = components is Map<String, Object?>
      ? components['schemas']
      : null;
  final operationStatus = schemas is Map<String, Object?>
      ? schemas['OperationPublicStatusResult']
      : null;
  final properties = operationStatus is Map<String, Object?>
      ? operationStatus['properties']
      : null;
  if (properties is! Map<String, Object?>) {
    throw const FormatException('Malformed M2 operation-status schema.');
  }
  final status = properties['status'];
  final statuses = status is Map<String, Object?> ? status['enum'] : null;
  const expectedStatuses = {'PROCESSING', 'COMPLETED', 'FAILED'};
  if (statuses is! List<Object?> ||
      statuses.toSet().difference(expectedStatuses).isNotEmpty ||
      expectedStatuses.difference(statuses.toSet()).isNotEmpty) {
    throw const FormatException('Unexpected M2 operation-status values.');
  }
  final resultPayload = properties['resultPayload'];
  final outerVariants = resultPayload is Map<String, Object?>
      ? resultPayload['anyOf']
      : null;
  if (outerVariants is! List<Object?> || outerVariants.length != 2) {
    throw const FormatException('Unexpected M2 operation result union.');
  }
  final resultUnion = outerVariants
      .whereType<Map<String, Object?>>()
      .firstWhere(
        (candidate) => candidate['anyOf'] is List<Object?>,
        orElse: () => const {},
      );
  final resultVariants = resultUnion['anyOf'];
  if (resultVariants is! List<Object?> || resultVariants.length != 3) {
    throw const FormatException('Unexpected M2 operation result variants.');
  }

  // swagger_parser 1.44 cannot generate this nullable three-result union.
  // Runtime adapters validate the authoritative payload before display.
  properties['resultPayload'] = <String, Object?>{
    'type': 'object',
    'nullable': true,
    'additionalProperties': true,
  };
}

void _validateStampVisualStates(Map<String, Object?> openApi) {
  final components = openApi['components'];
  final schemas = components is Map<String, Object?>
      ? components['schemas']
      : null;
  final membership = schemas is Map<String, Object?>
      ? schemas['MembershipResolveResult']
      : null;
  final membershipProperties = membership is Map<String, Object?>
      ? membership['properties']
      : null;
  final stampVisuals = membershipProperties is Map<String, Object?>
      ? membershipProperties['stampVisuals']
      : null;
  final visualProperties = stampVisuals is Map<String, Object?>
      ? stampVisuals['properties']
      : null;
  if (visualProperties is! Map<String, Object?> ||
      visualProperties.keys.toSet().difference(const {
        'filled',
        'empty',
      }).isNotEmpty ||
      const {
        'filled',
        'empty',
      }.difference(visualProperties.keys.toSet()).isNotEmpty) {
    throw const FormatException('Unexpected M2 stamp visual states.');
  }

  String? stateFor(String key) {
    final visual = visualProperties[key];
    final properties = visual is Map<String, Object?>
        ? visual['properties']
        : null;
    final state = properties is Map<String, Object?>
        ? properties['state']
        : null;
    return state is Map<String, Object?> ? state['const'] as String? : null;
  }

  if (stateFor('filled') != 'FILLED' || stateFor('empty') != 'EMPTY') {
    throw const FormatException('Unexpected M2 stamp visual constants.');
  }
}

void _normalizeCommandStatusForGenerator(Map<String, Object?> openApi) {
  final components = openApi['components'];
  final schemas = components is Map<String, Object?>
      ? components['schemas']
      : null;
  final commandStatus = schemas is Map<String, Object?>
      ? schemas['OperationCommandStatusResult']
      : null;
  final properties = commandStatus is Map<String, Object?>
      ? commandStatus['properties']
      : null;
  if (properties is! Map<String, Object?>) {
    throw const FormatException('Malformed M2 command-status schema.');
  }
  final status = properties['status'];
  final statuses = status is Map<String, Object?> ? status['enum'] : null;
  if (statuses is! List<Object?> ||
      statuses.toSet().difference(const {
        'PROCESSING',
        'COMPLETED',
        'FAILED',
      }).isNotEmpty ||
      const {
        'PROCESSING',
        'COMPLETED',
        'FAILED',
      }.difference(statuses.toSet()).isNotEmpty) {
    throw const FormatException('Unexpected M2 command-status values.');
  }
  final operationType = properties['operationType'];
  final operationTypes = operationType is Map<String, Object?>
      ? operationType['enum']
      : null;
  const expectedOperationTypes = {
    'ISSUE_STAMP',
    'REDEEM_REWARD',
    'REVERSE_STAMP',
    'REVERSE_REDEMPTION',
    'MANUAL_ADJUSTMENT',
    'SUSPEND_MEMBERSHIP',
    'RESTORE_MEMBERSHIP',
    'REVOKE_MEMBERSHIP',
    'EXPIRE_REWARD',
  };
  if (operationTypes is! List<Object?> ||
      operationTypes.toSet().difference(expectedOperationTypes).isNotEmpty ||
      expectedOperationTypes.difference(operationTypes.toSet()).isNotEmpty) {
    throw const FormatException('Unexpected M2 command operation types.');
  }
  final result = properties['result'];
  final outerVariants = result is Map<String, Object?> ? result['anyOf'] : null;
  if (outerVariants is! List<Object?> || outerVariants.length != 2) {
    throw const FormatException('Unexpected M2 command result union.');
  }
  final resultUnion = outerVariants
      .whereType<Map<String, Object?>>()
      .firstWhere(
        (candidate) => candidate['anyOf'] is List<Object?>,
        orElse: () => const {},
      );
  final resultVariants = resultUnion['anyOf'];
  if (resultVariants is! List<Object?> || resultVariants.length != 3) {
    throw const FormatException('Unexpected M2 command result variants.');
  }

  // swagger_parser 1.44 cannot generate this nullable three-result union.
  // The generator-only field is a nullable map; runtime domain parsing below
  // validates status, command ID, operation type, and the authoritative result
  // shape before any success is displayed.
  properties['result'] = <String, Object?>{
    'type': 'object',
    'nullable': true,
    'additionalProperties': true,
  };
  properties['safeFailureCode'] = <String, Object?>{
    'type': 'string',
    'nullable': true,
  };
  properties['completedAt'] = <String, Object?>{
    'type': 'string',
    'format': 'date-time',
    'nullable': true,
  };
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

Future<Map<String, List<int>>> _readTree(Directory directory) async {
  if (!directory.existsSync()) {
    return const {};
  }
  final result = <String, List<int>>{};
  await for (final entity in directory.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final relative = entity.path.substring(directory.path.length + 1);
    result[relative] = await entity.readAsBytes();
  }
  return result;
}

bool _sameTree(Map<String, List<int>> left, Map<String, List<int>> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    final other = right[entry.key];
    if (other == null ||
        _canonicalGeneratedText(entry.value) !=
            _canonicalGeneratedText(other)) {
      return false;
    }
  }
  return true;
}

String _canonicalGeneratedText(List<int> bytes) =>
    utf8.decode(bytes).replaceAll('\r\n', '\n').replaceAll('\r', '\n');

Future<void> _restoreTree(
  Directory directory,
  Map<String, List<int>> snapshot,
) async {
  if (directory.existsSync()) {
    await directory.delete(recursive: true);
  }
  for (final entry in snapshot.entries) {
    final file = File('${directory.path}${Platform.pathSeparator}${entry.key}');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(entry.value, flush: true);
  }
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
