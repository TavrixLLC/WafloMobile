import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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

import '../test/support/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('fresh install pairs, restarts, refreshes, and logs out', (
    tester,
  ) async {
    final store = MemorySecureKeyValueStore();
    final identity = DeviceIdentityRepository(store);
    final sessions = StaffDeviceSessionRepository(store);
    final transactions = PairingTransactionRepository(store);
    final lifecycle = LocalLifecycleRepository(store);
    final sessionApi = _IntegrationSessionApi();
    final manager = SessionManager(
      sessions,
      sessionApi,
      identity,
      PreferencesRepository(await SharedPreferences.getInstance()),
      lifecycleRepository: lifecycle,
      transactionRepository: transactions,
      now: () => DateTime.utc(2026, DateTime.july, 30),
    );
    final pairingApi = _IntegrationPairingApi();
    final service = PairingFlowService(
      const PairingQrParser(expectedEnvironment: 'test'),
      identity,
      pairingApi,
      const _MetadataProvider(),
      sessions,
      transactions,
      lifecycle,
      manager,
      now: () => DateTime.utc(2026, DateTime.july, 30),
    );
    final progress = <PairingProgress>[];

    expect(await sessions.read(), isNull);
    final result = await service.pair(
      _fixtureToken(),
      onProgress: progress.add,
    );
    expect(result.context.role, 'STAFF');
    expect(progress, [
      PairingProgress.validating,
      PairingProgress.creatingIdentity,
      PairingProgress.claiming,
      PairingProgress.signing,
      PairingProgress.completing,
      PairingProgress.saving,
      PairingProgress.loadingContext,
    ]);
    expect(pairingApi.completedSignature, isNotEmpty);
    expect(await transactions.readStage(), isNull);

    final restartedRepository = StaffDeviceSessionRepository(store);
    expect((await restartedRepository.read())?.deviceStatus, 'ACTIVE');
    final refreshed = await manager.refreshSingleFlight();
    expect(refreshed.sessionId, _IntegrationSessionApi.refreshedSessionId);

    sessionApi.contextFailure = const ApiFailure(
      'STAFF_DEVICE_NOT_ACTIVE',
      httpStatus: 401,
    );
    await expectLater(
      manager.loadContext(),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'STAFF_DEVICE_NOT_ACTIVE',
        ),
      ),
    );
    sessionApi.contextFailure = null;
    expect(await sessions.read(), isNull);
    await sessions.replaceAtomically(fixtureSession());
    await lifecycle.mark(LocalLifecycleState.paired);

    final logout = await manager.logout();
    expect(logout.serverReached, isTrue);
    expect(await sessions.read(), isNull);
    expect(await identity.load(), isNull);
  });

  testWidgets('network interruption during claim persists no session', (
    tester,
  ) async {
    final harness = await _FlowHarness.create(
      pairingFailure: const NetworkFailure(),
    );
    await expectLater(
      harness.service.pair(_fixtureToken(), onProgress: (_) {}),
      throwsA(isA<NetworkFailure>()),
    );
    expect(await harness.sessions.read(), isNull);
    expect(
      await harness.transactions.readStage(),
      PairingTransactionStage.claimPending,
    );
  });

  testWidgets('backend completion plus local write failure is fail closed', (
    tester,
  ) async {
    final store = _SelectiveFailureStore();
    final harness = await _FlowHarness.create(store: store);
    store.failSessionWrites = true;
    await expectLater(
      harness.service.pair(_fixtureToken(), onProgress: (_) {}),
      throwsA(isA<SecurePersistenceFailure>()),
    );
    expect(await harness.sessions.read(), isNull);
    expect(
      await harness.transactions.readStage(),
      PairingTransactionStage.persisting,
    );
  });
}

final class _FlowHarness {
  const _FlowHarness({
    required this.service,
    required this.sessions,
    required this.transactions,
  });

  final PairingFlowService service;
  final StaffDeviceSessionRepository sessions;
  final PairingTransactionRepository transactions;

