import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

import '../support/fixtures.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('lost claim response immediately attempts challenge recovery', () async {
    final store = MemorySecureKeyValueStore();
    final api = _RecoveryPairingApi(claimResponseLost: true);
    final harness = await _Harness.create(store: store, pairingApi: api);

    final result = await harness.service.pair(
      _fixtureToken(),
      onProgress: (_) {},
    );

    expect(result.context.device.publicId, fixtureSession().devicePublicId);
    expect(api.claimCalls, 1);
    expect(api.challengeCalls, 1);
    expect(api.completeCalls, 1);
    expect(await harness.transactions.read(), isNull);
    expect((await harness.lifecycle.read())?.state, LocalLifecycleState.paired);
  });

  test(
    'claim-pending transaction survives restart without QR secret',
    () async {
      final store = MemorySecureKeyValueStore();
      final firstApi = _RecoveryPairingApi(
        claimResponseLost: true,
        challengeOffline: true,
      );
      final first = await _Harness.create(store: store, pairingApi: firstApi);

      await expectLater(
        first.service.pair(_fixtureToken(), onProgress: (_) {}),
        throwsA(isA<NetworkFailure>()),
      );
      final transaction = await first.transactions.read();
      expect(transaction?.stage, PairingTransactionStage.claimPending);
      final serialized = store.snapshot['pairing.transaction.v2']!;
      expect(serialized, isNot(contains('pairingToken')));
      expect(serialized, isNot(contains(_fixtureToken())));

      final identity = await first.identity.load();
      final secondApi = _RecoveryPairingApi(
        installationId: identity!.installationId,
      );
      final restarted = await _Harness.create(
        store: store,
        pairingApi: secondApi,
      );
      final result = await restarted.service.resume(onProgress: (_) {});

      expect(result.context.device.status, 'ACTIVE');
      expect(secondApi.claimCalls, 0);
      expect(secondApi.challengeCalls, 1);
      expect(secondApi.completeCalls, 1);
    },
  );

  test(
    'restart in signing revalidates challenge and reuses signature',
    () async {
      final store = MemorySecureKeyValueStore();
      final harness = await _Harness.create(
        store: store,
        pairingApi: _RecoveryPairingApi(),
      );
      final identity = await harness.identity.loadOrCreate();
      const pairingPublicId = '00000000-0000-4000-8000-000000000100';
      const challenge = 'fixture-challenge-value-with-at-least-32-characters';
      final message = [
        'waflo-pair-challenge-v1',
        pairingPublicId,
        challenge,
        identity.installationId,
      ].join('\n');
      final signature = await harness.identity.signUtf8(message);
      await harness.transactions.mark(
        pairingPublicId: pairingPublicId,
        stage: PairingTransactionStage.signing,
        challenge: challenge,
        challengeExpiresAt: DateTime.utc(2026, DateTime.august, 1, 13),
        message: message,
        signature: signature,
      );
      final api = _RecoveryPairingApi(installationId: identity.installationId);
      final restarted = await _Harness.create(store: store, pairingApi: api);

      await restarted.service.resume(onProgress: (_) {});

      expect(api.challengeCalls, 1);
      expect(api.completedSignature, signature);
    },
  );

  test(
    'expired recovered challenge is conclusive and routes expired',
    () async {
      final store = MemorySecureKeyValueStore();
      final identity = await DeviceIdentityRepository(store).loadOrCreate();
      final transactions = PairingTransactionRepository(store);
      await transactions.mark(
        pairingPublicId: '00000000-0000-4000-8000-000000000100',
        stage: PairingTransactionStage.claimPending,
      );
      final harness = await _Harness.create(
        store: store,
        pairingApi: _RecoveryPairingApi(
          installationId: identity.installationId,
          challengeExpired: true,
        ),
      );

      await expectLater(
        harness.service.resume(onProgress: (_) {}),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.safeCode,
            'safeCode',
            'DEVICE_PAIRING_EXPIRED',
          ),
        ),
      );

      expect(await transactions.read(), isNull);
      expect(await harness.identity.load(), isNull);
      expect(
        (await harness.lifecycle.read())?.state,
        LocalLifecycleState.neverPaired,
      );
    },
  );
}

