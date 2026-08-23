import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/review_access/domain/local_review_access.dart';

import '../support/fixtures.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Review credential is normalized, bounded, and domain-derived', () {
    expect(LocalReviewCodeFormat.normalize('w4fl 7rvw 9kqp'), _reviewCode());
    expect(LocalReviewCodeFormat.isValid(_reviewCode()), isTrue);
    for (final value in ['ABCD-2345', 'W4FL-7RVW-9KQ', 'W4FL-7RVW-10O1']) {
      expect(LocalReviewCodeFormat.isValid(value), isFalse, reason: value);
    }
    expect(
      sha256
          .convert(
            utf8.encode('waflo-local-review-access-v1\n${_reviewCode()}'),
          )
          .toString(),
      _reviewDigest,
    );
  });

  test('wrong attempts are persistently rate limited', () async {
    final preferences = await SharedPreferences.getInstance();
    var now = DateTime.utc(2026, 8, 22, 12);
    final access = LocalReviewAccess(
      preferences,
      expectedDigest: _reviewDigest,
      now: () => now,
    );

    for (var attempt = 0; attempt < 5; attempt += 1) {
      await expectLater(
        access.authorize(_wrongReviewCode()),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.safeCode,
            'safeCode',
            'REVIEW_ACCESS_INVALID',
          ),
        ),
      );
    }
    await expectLater(
      access.authorize(_reviewCode()),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'REVIEW_ACCESS_RATE_LIMITED',
        ),
      ),
    );

    final restarted = LocalReviewAccess(
      preferences,
      expectedDigest: _reviewDigest,
      now: () => now,
    );
    await expectLater(
      restarted.authorize(_reviewCode()),
      throwsA(isA<ApiFailure>()),
    );
    now = now.add(const Duration(minutes: 16));
    expect(
      await restarted.authorize(_reviewCode()),
      isA<LocalReviewAccessGrant>(),
    );
  });

  test(
    'Review code activates only credential-free local state and no pairing API',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final secureStore = MemorySecureKeyValueStore();
      final pairingApi = _FailIfCalledPairingApi();
      final container = _container(
        preferences: preferences,
        secureStore: secureStore,
        pairingApi: pairingApi,
      );
      addTearDown(container.dispose);

      await container
          .read(pairingControllerProvider.notifier)
          .submitManualCode(_reviewCode());

      expect(container.read(localDemoControllerProvider).active, isTrue);
      expect(container.read(pairingControllerProvider).reviewFlow, isTrue);
      expect(await container.read(sessionRepositoryProvider).read(), isNull);
      expect(await container.read(identityRepositoryProvider).load(), isNull);
      expect(
        await container.read(pairingTransactionRepositoryProvider).read(),
        isNull,
      );
      expect(pairingApi.calls, 0);
      expect(
        secureStore.snapshot.values.join(),
        isNot(contains(_reviewCode())),
      );
      expect(
        preferences
            .getKeys()
            .map((key) => preferences.get(key).toString())
            .join(),
        isNot(contains(_reviewCode())),
      );
    },
  );

  test(
    'Review mode blocks every shared HTTP client before its adapter',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final container = _container(
        preferences: preferences,
        secureStore: MemorySecureKeyValueStore(),
        pairingApi: _FailIfCalledPairingApi(),
      );
      addTearDown(container.dispose);
      await container
          .read(pairingControllerProvider.notifier)
          .submitManualCode(_reviewCode());
      final dio = container.read(publicDioProvider);
      final adapter = _RecordingAdapter();
      dio.httpClientAdapter = adapter;

      await expectLater(
        dio.get<Object?>('/v1/staff/device-context'),
        throwsA(
          isA<DioException>().having(
            (error) => error.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'Review code cannot replace or impersonate a Production session',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final secureStore = MemorySecureKeyValueStore();
      final sessions = StaffDeviceSessionRepository(secureStore);
      await sessions.replaceAtomically(fixtureSession());
      final pairingApi = _FailIfCalledPairingApi();
      final container = _container(
        preferences: preferences,
        secureStore: secureStore,
        pairingApi: pairingApi,
      );
      addTearDown(container.dispose);

      await container
          .read(pairingControllerProvider.notifier)
          .submitManualCode(_reviewCode());

      final persisted = await sessions.read();
      expect(persisted?.sessionMode, StaffSessionMode.normal);
      expect(persisted?.sessionId, fixtureSession().sessionId);
      expect(container.read(localDemoControllerProvider).active, isFalse);
      expect(container.read(localReviewAccessProvider).isActive, isFalse);
      expect(pairingApi.calls, 0);
    },
  );

  test(
    'restart marker restores locally and Exit Review clears it safely',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final first = _container(
        preferences: preferences,
        secureStore: MemorySecureKeyValueStore(),
        pairingApi: _FailIfCalledPairingApi(),
      );
      await first
          .read(pairingControllerProvider.notifier)
          .submitManualCode(_reviewCode());
      expect(first.read(localReviewAccessProvider).isActive, isTrue);
      first.dispose();

      final restartedStore = MemorySecureKeyValueStore();
      final restarted = _container(
        preferences: preferences,
        secureStore: restartedStore,
        pairingApi: _FailIfCalledPairingApi(),
      );
      addTearDown(restarted.dispose);
      expect(
        await restarted
            .read(localDemoControllerProvider.notifier)
            .restoreIfActive(),
        isTrue,
      );
      expect(restarted.read(localDemoControllerProvider).active, isTrue);
      expect(await StaffDeviceSessionRepository(restartedStore).read(), isNull);

      await restarted.read(localDemoControllerProvider.notifier).exit();
      expect(restarted.read(localDemoControllerProvider).active, isFalse);
      expect(restarted.read(localReviewAccessProvider).isActive, isFalse);
    },
  );
}

ProviderContainer _container({
  required SharedPreferences preferences,
  required MemorySecureKeyValueStore secureStore,
  required PairingApi pairingApi,
}) => ProviderContainer(
  overrides: [
    environmentProvider.overrideWithValue(_productionEnvironment),
    sharedPreferencesProvider.overrideWithValue(preferences),
    secureStoreProvider.overrideWithValue(secureStore),
    pairingApiProvider.overrideWithValue(pairingApi),
    localDemoRuntimeProvider.overrideWithValue(
      LocalDemoRuntimeDebug(forceAvailable: true),
    ),
  ],
);

String _reviewCode() => String.fromCharCodes(const [
  87,
  52,
  70,
  76,
  45,
  55,
  82,
  86,
  87,
  45,
  57,
  75,
  81,
  80,
]);

String _wrongReviewCode() => String.fromCharCodes(const [
  87,
  52,
  70,
  76,
  45,
  55,
  82,
  86,
  87,
  45,
  57,
  75,
  81,
  82,
]);

const _reviewDigest =
    'cfe79dd27fd04cd48d85da6335eb9541e61458dc29ce2005f3c4b518c054dd32';

final _productionEnvironment = AppEnvironment(
  flavor: AppFlavor.production,
  apiBaseUrl: Uri.parse('https://api.waflo.app'),
  pairingEnvironment: 'production',
  logLevel: AppLogLevel.minimal,
  allowTestAdapter: false,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
  expectedNativeFlavor: AppFlavor.production,
  suppliedDartEnvironment: 'production',
);

final class _FailIfCalledPairingApi implements PairingApi {
  int calls = 0;

  Never _called() {
    calls += 1;
    throw StateError('Production pairing API must not run for Review access.');
  }

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) => _called();

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) =>
      _called();

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) => _called();
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
