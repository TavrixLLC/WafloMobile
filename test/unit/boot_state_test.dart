import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';

import '../support/fixtures.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final testCase in [
    ('REVOKED', BootStage.deviceRevoked),
    ('COMPROMISED', BootStage.deviceCompromised),
  ]) {
    test('boot maps persisted ${testCase.$1} device status', () async {
      SharedPreferences.setMockInitialValues({});
      final store = MemorySecureKeyValueStore();
      await DeviceIdentityRepository(store).loadOrCreate();
      await StaffDeviceSessionRepository(
        store,
      ).replaceAtomically(fixtureSession(deviceStatus: testCase.$1));
      final container = ProviderContainer(
        overrides: [
          secureStoreProvider.overrideWithValue(store),
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
          environmentProvider.overrideWithValue(_environment),
        ],
      );
      addTearDown(container.dispose);
      await container.read(bootControllerProvider.notifier).initialize();
      expect(container.read(bootControllerProvider).stage, testCase.$2);
    });
  }

  for (final testCase in const [
    ('STAFF_USER_DEACTIVATED', BootStage.staffUserDeactivated),
    ('STAFF_MEMBERSHIP_INACTIVE', BootStage.staffMembershipInactive),
    ('STAFF_DEVICE_REVOKED', BootStage.deviceRevoked),
    (
      'STAFF_LOCATION_ASSIGNMENT_INVALID',
      BootStage.staffLocationAssignmentInvalid,
    ),
  ]) {
    test('current authority loss maps ${testCase.$1} distinctly', () async {
      final store = MemorySecureKeyValueStore();
      await DeviceIdentityRepository(store).loadOrCreate();
      await StaffDeviceSessionRepository(
        store,
      ).replaceAtomically(fixtureSession());
      await LocalLifecycleRepository(store).mark(LocalLifecycleState.paired);
      final container = await _container(
        store,
        sessionApi: _FailingBootSessionApi(testCase.$1),
      );
      addTearDown(container.dispose);

      await container.read(bootControllerProvider.notifier).initialize();

      expect(container.read(bootControllerProvider).stage, testCase.$2);
      expect(await StaffDeviceSessionRepository(store).read(), isNull);
      expect(
        (await LocalLifecycleRepository(store).read())?.reason,
        testCase.$1,
      );
    });
  }

  test('fresh install records never-paired and routes unpaired', () async {
    final store = MemorySecureKeyValueStore();
    final container = await _container(store);
    addTearDown(container.dispose);

    await container.read(bootControllerProvider.notifier).initialize();

    expect(container.read(bootControllerProvider).stage, BootStage.unpaired);
    expect(
      (await LocalLifecycleRepository(store).read())?.state,
      LocalLifecycleState.neverPaired,
    );
  });

  test('paired marker with identity but no session fails closed', () async {
    final store = MemorySecureKeyValueStore();
    await DeviceIdentityRepository(store).loadOrCreate();
    await LocalLifecycleRepository(store).mark(LocalLifecycleState.paired);
    final container = await _container(store);
    addTearDown(container.dispose);

    await container.read(bootControllerProvider.notifier).initialize();

    expect(
      container.read(bootControllerProvider).stage,
      BootStage.fatalLocalSecurityError,
    );
  });

  test('session without identity fails closed and records recovery', () async {
    final store = MemorySecureKeyValueStore();
    await StaffDeviceSessionRepository(
      store,
    ).replaceAtomically(fixtureSession());
    final container = await _container(store);
    addTearDown(container.dispose);

    await container.read(bootControllerProvider.notifier).initialize();

    expect(
      container.read(bootControllerProvider).stage,
      BootStage.fatalLocalSecurityError,
    );
    expect(
      (await LocalLifecycleRepository(store).read())?.state,
      LocalLifecycleState.recoveryRequired,
    );
  });

  test(
    'persisting pairing ambiguity requires manager-assisted repair',
    () async {
      final store = MemorySecureKeyValueStore();
      await DeviceIdentityRepository(store).loadOrCreate();
      await PairingTransactionRepository(store).mark(
        pairingPublicId: '00000000-0000-4000-8000-000000000100',
        stage: PairingTransactionStage.persisting,
        challenge: 'fixture-challenge-value-with-at-least-32-characters',
        challengeExpiresAt: DateTime.utc(2030),
        message: 'safe fixture message',
        signature: 'fixture-signature-value-with-at-least-40-characters',
      );
      final container = await _container(store);
      addTearDown(container.dispose);

      await container.read(bootControllerProvider.notifier).initialize();

      expect(
        container.read(bootControllerProvider).stage,
        BootStage.fatalLocalSecurityError,
      );
      expect(await PairingTransactionRepository(store).read(), isNotNull);
    },
  );

  test('logged-out marker clears any stale identity and session', () async {
    final store = MemorySecureKeyValueStore();
    await DeviceIdentityRepository(store).loadOrCreate();
    await StaffDeviceSessionRepository(
      store,
    ).replaceAtomically(fixtureSession());
    await LocalLifecycleRepository(store).mark(LocalLifecycleState.loggedOut);
    final container = await _container(store);
    addTearDown(container.dispose);

    await container.read(bootControllerProvider.notifier).initialize();

    expect(container.read(bootControllerProvider).stage, BootStage.unpaired);
    expect(await DeviceIdentityRepository(store).load(), isNull);
    expect(await StaffDeviceSessionRepository(store).read(), isNull);
  });

  test('restart with recoverable claim resumes through challenge', () async {
    final store = MemorySecureKeyValueStore();
    final identity = await DeviceIdentityRepository(store).loadOrCreate();
    await PairingTransactionRepository(store).mark(
      pairingPublicId: '00000000-0000-4000-8000-000000000100',
      stage: PairingTransactionStage.claimPending,
    );
    await LocalLifecycleRepository(store).mark(LocalLifecycleState.pairing);
    final pairingApi = _BootPairingApi(identity.installationId);
    final container = await _container(store, pairingApi: pairingApi);
    addTearDown(container.dispose);

    await container.read(bootControllerProvider.notifier).initialize();

    expect(container.read(bootControllerProvider).stage, BootStage.pairedReady);
    expect(pairingApi.challengeCalls, 1);
    expect(await PairingTransactionRepository(store).read(), isNull);
  });
}

