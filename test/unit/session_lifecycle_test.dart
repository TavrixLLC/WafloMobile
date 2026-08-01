import 'dart:async';

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

import '../support/fixtures.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('secure record serializes, validates, and preserves UTC values', () {
    final original = fixtureSession();
    final restored = StaffDeviceSession.fromJson(original.toJson());
    expect(restored.sessionId, original.sessionId);
    expect(restored.accessExpiresAt.isUtc, isTrue);
    expect(restored.toString(), isNot(contains(original.accessToken)));
  });

  test('corrupt secure session fails closed', () async {
    final repository = StaffDeviceSessionRepository(
      MemorySecureKeyValueStore({'staff_device.session.v1': '{"bad":true}'}),
    );
    expect(
      repository.read,
      throwsA(
        isA<LocalSecurityFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'LOCAL_SESSION_CORRUPT',
        ),
      ),
    );
  });

  test(
    'atomic replacement verifies write and reports persistence failure',
    () async {
      final store = MemorySecureKeyValueStore();
      final repository = StaffDeviceSessionRepository(store);
      final first = fixtureSession();
      await repository.replaceAtomically(first);
      expect((await repository.read())?.sessionId, first.sessionId);

      store.failWrites = true;
      expect(
        () => repository.replaceAtomically(
          fixtureSession(sessionId: '00000000-0000-4000-8000-000000000299'),
        ),
        throwsA(isA<SecurePersistenceFailure>()),
      );
      expect((await repository.read())?.sessionId, first.sessionId);
    },
  );

  test('concurrent refreshes use one in-flight backend request', () async {
    final harness = await _Harness.create();
    final barrier = Completer<void>();
    harness.api.refreshBarrier = barrier.future;

    final first = harness.manager.refreshSingleFlight();
    final second = harness.manager.refreshSingleFlight();
    await Future<void>.delayed(Duration.zero);
    expect(harness.api.refreshCalls, 1);
    barrier.complete();
    final results = await Future.wait([first, second]);
    expect(results[0].sessionId, results[1].sessionId);
    expect(harness.api.refreshCalls, 1);
  });

  test(
    'inactive refresh clears unusable session and requires recovery',
    () async {
      final harness = await _Harness.create();
      harness.api.failure = const ApiFailure(
        'STAFF_DEVICE_NOT_ACTIVE',
        httpStatus: 401,
      );
      await expectLater(
        harness.manager.refreshSingleFlight(),
        throwsA(isA<ApiFailure>()),
      );
      expect(await harness.sessionRepository.read(), isNull);
      expect(
        (await harness.lifecycleRepository.read())?.state,
        LocalLifecycleState.recoveryRequired,
      );
    },
  );

  test(
    'server rotation plus local replacement failure retains identity and requires recovery',
    () async {
      final store = _FailReplacementStore();
      final sessions = StaffDeviceSessionRepository(store);
      await sessions.replaceAtomically(fixtureSession());
      final identity = DeviceIdentityRepository(store);
      await identity.loadOrCreate();
      final lifecycle = LocalLifecycleRepository(store);
      final transactions = PairingTransactionRepository(store);
      final manager = SessionManager(
        sessions,
        _FakeSessionApi(),
        identity,
        PreferencesRepository(await SharedPreferences.getInstance()),
        lifecycleRepository: lifecycle,
        transactionRepository: transactions,
      );
      store.failSessionWrites = true;

      await expectLater(
        manager.refreshSingleFlight(),
        throwsA(isA<SecurePersistenceFailure>()),
      );

      expect(await sessions.read(), isNull);
      expect(await identity.load(), isNotNull);
      final marker = await lifecycle.read();
      expect(marker?.state, LocalLifecycleState.recoveryRequired);
      expect(marker?.reason, 'REFRESH_ROTATED_LOCAL_REPLACEMENT_FAILED');
    },
  );

  test('logout clears session, key, and cached context even offline', () async {
    final harness = await _Harness.create();
    await harness.identityRepository.loadOrCreate();
    harness.api.failure = const NetworkFailure();
    final result = await harness.manager.logout();
    expect(result.serverReached, isFalse);
    expect(await harness.sessionRepository.read(), isNull);
    expect(await harness.identityRepository.load(), isNull);
    expect(harness.preferencesRepository.readSafeContext(), isNull);
    expect(
      (await harness.lifecycleRepository.read())?.state,
      LocalLifecycleState.loggedOut,
    );
  });
}

final class _Harness {
  const _Harness({
    required this.manager,
    required this.api,
    required this.sessionRepository,
    required this.identityRepository,
    required this.preferencesRepository,
    required this.lifecycleRepository,
  });

  final SessionManager manager;
  final _FakeSessionApi api;
  final StaffDeviceSessionRepository sessionRepository;
  final DeviceIdentityRepository identityRepository;
  final PreferencesRepository preferencesRepository;
  final LocalLifecycleRepository lifecycleRepository;

  static Future<_Harness> create() async {
    final secureStore = MemorySecureKeyValueStore();
    final sessionRepository = StaffDeviceSessionRepository(secureStore);
    await sessionRepository.replaceAtomically(
      fixtureSession(expiresAt: DateTime.utc(2026)),
    );
    final identityRepository = DeviceIdentityRepository(secureStore);
    final transactionRepository = PairingTransactionRepository(secureStore);
    final lifecycleRepository = LocalLifecycleRepository(secureStore);
    final preferencesRepository = PreferencesRepository(
      await SharedPreferences.getInstance(),
    );
    final api = _FakeSessionApi();
    return _Harness(
      manager: SessionManager(
        sessionRepository,
        api,
        identityRepository,
        preferencesRepository,
        lifecycleRepository: lifecycleRepository,
        transactionRepository: transactionRepository,
        now: () => DateTime.utc(2026, DateTime.july, 30),
      ),
      api: api,
      sessionRepository: sessionRepository,
      identityRepository: identityRepository,
      preferencesRepository: preferencesRepository,
      lifecycleRepository: lifecycleRepository,
    );
  }
}

final class _FakeSessionApi implements DeviceSessionApi {
  int refreshCalls = 0;
  Future<void>? refreshBarrier;
  AppFailure? failure;

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async {
    final problem = failure;
    if (problem != null) {
      throw problem;
    }
    return fixtureContext();
  }

  @override
  Future<void> logout(StaffDeviceSession current) async {
    final problem = failure;
    if (problem != null) {
      throw problem;
    }
  }

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async {
    refreshCalls += 1;
    final barrier = refreshBarrier;
    if (barrier != null) {
      await barrier;
    }
    final problem = failure;
    if (problem != null) {
      throw problem;
    }
    return fixtureSession(sessionId: '00000000-0000-4000-8000-000000000298');
  }
}

final class _FailReplacementStore implements SecureKeyValueStore {
  final MemorySecureKeyValueStore _delegate = MemorySecureKeyValueStore();
  bool failSessionWrites = false;

  @override
  Future<void> delete(String key) => _delegate.delete(key);

  @override
  Future<String?> read(String key) => _delegate.read(key);

  @override
  Future<void> write(String key, String value) {
    if (failSessionWrites && key == 'staff_device.session.v1') {
      throw StateError('Simulated rotated-session write failure.');
    }
    return _delegate.write(key, value);
  }
}