  static Future<_FlowHarness> create({
    SecureKeyValueStore? store,
    AppFailure? pairingFailure,
  }) async {
    final resolvedStore = store ?? MemorySecureKeyValueStore();
    final identity = DeviceIdentityRepository(resolvedStore);
    final sessions = StaffDeviceSessionRepository(resolvedStore);
    final transactions = PairingTransactionRepository(resolvedStore);
    final lifecycle = LocalLifecycleRepository(resolvedStore);
    final manager = SessionManager(
      sessions,
      _IntegrationSessionApi(),
      identity,
      PreferencesRepository(await SharedPreferences.getInstance()),
      lifecycleRepository: lifecycle,
      transactionRepository: transactions,
    );
    return _FlowHarness(
      service: PairingFlowService(
        const PairingQrParser(expectedEnvironment: 'test'),
        identity,
        _IntegrationPairingApi(failure: pairingFailure),
        const _MetadataProvider(),
        sessions,
        transactions,
        lifecycle,
        manager,
        now: () => DateTime.utc(2026, DateTime.july, 30),
      ),
      sessions: sessions,
      transactions: transactions,
    );
  }
}

final class _IntegrationPairingApi implements PairingApi {
  _IntegrationPairingApi({this.failure});

  final AppFailure? failure;
  String? completedSignature;
  String? _installationId;

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) async {
    final problem = failure;
    if (problem != null) {
      throw problem;
    }
    final installationId = _installationId;
    if (installationId == null) {
      throw StateError('Fixture installation ID is unavailable.');
    }
    const challenge = 'fixture-challenge-value-with-at-least-32-characters';
    return PairingChallengeResult(
      pairingPublicId: pairingPublicId,
      challenge: challenge,
      challengeExpiresAt: DateTime.utc(2026, DateTime.july, 30, 12, 5),
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
  Future<PairingClaimResult> claim(PairingClaimCommand command) async {
    final problem = failure;
    if (problem != null) {
      throw problem;
    }
    _installationId = command.installationId;
    const pairingPublicId = '00000000-0000-4000-8000-000000000100';
    const challenge = 'fixture-challenge-value-with-at-least-32-characters';
    return PairingClaimResult(
      pairingPublicId: pairingPublicId,
      challenge: challenge,
      challengeExpiresAt: DateTime.utc(2026, DateTime.july, 30, 12, 5),
      signatureAlgorithm: 'Ed25519',
      message: [
        'waflo-pair-challenge-v1',
        pairingPublicId,
        challenge,
        command.installationId,
      ].join('\n'),
    );
  }

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async {
    if (_installationId == null) {
      throw StateError('Claim must precede completion.');
    }
    completedSignature = command.signature;
    return fixtureSession();
  }
}

final class _IntegrationSessionApi implements DeviceSessionApi {
  static const refreshedSessionId = '00000000-0000-4000-8000-000000000288';
  AppFailure? contextFailure;

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async {
    final problem = contextFailure;
    if (problem != null) {
      throw problem;
    }
    return fixtureContext();
  }

  @override
  Future<void> logout(StaffDeviceSession current) async {}

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async =>
      fixtureSession(sessionId: refreshedSessionId);
}

final class _MetadataProvider implements DeviceMetadataProvider {
  const _MetadataProvider();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0+1',
    osVersion: 'fixture-os',
    model: 'fixture-model',
  );
}

final class _SelectiveFailureStore implements SecureKeyValueStore {
  final MemorySecureKeyValueStore _delegate = MemorySecureKeyValueStore();
  bool failSessionWrites = false;

  @override
  Future<void> delete(String key) => _delegate.delete(key);

  @override
  Future<String?> read(String key) => _delegate.read(key);

  @override
  Future<void> write(String key, String value) {
    if (failSessionWrites && key == 'staff_device.session.v1') {
      throw StateError('Simulated secure session persistence failure.');
    }
    return _delegate.write(key, value);
  }
}

String _fixtureToken() {
  return 'waflo-pair-v1.'
      'MDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMTAw.'
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.'
      'dGVzdA';
}
