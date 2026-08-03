import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractDirectory = 'contracts/w4/m2';
const _checksumFile = '$_contractDirectory/contract-checksums.sha256';

Future<void> main() async {
  final failures = <String>[];
  final checksumLines = await File(_checksumFile).readAsLines();
  final expected = <String, String>{};

  for (final line in checksumLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    final match = RegExp(r'^([a-f0-9]{64})  ([^/\\]+)$').firstMatch(trimmed);
    if (match == null) {
      failures.add('Malformed checksum line: $trimmed');
      continue;
    }
    expected[match.group(2)!] = match.group(1)!;
  }

  const required = <String>{
    'm2.schema.json',
    'membership-resolve.fixture.json',
    'openapi.m2.json',
    'operation-completed.fixture.json',
    'operation-failed.fixture.json',
    'operation-processing.fixture.json',
    'redeem-final-reset.fixture.json',
    'redeem-milestone.fixture.json',
    'source-manifest.json',
    'stable-error-codes.m2.json',
    'stamp-final-ready.fixture.json',
    'stamp-success.fixture.json',
    'stamp-visual.fixture.json',
  };

  if (expected.keys.toSet().difference(required).isNotEmpty ||
      required.difference(expected.keys.toSet()).isNotEmpty) {
    failures.add('Checksum inventory does not match the approved M2 bundle.');
  }

  for (final entry in expected.entries) {
    final file = File('$_contractDirectory/${entry.key}');
    if (!file.existsSync()) {
      failures.add('Missing contract file: ${entry.key}');
      continue;
    }
    final actual = sha256.convert(await file.readAsBytes()).toString();
    if (actual != entry.value) {
      failures.add('Checksum mismatch: ${entry.key}');
    }
  }

  final manifestValue = jsonDecode(
    await File('$_contractDirectory/source-manifest.json').readAsString(),
  );
  if (manifestValue is! Map<String, Object?>) {
    failures.add('source-manifest.json must contain an object.');
  } else {
    final backendCommit = manifestValue['backendCommitSha'];
    final aggregateChecksum = manifestValue['contractChecksum'];
    if (backendCommit is! String ||
        !RegExp(r'^[a-f0-9]{40}$').hasMatch(backendCommit)) {
      failures.add('Backend commit SHA is missing or malformed.');
    }
    if (aggregateChecksum is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(aggregateChecksum)) {
      failures.add('Aggregate contract checksum is missing or malformed.');
    }
    if (manifestValue['containsCredentials'] != false ||
        manifestValue['containsRealQrValues'] != false) {
      failures.add('Approved bundle safety declarations are not satisfied.');
    }
  }

  if (failures.isNotEmpty) {
    for (final failure in failures) {
      stderr.writeln(failure);
    }
    exitCode = 1;
    return;
  }

  final manifest = manifestValue as Map<String, Object?>;
  stdout.writeln(
    'M2 contract verification passed: ${expected.length} files; '
    'backend ${manifest['backendCommitSha']}; '
    'contract ${manifest['contractChecksum']}.',
  );
}
