import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';

void main() {
  test('maps every Production-v1 approval machine code explicitly', () {
    const expected = {
      'MANAGER_APPROVAL_REQUIRED': ManagerApprovalState.required,
      'MANAGER_APPROVAL_PENDING': ManagerApprovalState.pending,
      'MANAGER_APPROVAL_REJECTED': ManagerApprovalState.rejected,
      'MANAGER_APPROVAL_EXPIRED': ManagerApprovalState.expired,
      'MANAGER_APPROVAL_CONSUMED': ManagerApprovalState.consumed,
      'MANAGER_APPROVAL_MISMATCH': ManagerApprovalState.mismatch,
      'MANAGER_APPROVAL_INVALID': ManagerApprovalState.invalid,
      'MANAGER_APPROVAL_NOT_APPLICABLE': ManagerApprovalState.notApplicable,
      'MANAGER_APPROVAL_ALREADY_DECIDED': ManagerApprovalState.alreadyDecided,
      'MANAGER_APPROVAL_STALE': ManagerApprovalState.stale,
      'MANAGER_APPROVAL_APPROVER_INACTIVE':
          ManagerApprovalState.approverInactive,
    };
    for (final entry in expected.entries) {
      expect(ManagerApprovalState.fromMachineCode(entry.key), entry.value);
    }
    expect(ManagerApprovalState.fromMachineCode('UNKNOWN'), isNull);
  });

  test('accepts only the exact safe approval response shape', () {
    const failure = ApiFailure(
      'MANAGER_APPROVAL_REQUIRED',
      httpStatus: 409,
      details: {
        'approvalRequest': {
          'publicId': '70000000-0000-4000-8000-000000000001',
          'status': 'PENDING',
          'expiresAt': '2030-08-11T21:00:00.000Z',
        },
        'operationType': 'REDEEM',
        'retryWithSameIdempotencyKey': true,
      },
    );
    final parsed = ManagerApprovalRequestData.fromFailure(failure);
    expect(parsed.status, 'PENDING');
    expect(parsed.expiresAt.isUtc, isTrue);
    expect(
      () => ManagerApprovalRequestData.fromFailure(
        const ApiFailure(
          'MANAGER_APPROVAL_REQUIRED',
          details: {
            'approvalRequest': {
              'publicId': 'not-a-uuid',
              'status': 'PENDING',
              'expiresAt': '2030-08-11T21:00:00.000Z',
            },
            'operationType': 'REDEEM',
            'retryWithSameIdempotencyKey': true,
          },
        ),
      ),
      throwsFormatException,
    );
  });

  test(
    'approval intent is stored only in the secure store and redacts itself',
    () async {
      final secure = MemorySecureKeyValueStore();
      final store = SecureManagerApprovalIntentStore(secure);
      final intent = ManagerApprovalIntent(
        commandId: '20000000-0000-4000-8000-000000000001',
        membershipPublicId: 'mem_public_fixture',
        qrPayload: 'q' * 40,
        entitlementPublicId: '40000000-0000-4000-8000-000000000001',
        finalReward: true,
        note: 'Exact customer-confirmed intent',
        approvalPublicId: '70000000-0000-4000-8000-000000000001',
        expiresAt: DateTime.utc(2030, 8, 11, 21),
        createdAt: DateTime.utc(2026, 8, 11, 20, 55),
      );
      await store.write(intent);
      final restored = await store.read();
      expect(restored?.commandId, intent.commandId);
      expect(restored?.qrPayload, intent.qrPayload);
      expect(intent.toString(), isNot(contains(intent.qrPayload)));
      expect(intent.toString(), isNot(contains(intent.approvalPublicId)));
      await store.clear();
      expect(await store.read(), isNull);
    },
  );
}
