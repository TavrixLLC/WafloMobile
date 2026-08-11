import 'dart:convert';
import 'dart:io';

const _backendSha = '763f2dfccdb24fb9bfa16457f0e49936840e20a1';
const _documentationCommit = '06067d454077cdedf827f93ed0ced72d0e2e133d';
const _historicalM2Bundle =
    '3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae';

void main() {
  final authority = _json('contracts/production-v1/mobile-authority.json');
  _expect(
    authority['authorityKind'] == 'CURRENT_PRODUCTION_V1_MOBILE_INTEGRATION',
    'Production-v1 authority kind is invalid.',
  );
  _expect(
    authority['backendSha'] == _backendSha,
    'Production-v1 Backend authority SHA drifted.',
  );
  _expect(
    authority['documentationCommit'] == _documentationCommit,
    'Production-v1 documentation authority drifted.',
  );
  _expect(
    authority['historicalM2BundleSha256'] == _historicalM2Bundle,
    'Historical M2 bundle pointer drifted.',
  );

  final inventory = authority['routeInventory'] as Map<String, Object?>;
  _expect(inventory['total'] == 178, 'Production-v1 route total drifted.');
  _expect(
    inventory['directMobileRequired'] == 9,
    'Required Mobile route count drifted.',
  );
  _expect(
    inventory['directMobileOptional'] == 4,
    'Optional Mobile route count drifted.',
  );
  _expect(
    inventory['mobileSupporting'] == 12,
    'Mobile-supporting route count drifted.',
  );
  _expect(
    inventory['notForMobile'] == 153,
    'Not-for-Mobile route count drifted.',
  );

  final required = (authority['directMobileRequired'] as List<Object?>)
      .cast<String>()
      .toSet();
  _expect(required.length == 9, 'Required Mobile routes are not unique.');
  _expect(
    required.contains('POST /v1/staff/operations/redeem'),
    'Signed redeem route is missing.',
  );
  _expect(
    required.contains('GET /v1/staff/operations/commands/:commandId'),
    'Command recovery route is missing.',
  );

  final approvalCodes = (authority['managerApprovalCodes'] as List<Object?>)
      .cast<String>();
  _expect(
    approvalCodes.length == 11 && approvalCodes.toSet().length == 11,
    'Manager approval state machine is incomplete.',
  );

  final api = File(
    'lib/features/membership_resolution/data/loyalty_operations_api.dart',
  ).readAsStringSync();
  final stampStart = api.indexOf('Future<StampOperationResult> issueStamps');
  final redeemStart = api.indexOf(
    'Future<RedemptionOperationResult> redeemReward',
  );
  _expect(
    stampStart >= 0 && redeemStart > stampStart,
    'Loyalty API method boundaries are missing.',
  );
  final stampSource = api.substring(stampStart, redeemStart);
  _expect(
    !stampSource.contains('managerOverride'),
    'MOB-001 failed: stamp may serialize managerOverride.',
  );
  _expect(
    api.contains("'managerApprovalPublicId'"),
    'Redeem approval retry field is missing.',
  );

  final currentSource = _currentDartSource();
  final legacyThresholdHits = <String>[];
  for (final file in _currentDartFiles()) {
    if (file.readAsStringSync().contains('PURCHASE_AMOUNT_BELOW_MINIMUM')) {
      legacyThresholdHits.add(file.path.replaceAll('\\', '/'));
    }
  }
  _expect(
    legacyThresholdHits.length == 1 &&
        legacyThresholdHits.single.endsWith(
          '/core/localization/localization_extensions.dart',
        ) &&
        File(legacyThresholdHits.single).readAsStringSync().contains(
          'Historical M2 evidence still exercises this retired wire code.',
        ),
    'MOB-002 failed: retired threshold code escaped its isolated M2 '
    'compatibility mapping.',
  );
  _expect(
    currentSource.contains('PURCHASE_THRESHOLD_NOT_MET'),
    'MOB-002 failed: current threshold code is missing.',
  );
  _expect(
    currentSource.contains('OPERATION_BILLING_BLOCKED'),
    'MOB-003 failed: billing denial is not handled.',
  );
  for (final code in approvalCodes) {
    _expect(
      currentSource.contains(code),
      'Manager approval code is not handled: $code',
    );
  }
  for (final code in const [
    'STAFF_USER_DEACTIVATED',
    'STAFF_MEMBERSHIP_INACTIVE',
    'STAFF_DEVICE_REVOKED',
    'STAFF_LOCATION_ASSIGNMENT_INVALID',
  ]) {
    _expect(
      currentSource.contains(code),
      'Authority loss is not handled: $code',
    );
  }
  for (final forbidden in const [
    '/location-assignments',
    '/manager-approval-requests',
    'merchantCookie',
  ]) {
    _expect(
      !currentSource.contains(forbidden),
      'Forbidden Merchant-Web dependency found: $forbidden',
    );
  }

  stdout.writeln(
    'Production-v1 Mobile authority verified: Backend $_backendSha; '
    '9 required + 4 optional direct routes; historical M2 unchanged.',
  );
}

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

String _currentDartSource() {
  final buffer = StringBuffer();
  for (final file in _currentDartFiles()) {
    buffer.writeln(file.readAsStringSync());
  }
  return buffer.toString();
}

Iterable<File> _currentDartFiles() sync* {
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final normalized = entity.path.replaceAll('\\', '/');
    if (normalized.contains('/generated_m2/')) continue;
    yield entity;
  }
}

void _expect(bool condition, String message) {
  if (!condition) throw StateError(message);
}
