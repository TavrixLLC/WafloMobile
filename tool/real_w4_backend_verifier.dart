import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const historicalRealW4BackendSha = '0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e';
const pairingRepairBackendSha = 'dbd20acafc3d7687866256e8e950a5b978ba4e29';
const requestCorrelationRepairBackendSha =
    '79a5ff7b224fbd0a1cf76a4d5eeb4e697b023435';
const repairedRealW4BackendSha = '966454633519bff3d9aed277ce0bcf36f17d3d60';
const _historicalBundleSha =
    '3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae';
const _repairClassifications = <String>{
  'BACKEND_RUNTIME_OMISSION',
  'BACKEND_RUNTIME_VALUE_MISMATCH',
  'BACKEND_ERROR_MAPPING_MISMATCH',
};
const _repairManifestPath = 'contracts/w4/m2/runtime-conformance-repair.json';

Future<String> verifyApprovedRealW4Backend({
  required Directory mobileRoot,
  required Directory backendRoot,
  required String outputLabel,
}) async {
  if (!backendRoot.existsSync()) {
    _fail('Approved W4 checkout does not exist.');
  }

  final head = await _git(backendRoot, ['rev-parse', 'HEAD']);
  if (head != repairedRealW4BackendSha) {
    _fail(
      'Approved W4 checkout is not at runtime-conformance repair '
      '$repairedRealW4BackendSha.',
    );
  }
  final repairCommits = (await _git(backendRoot, [
    'rev-list',
    '--reverse',
    '$historicalRealW4BackendSha..$repairedRealW4BackendSha',
  ])).split(RegExp(r'[\r\n]+')).where((sha) => sha.isNotEmpty).toList();
  const expectedRepairCommits = <String>[
    pairingRepairBackendSha,
    requestCorrelationRepairBackendSha,
    repairedRealW4BackendSha,
  ];
  if (!_sameList(repairCommits, expectedRepairCommits)) {
    _fail(
      'Approved W4 runtime repair is not the verified commit chain from '
      '$historicalRealW4BackendSha.',
    );
  }
  final trackedStatus = await _git(backendRoot, [
    'status',
    '--porcelain',
    '--untracked-files=no',
  ]);
  if (trackedStatus.isNotEmpty) {
    _fail('Approved W4 checkout has tracked working-tree changes.');
  }

  final historicalManifest = await _readObject(
    File(_join(mobileRoot.path, 'contracts/w4/m2/source-manifest.json')),
    'The authoritative historical M2 source manifest is invalid.',
  );
  if (historicalManifest['backendCommitSha'] != historicalRealW4BackendSha ||
      historicalManifest['bundleSha256'] != _historicalBundleSha ||
      historicalManifest['sourceFiles'] is! Map<String, Object?>) {
    _fail('The authoritative historical M2 source manifest is invalid.');
  }

  final repairManifest = await _readObject(
    File(_join(mobileRoot.path, _repairManifestPath)),
    'The M2 runtime-conformance repair manifest is invalid.',
  );
  final repairSources = repairManifest['changedSourceFiles'];
  final pairingRepair = repairManifest['pairingChallenge'];
  final manifestClassifications = repairManifest['classifications'];
  final manifestRepairCommits = repairManifest['repairCommitShas'];
  if (repairManifest['version'] != 'waflo-m2-runtime-conformance-repair-v2' ||
      manifestClassifications is! List<Object?> ||
      manifestClassifications
          .toSet()
          .difference(_repairClassifications)
          .isNotEmpty ||
      _repairClassifications
          .difference(manifestClassifications.toSet())
          .isNotEmpty ||
      manifestRepairCommits is! List<Object?> ||
      !_sameList(manifestRepairCommits, expectedRepairCommits) ||
      repairManifest['contractVersion'] !=
          historicalManifest['contractVersion'] ||
      repairManifest['historicalBundleSha256'] != _historicalBundleSha ||
      repairManifest['historicalBackendCommitSha'] !=
          historicalRealW4BackendSha ||
      repairManifest['repairBackendCommitSha'] != repairedRealW4BackendSha ||
      repairManifest['contractSchemaChanged'] != false ||
      repairManifest['contractVersionChanged'] != false ||
      repairSources is! Map<String, Object?> ||
      pairingRepair is! Map<String, Object?> ||
      pairingRepair['field'] != 'signatureAlgorithm' ||
      pairingRepair['required'] != true ||
      pairingRepair['canonicalValue'] != 'Ed25519') {
    _fail('The M2 runtime-conformance repair manifest is invalid.');
  }
  await _verifyHistoricalPairingContract(mobileRoot);

  const expectedChanges = <String>{
    'apps/api/src/security/guards.ts',
    'apps/api/src/staff-devices/staff-device.service.ts',
    'packages/staff-device-security/src/index.ts',
    'tests/http/w4-staff-operations.test.ts',
  };
  if (repairSources.keys.toSet().difference(expectedChanges).isNotEmpty ||
      expectedChanges.difference(repairSources.keys.toSet()).isNotEmpty ||
      repairSources.values.any((value) => value is! String)) {
    _fail('The M2 runtime-conformance repair file set is invalid.');
  }
  final changedPaths = (await _git(backendRoot, [
    'diff',
    '--name-only',
    '$historicalRealW4BackendSha..$repairedRealW4BackendSha',
  ])).split(RegExp(r'[\r\n]+')).where((path) => path.isNotEmpty).toSet();
  if (changedPaths.difference(expectedChanges).isNotEmpty ||
      expectedChanges.difference(changedPaths).isNotEmpty) {
    _fail('The approved W4 runtime repair contains unexpected source paths.');
  }

  final historicalSources =
      historicalManifest['sourceFiles']! as Map<String, Object?>;
  final mismatches = <String>[];
  for (final entry in historicalSources.entries) {
    final historicalHash = entry.value;
    if (historicalHash is! String) {
      _fail('The historical M2 source manifest contains an invalid entry.');
    }
    final source = File(_join(backendRoot.path, entry.key));
    if (!source.existsSync()) {
      mismatches.add('${entry.key} (missing)');
      continue;
    }
    final expectedHash = repairSources[entry.key] ?? historicalHash;
    final actualHash = sha256.convert(await source.readAsBytes()).toString();
    if (actualHash != expectedHash) {
      mismatches.add('${entry.key} (checksum)');
    }
  }
  if (mismatches.isNotEmpty) {
    _fail(
      'Approved W4 runtime-conformance source verification failed: '
      '${mismatches.join(', ')}',
    );
  }
  stdout.writeln(
    '$outputLabel verified: repair=$repairedRealW4BackendSha '
    'base=$historicalRealW4BackendSha files=${historicalSources.length} '
    'changed=${repairSources.length}.',
  );
  return repairedRealW4BackendSha;
}

