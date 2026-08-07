import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _contractDirectory = 'contracts/w4/m2';
const _checksumFile = '$_contractDirectory/contract-checksums.sha256';
const _backendCommit = '0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e';
const _parentCommit = '2b0000c5541cff0128804992780aaa80853e2655';
const _bundleChecksum =
    '3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae';

Future<void> main() async {
  final failures = <String>[];
  await _verifyCanonicalLf(failures);
  final expected = await _readChecksumInventory(failures);

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
    failures.add('Checksum inventory does not match the 13-file bundle.');
  }
  for (final entry in expected.entries) {
    final file = File('$_contractDirectory/${entry.key}');
    if (!file.existsSync()) {
      failures.add('Missing contract file: ${entry.key}');
      continue;
    }
    final actual = sha256.convert(await file.readAsBytes()).toString();
    if (actual != entry.value) failures.add('Checksum mismatch: ${entry.key}');
  }

  final manifest = _readObject('source-manifest.json', failures);
  _verifyManifest(manifest, expected, failures);
  _verifySchema(failures);

  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'M2 contract verification passed: 13 files, 12 generated hashes, '
    'canonical LF; backend $_backendCommit; bundle $_bundleChecksum.',
  );
}

Future<Map<String, String>> _readChecksumInventory(
  List<String> failures,
) async {
  final expected = <String, String>{};
  for (final line in await File(_checksumFile).readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final match = RegExp(r'^([a-f0-9]{64})  ([^/\\]+)$').firstMatch(trimmed);
    if (match == null) {
      failures.add('Malformed checksum line: $trimmed');
    } else {
      expected[match.group(2)!] = match.group(1)!;
    }
  }
  return expected;
}

Future<void> _verifyCanonicalLf(List<String> failures) async {
  await for (final entity in Directory('contracts/w4').list(recursive: true)) {
    if (entity is! File ||
        !RegExp(
          r'\.(json|md|ya?ml)$',
          caseSensitive: false,
        ).hasMatch(entity.path)) {
      continue;
    }
    if ((await entity.readAsBytes()).contains(13)) {
      failures.add(
        'Contract text must use canonical LF only: '
        '${entity.path.replaceAll('\\', '/')}',
      );
    }
  }
}

Map<String, Object?> _readObject(String name, List<String> failures) {
  try {
    final value = jsonDecode(
      File('$_contractDirectory/$name').readAsStringSync(),
    );
    if (value is Map<String, Object?>) return value;
  } on FormatException {
    // Report one stable failure below.
  }
  failures.add('$name must contain a valid JSON object.');
  return const {};
}

void _verifyManifest(
  Map<String, Object?> manifest,
  Map<String, String> checksums,
  List<String> failures,
) {
  void require(bool condition, String message) {
    if (!condition) failures.add(message);
  }

  require(
    manifest['contractVersion'] == 'waflo-m2-mobile-contract-v1',
    'Unexpected contract version.',
  );
  require(
    manifest['generatorVersion'] == 'waflo-m2-contract-generator-v1',
    'Unexpected generator version.',
  );
  require(
    manifest['backendCommitSha'] == _backendCommit,
    'Backend SHA mismatch.',
  );
  require(manifest['parentCommitSha'] == _parentCommit, 'Parent SHA mismatch.');
  require(manifest['bundleSha256'] == _bundleChecksum, 'Bundle SHA mismatch.');
  final reconstruction = manifest['reconstruction'];
  require(
    reconstruction is Map<String, Object?> &&
        reconstruction['classification'] ==
            'PARTIAL_W4_RECOVERY_WITH_M2_COMPATIBILITY_RECONSTRUCTION' &&
        reconstruction['historicalM2CommitRecovered'] == false,
    'Reconstruction provenance mismatch.',
  );
  final migrations = manifest['migrations'];
  require(
    migrations is Map<String, Object?> &&
        migrations['migrationCount'] == 24 &&
        migrations['migrationAddedForM2'] == false,
    'Migration provenance mismatch.',
  );
  final safety = manifest['safety'];
  require(
    safety is Map<String, Object?> &&
        safety['containsValidQrCredential'] == false &&
        safety['containsAccessToken'] == false &&
        safety['containsPrivateKey'] == false &&
        safety['containsSigningSecret'] == false &&
        safety['containsCustomerEmailOrPhone'] == false &&
        safety['fixturesAreSynthetic'] == true,
    'Bundle safety declarations are not satisfied.',
  );

  final generatedValue = manifest['generatedFiles'];
  if (generatedValue is! Map<String, Object?> || generatedValue.length != 12) {
    failures.add('Manifest generated-file inventory must contain 12 files.');
    return;
  }
  final generated = <String, String>{};
  for (final entry in generatedValue.entries) {
    if (entry.value is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(entry.value! as String)) {
      failures.add('Malformed manifest hash: ${entry.key}');
      continue;
    }
    generated[entry.key] = entry.value! as String;
    if (checksums[entry.key] != entry.value) {
      failures.add('Manifest/checksum inventory mismatch: ${entry.key}');
    }
  }
  final entries = generated.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  final aggregate = sha256
      .convert(
        utf8.encode(
          entries.map((entry) => '${entry.key}:${entry.value}').join('\n'),
        ),
      )
      .toString();
  require(aggregate == _bundleChecksum, 'Recomputed bundle SHA mismatch.');
}

void _verifySchema(List<String> failures) {
  final schema = _readObject('m2.schema.json', failures);
  final definitions = schema[r'$defs'];
  final currency = definitions is Map<String, Object?>
      ? definitions['PurchaseCurrency']
      : null;
  if (currency is! Map<String, Object?> ||
      currency['type'] != 'string' ||
      currency['minLength'] != 3 ||
      currency['maxLength'] != 3 ||
      currency['pattern'] != r'^[A-Za-z]{3}$') {
    failures.add('PurchaseCurrency schema is not the approved strict string.');
  }
  final command = definitions is Map<String, Object?>
      ? definitions['OperationCommandStatusResult']
      : null;
  final properties = command is Map<String, Object?>
      ? command['properties']
      : null;
  final status = properties is Map<String, Object?>
      ? properties['status']
      : null;
  final values = status is Map<String, Object?> ? status['enum'] : null;
  if (values is! List<Object?> ||
      values.toSet().difference(const {
        'PROCESSING',
        'COMPLETED',
        'FAILED',
      }).isNotEmpty ||
      const {
        'PROCESSING',
        'COMPLETED',
        'FAILED',
      }.difference(values.toSet()).isNotEmpty) {
    failures.add(
      'Command status enum does not match the approved three states.',
    );
  }
  final errors = jsonDecode(
    File('$_contractDirectory/stable-error-codes.m2.json').readAsStringSync(),
  );
  final codes = errors is Map<String, Object?> ? errors['codes'] : null;
  if (codes is! List<Object?> ||
      !codes.contains('STAFF_APP_VERSION_UNSUPPORTED')) {
    failures.add(
      'Stable error catalog is missing STAFF_APP_VERSION_UNSUPPORTED.',
    );
  }
}