Future<ProviderContainer> _container(
  MemorySecureKeyValueStore store, {
  PairingApi? pairingApi,
  DeviceSessionApi sessionApi = const _BootSessionApi(),
}) async => ProviderContainer(
  overrides: [
    secureStoreProvider.overrideWithValue(store),
    sharedPreferencesProvider.overrideWithValue(
      await SharedPreferences.getInstance(),
    ),
    environmentProvider.overrideWithValue(_environment),
    deviceSessionApiProvider.overrideWithValue(sessionApi),
    if (pairingApi != null) pairingApiProvider.overrideWithValue(pairingApi),
  ],
);

final class _BootPairingApi implements PairingApi {
  _BootPairingApi(this.installationId);

  final String installationId;
  int challengeCalls = 0;

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) async {
    challengeCalls += 1;
    const challenge = 'fixture-challenge-value-with-at-least-32-characters';
    return PairingChallengeResult(
      pairingPublicId: pairingPublicId,
      challenge: challenge,
      challengeExpiresAt: DateTime.now().toUtc().add(
        const Duration(minutes: 5),
      ),
      signatureAlgorithm: 'Ed25519',
      message: [
        'waflo-pair-challenge-v1',
        pairingPublicId,
        challenge,
        installationId,
      ].join('\n'),
    );
  }

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) =>
      throw UnimplementedError();

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async =>
      fixtureSession();
}

final class _BootSessionApi implements DeviceSessionApi {
  const _BootSessionApi();

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

final class _FailingBootSessionApi implements DeviceSessionApi {
  const _FailingBootSessionApi(this.code);

  final String code;

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async => throw ApiFailure(code, httpStatus: 401);

  @override
  Future<void> logout(StaffDeviceSession current) async {}

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async =>
      throw ApiFailure(code, httpStatus: 401);
}

final _environment = AppEnvironment(
  flavor: AppFlavor.development,
  apiBaseUrl: Uri.parse('http://10.0.2.2:3000'),
  pairingEnvironment: 'development',
  logLevel: AppLogLevel.debug,
  allowTestAdapter: true,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
);