bool _sameList(List<Object?> actual, List<String> expected) {
  if (actual.length != expected.length) return false;
  for (var index = 0; index < expected.length; index++) {
    if (actual[index] != expected[index]) return false;
  }
  return true;
}

Future<Map<String, Object?>> _readObject(File file, String failure) async {
  if (!file.existsSync()) _fail(failure);
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map<String, Object?>) _fail(failure);
  return decoded;
}

Future<void> _verifyHistoricalPairingContract(Directory mobileRoot) async {
  final openApi = await _readObject(
    File(_join(mobileRoot.path, 'contracts/w4/openapi.m1.json')),
    'The authoritative M1 pairing contract is invalid.',
  );
  final components = openApi['components'];
  final schemas = components is Map<String, Object?>
      ? components['schemas']
      : null;
  final response = schemas is Map<String, Object?>
      ? schemas['DevicePairingRecoveryResponse']
      : null;
  final properties = response is Map<String, Object?>
      ? response['properties']
      : null;
  final algorithm = properties is Map<String, Object?>
      ? properties['signatureAlgorithm']
      : null;
  final required = response is Map<String, Object?>
      ? response['required']
      : null;
  if (algorithm is! Map<String, Object?> ||
      algorithm['const'] != 'Ed25519' ||
      required is! List<Object?> ||
      !required.contains('signatureAlgorithm')) {
    _fail('The authoritative M1 pairing contract is invalid.');
  }
}

Future<String> _git(Directory root, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: root.path,
    runInShell: Platform.isWindows,
  );
  if (result.exitCode != 0) {
    _fail('Unable to verify the approved W4 Git source.');
  }
  return (result.stdout as String).trim();
}

String _join(String root, String relative) =>
    '$root${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