final class _Harness {
  const _Harness({
    required this.service,
    required this.identity,
    required this.transactions,
    required this.lifecycle,
  });

  final PairingFlowService service;
  final DeviceIdentityRepository identity;
  final PairingTransactionRepository transactions;
  final LocalLifecycleRepository lifecycle;

  static Future<_Harness> create({
    required MemorySecureKeyValueStore store,
    required _RecoveryPairingApi pairingApi,
  }) async {
    final identity = DeviceIdentityRepository(store);
    final sessions = StaffDeviceSessionRepository(store);
    final transactions = PairingTransactionRepository(
      store,
      now: () => DateTime.utc(2026, DateTime.august, 1, 12),
    );
    final lifecycle = LocalLifecycleRepository(
      store,
      now: () => DateTime.utc(2026, DateTime.august, 1, 12),
    );
    final manager = SessionManager(
      sessions,
      const _SessionApi(),
      identity,
      PreferencesRepository(await SharedPreferences.getInstance()),
      lifecycleRepository: lifecycle,
      transactionRepository: transactions,
      now: () => DateTime.utc(2026, DateTime.august, 1, 12),
    );
    return _Harness(
      service: PairingFlowService(
        const PairingQrParser(expectedEnvironment: 'test'),
        identity,
        pairingApi,
        const _Metadata(),
        sessions,
        transactions,
        lifecycle,
        manager,
        now: () => DateTime.utc(2026, DateTime.august, 1, 12),
      ),
      identity: identity,
      transactions: transactions,
      lifecycle: lifecycle,
    );
  }
}

final class _RecoveryPairingApi implements PairingApi {
  _RecoveryPairingApi({
    this.installationId,
    this.claimResponseLost = false,
    this.challengeOffline = false,
    this.challengeExpired = false,
  });

  String? installationId;
  final bool claimResponseLost;
  final bool challengeOffline;
  final bool challengeExpired;
  int claimCalls = 0;
  int challengeCalls = 0;
  int completeCalls = 0;
  String? completedSignature;

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) async {
    claimCalls += 1;
    installationId = command.installationId;
    if (claimResponseLost) {
      throw const NetworkFailure();
    }
    final recovered = await _challengeData(
      '00000000-0000-4000-8000-000000000100',
    );
    return PairingClaimResult(
      pairingPublicId: recovered.pairingPublicId,
      challenge: recovered.challenge,
      challengeExpiresAt: recovered.challengeExpiresAt,
      signatureAlgorithm: recovered.signatureAlgorithm,
      message: recovered.message,
    );
  }

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) async {
    challengeCalls += 1;
    if (challengeOffline) {
      throw const NetworkFailure();
    }
    return _challengeData(pairingPublicId);
  }

  Future<PairingChallengeResult> _challengeData(String pairingPublicId) async {
    final localInstallationId = installationId;
    if (localInstallationId == null) {
      throw StateError('Fixture installation ID missing.');
    }
    const challenge = 'fixture-challenge-value-with-at-least-32-characters';
    return PairingChallengeResult(
      pairingPublicId: pairingPublicId,
      challenge: challenge,
      challengeExpiresAt: challengeExpired
          ? DateTime.utc(2026, DateTime.august, 1, 11)
          : DateTime.utc(2026, DateTime.august, 1, 13),
      signatureAlgorithm: 'Ed25519',
      message: [
        'waflo-pair-challenge-v1',
        pairingPublicId,
        challenge,
        localInstallationId,
      ].join('\n'),
    );
  }

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async {
    completeCalls += 1;
    completedSignature = command.signature;
    return fixtureSession();
  }
}

final class _SessionApi implements DeviceSessionApi {
  const _SessionApi();

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async => fixtureContext();

  @override
  Future<void> logout(StaffDeviceSession current) async {}

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async =>
      fixtureSession();
}

final class _Metadata implements DeviceMetadataProvider {
  const _Metadata();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0',
  );
}

String _fixtureToken() {
  final root =
      jsonDecode(
            File('contracts/w4/deterministic-fixtures.json').readAsStringSync(),
          )
          as Map<String, Object?>;
  return (root['pairingQrShape']! as Map<String, Object?>)['token']! as String;
}
