import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/app.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';

import '../test/support/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('01 fresh install boots the real app unpaired', (tester) async {
    final harness = await _AppHarness.pump(tester);
    expect(find.text('Pair this staff device'), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);
  });

  testWidgets('02 English pairing uses the injected scanner path', (
    tester,
  ) async {
    final harness = await _AppHarness.pump(tester);
    harness.container.read(pairingControllerProvider.notifier).showScanner();
    await _pumpFrames(tester);
    await harness.scanner.emit(_developmentToken());
    await _pumpFrames(tester);
    expect(find.text('Device paired'), findsOneWidget);
    expect(harness.pairingApi.completeCalls, 1);
  });

  testWidgets('03 Arabic RTL pairing renders through the real app', (
    tester,
  ) async {
    final harness = await _AppHarness.pump(
      tester,
      preferenceValues: {'preferences.locale.v1': 'ar'},
    );
    final welcome = find.byKey(const Key('scan-pairing-code'));
    expect(welcome, findsOneWidget);
    expect(Directionality.of(tester.element(welcome)), TextDirection.rtl);
    harness.container.read(pairingControllerProvider.notifier).showScanner();
    await _pumpFrames(tester);
    await harness.scanner.emit(_developmentToken());
    await _pumpFrames(tester);
    expect(harness.pairingApi.completeCalls, 1);
  });

  testWidgets('04 process restart after claim resumes automatically', (
    tester,
  ) async {
    final store = MemorySecureKeyValueStore();
    final identity = await DeviceIdentityRepository(store).loadOrCreate();
    await PairingTransactionRepository(store).mark(
      pairingPublicId: _pairingPublicId,
      stage: PairingTransactionStage.claimPending,
    );
    await LocalLifecycleRepository(store).mark(LocalLifecycleState.pairing);
    final api = _AppPairingApi(installationId: identity.installationId);
    final harness = await _AppHarness.pump(
      tester,
      store: store,
      pairingApi: api,
    );
    expect(api.challengeCalls, 1);
    expect(api.completeCalls, 1);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNotNull);
    expect(await PairingTransactionRepository(harness.store).read(), isNull);
    expect(
      (await LocalLifecycleRepository(harness.store).read())?.state,
      LocalLifecycleState.paired,
    );
  });

  testWidgets('05 challenge recovery validates and completes once', (
    tester,
  ) async {
    final store = MemorySecureKeyValueStore();
    final identity = await DeviceIdentityRepository(store).loadOrCreate();
    await PairingTransactionRepository(store).mark(
      pairingPublicId: _pairingPublicId,
      stage: PairingTransactionStage.claimPending,
    );
    final api = _AppPairingApi(installationId: identity.installationId);
    await _AppHarness.pump(tester, store: store, pairingApi: api);
    expect(api.challengeCalls, 1);
    expect(api.completeCalls, 1);
    expect(await PairingTransactionRepository(store).read(), isNull);
  });

  testWidgets('06 pairing completion transitions from success to home', (
    tester,
  ) async {
    final harness = await _pairedThroughScanner(tester);
    await tester.tap(find.byKey(const Key('pairing-success-continue')));
    await _pumpFrames(tester);
    _expectTaskFirstHome();
    expect(
      (await LocalLifecycleRepository(harness.store).read())?.state,
      LocalLifecycleState.paired,
    );
  });

  testWidgets('07 secure session restoration loads authoritative context', (
    tester,
  ) async {
    await _AppHarness.pump(tester, restored: true);
    _expectTaskFirstHome();
    expect(find.text('Fixture Coffee'), findsOneWidget);
    expect(find.text('Main branch'), findsOneWidget);
    expect(find.textContaining('Fixture Staff'), findsNothing);
  });

  testWidgets('08 refresh is single-flight in the real app container', (
    tester,
  ) async {
    final sessionApi = _AppSessionApi();
    final barrier = Completer<void>();
    sessionApi.refreshBarrier = barrier.future;
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: sessionApi,
    );
    final manager = harness.container.read(sessionManagerProvider);
    final first = manager.refreshSingleFlight();
    final second = manager.refreshSingleFlight();
    await Future<void>.delayed(Duration.zero);
    expect(sessionApi.refreshCalls, 1);
    barrier.complete();
    await Future.wait([first, second]);
    expect(sessionApi.refreshCalls, 1);
  });

  testWidgets('09 rejected old refresh token routes session repair', (
    tester,
  ) async {
    final sessionApi = _AppSessionApi(
      refreshFailure: const ApiFailure(
        'STAFF_DEVICE_SESSION_EXPIRED',
        httpStatus: 401,
      ),
    );
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      expiredSession: true,
      sessionApi: sessionApi,
    );
    expect(find.text('Session expired'), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);
  });

  testWidgets('10 context supports multiple assigned Locations', (
    tester,
  ) async {
    final context = fixtureContext(
      assignedLocations: const [
        LocationContext(
          publicId: '00000000-0000-4000-8000-000000000204',
          displayName: 'Main branch',
          earningAllowed: true,
          redemptionAllowed: true,
        ),
        LocationContext(
          publicId: '00000000-0000-4000-8000-000000000214',
          displayName: 'Airport branch',
          earningAllowed: true,
          redemptionAllowed: false,
        ),
      ],
    );
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: _AppSessionApi(context: context),
    );
    _expectTaskFirstHome();
    expect(
      harness.container.read(bootControllerProvider).context?.assignedLocations,
      hasLength(2),
    );
    expect(find.text('Main branch'), findsOneWidget);
    expect(find.text('Airport branch'), findsNothing);
  });

  testWidgets('11 revoked clears session and renders repair state', (
    tester,
  ) async {
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: _AppSessionApi(
        contextFailure: const ApiFailure(
          'STAFF_DEVICE_REVOKED',
          httpStatus: 401,
        ),
      ),
    );
    expect(find.text('Device revoked'), findsOneWidget);
    expect(find.byKey(const Key('pair-device-again')), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);

    await tester.tap(find.byKey(const Key('pair-device-again')));
    await _pumpFrames(tester);

    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);
    expect(await DeviceIdentityRepository(harness.store).load(), isNull);
    expect(await PairingTransactionRepository(harness.store).read(), isNull);
    expect(
      (await LocalLifecycleRepository(harness.store).read())?.state,
      LocalLifecycleState.neverPaired,
    );
  });

  testWidgets('12 compromised clears session and renders repair state', (
    tester,
  ) async {
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: _AppSessionApi(
        contextFailure: const ApiFailure(
          'STAFF_DEVICE_COMPROMISED',
          httpStatus: 401,
        ),
      ),
    );
    expect(find.text('Device blocked for security'), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);
  });

  testWidgets('13 update required blocks operations but preserves session', (
    tester,
  ) async {
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: _AppSessionApi(
        contextFailure: const ApiFailure(
          'APP_UPDATE_REQUIRED',
          httpStatus: 426,
        ),
      ),
    );
    expect(find.text('Update required'), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNotNull);
  });

  testWidgets('14 offline context can retry without revocation mapping', (
    tester,
  ) async {
    final sessionApi = _AppSessionApi(contextFailure: const NetworkFailure());
    final harness = await _AppHarness.pump(
      tester,
      restored: true,
      sessionApi: sessionApi,
    );
    expect(find.text('Waflo is unavailable'), findsOneWidget);
    sessionApi.contextFailure = null;
    await tester.tap(find.byKey(const Key('retry-boot')));
    await _pumpFrames(tester);
    _expectTaskFirstHome();
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNotNull);
  });

  testWidgets('15 logout removes local identity and session', (tester) async {
    final harness = await _AppHarness.pump(tester, restored: true);
    await tester.tap(find.text('Device & Security'));
    await _pumpFrames(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('sign-out')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('sign-out')));
    await _pumpFrames(tester);
    await tester.tap(find.text('Sign out').last);
    await _pumpFrames(tester);
    expect(find.text('Pair this staff device'), findsOneWidget);
    expect(await StaffDeviceSessionRepository(harness.store).read(), isNull);
    expect(await DeviceIdentityRepository(harness.store).load(), isNull);
  });

  testWidgets('16 recovery-required secure state fails closed', (tester) async {
    final store = MemorySecureKeyValueStore();
    await DeviceIdentityRepository(store).loadOrCreate();
    await LocalLifecycleRepository(store).mark(
      LocalLifecycleState.recoveryRequired,
      reason: 'REFRESH_ROTATED_LOCAL_REPLACEMENT_FAILED',
    );
    await _AppHarness.pump(tester, store: store);
    expect(find.text('Local security key unavailable'), findsOneWidget);
  });

  testWidgets('17 environment mismatch renders CONFIGURATION_ERROR UI', (
    tester,
  ) async {
    await _AppHarness.pump(
      tester,
      environment: AppEnvironment(
        flavor: AppFlavor.production,
        expectedNativeFlavor: AppFlavor.staging,
        suppliedDartEnvironment: 'production',
        apiBaseUrl: Uri.parse('https://api.waflo.app'),
        pairingEnvironment: 'production',
        logLevel: AppLogLevel.minimal,
        allowTestAdapter: false,
        minimumVersionSource: 'backend',
        crashReportingEnabled: false,
        certificatePinningEnabled: false,
      ),
    );
    expect(find.text('App configuration error'), findsOneWidget);
  });

  testWidgets('18 large-text accessibility flow remains usable', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _AppHarness.pump(tester);
    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('19 configured staging build reaches pairing and home', (
    tester,
  ) async {
    final environment = AppEnvironment.fromDefines(
      expectedNativeFlavor: AppFlavor.staging,
    );
    expect(environment.validate(), isEmpty);

    final harness = await _AppHarness.pump(tester, environment: environment);
    expect(find.text('Pair this staff device'), findsOneWidget);
    expect(find.text('App configuration error'), findsNothing);

    harness.container.read(pairingControllerProvider.notifier).showScanner();
    await _pumpFrames(tester);
    await harness.scanner.emit(_stagingToken());
    await _pumpFrames(tester);
    await tester.tap(find.byKey(const Key('pairing-success-continue')));
    await _pumpFrames(tester);
    _expectTaskFirstHome();
  }, skip: const String.fromEnvironment('WAFLO_ENV') != 'staging');
}

void _expectTaskFirstHome() {
  expect(find.byKey(const Key('task-first-home')), findsOneWidget);
  expect(find.text('Scan customer'), findsOneWidget);
}

Future<_AppHarness> _pairedThroughScanner(WidgetTester tester) async {
  final harness = await _AppHarness.pump(tester);
  harness.container.read(pairingControllerProvider.notifier).showScanner();
  await _pumpFrames(tester);
  await harness.scanner.emit(_developmentToken());
  await _pumpFrames(tester);
  return harness;
}

final class _AppHarness {
  const _AppHarness({
    required this.container,
    required this.store,
    required this.pairingApi,
    required this.sessionApi,
    required this.scanner,
  });

  final ProviderContainer container;
  final MemorySecureKeyValueStore store;
  final _AppPairingApi pairingApi;
  final _AppSessionApi sessionApi;
  final _TestScannerAdapter scanner;

  static Future<_AppHarness> pump(
    WidgetTester tester, {
    MemorySecureKeyValueStore? store,
    _AppPairingApi? pairingApi,
    _AppSessionApi? sessionApi,
    AppEnvironment? environment,
    bool restored = false,
    bool expiredSession = false,
    Map<String, Object> preferenceValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(preferenceValues);
    final preferences = await SharedPreferences.getInstance();
    final resolvedStore = store ?? MemorySecureKeyValueStore();
    if (restored) {
      await DeviceIdentityRepository(resolvedStore).loadOrCreate();
      await StaffDeviceSessionRepository(resolvedStore).replaceAtomically(
        fixtureSession(
          expiresAt: expiredSession
              ? DateTime.now().toUtc().subtract(const Duration(minutes: 1))
              : null,
        ),
      );
      await LocalLifecycleRepository(
        resolvedStore,
      ).mark(LocalLifecycleState.paired);
    }
    final resolvedPairingApi = pairingApi ?? _AppPairingApi();
    final resolvedSessionApi = sessionApi ?? _AppSessionApi();
    final scanner = _TestScannerAdapter();
    final container = ProviderContainer(
      overrides: [
        environmentProvider.overrideWithValue(environment ?? _environment),
        sharedPreferencesProvider.overrideWithValue(preferences),
        secureStoreProvider.overrideWithValue(resolvedStore),
        pairingApiProvider.overrideWithValue(resolvedPairingApi),
        deviceSessionApiProvider.overrideWithValue(resolvedSessionApi),
        metadataProvider.overrideWithValue(const _Metadata()),
        pairingScannerAdapterProvider.overrideWithValue(scanner),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        packageInfoProvider.overrideWith(
          (ref) => PackageInfo(
            appName: 'Waflo Staff',
            packageName: 'app.waflo.staff.dev',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const WafloApp()),
    );
    await _pumpFrames(tester);
    return _AppHarness(
      container: container,
      store: resolvedStore,
      pairingApi: resolvedPairingApi,
      sessionApi: resolvedSessionApi,
      scanner: scanner,
    );
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 20; frame += 1) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

final class _AppPairingApi implements PairingApi {
  _AppPairingApi({this.installationId});

  String? installationId;
  int challengeCalls = 0;
  int completeCalls = 0;

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) async {
    installationId = command.installationId;
    final recovered = _challenge(_pairingPublicId);
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
    return _challenge(pairingPublicId);
  }

  PairingChallengeResult _challenge(String pairingPublicId) {
    final localInstallationId = installationId;
    if (localInstallationId == null) {
      throw StateError('Test installation ID missing.');
    }
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
        localInstallationId,
      ].join('\n'),
    );
  }

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async {
    completeCalls += 1;
    return fixtureSession();
  }
}

final class _AppSessionApi implements DeviceSessionApi {
  _AppSessionApi({
    AuthoritativeDeviceContext? context,
    this.contextFailure,
    this.refreshFailure,
  }) : context = context ?? fixtureContext();

  final AuthoritativeDeviceContext context;
  AppFailure? contextFailure;
  final AppFailure? refreshFailure;
  int refreshCalls = 0;
  Future<void>? refreshBarrier;

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async {
    final failure = contextFailure;
    if (failure != null) {
      throw failure;
    }
    return context;
  }

  @override
  Future<void> logout(StaffDeviceSession current) async {}

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async {
    refreshCalls += 1;
    final barrier = refreshBarrier;
    if (barrier != null) {
      await barrier;
    }
    final failure = refreshFailure;
    if (failure != null) {
      throw failure;
    }
    return fixtureSession(sessionId: '00000000-0000-4000-8000-000000000299');
  }
}

final class _Metadata implements DeviceMetadataProvider {
  const _Metadata();

  @override
  Future<SafeDeviceMetadata> load() async => const SafeDeviceMetadata(
    platform: StaffMobilePlatform.android,
    appVersion: '1.0.0',
  );
}

final class _TestScannerAdapter implements PairingScannerAdapter {
  Future<void> Function(String value)? _onDetected;
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.ready,
  );
  final ValueNotifier<bool> _torch = ValueNotifier(false);

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torch;

  Future<void> emit(String value) async {
    final callback = _onDetected;
    if (callback == null) {
      throw StateError('Scanner preview is not active.');
    }
    await callback(value);
  }

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) {
    _onDetected = onDetected;
    return const ColoredBox(
      key: Key('test-pairing-scanner'),
      color: Colors.black,
    );
  }

  @override
  Future<void> dispose() async {
    _state.dispose();
    _torch.dispose();
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> toggleTorch() async => _torch.value = !_torch.value;
}

final _environment = AppEnvironment(
  flavor: AppFlavor.development,
  expectedNativeFlavor: AppFlavor.development,
  suppliedDartEnvironment: 'development',
  apiBaseUrl: Uri.parse('http://10.0.2.2:3000'),
  pairingEnvironment: 'development',
  logLevel: AppLogLevel.debug,
  allowTestAdapter: true,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
);

const _pairingPublicId = '00000000-0000-4000-8000-000000000100';

String _developmentToken() {
  return 'waflo-pair-v1.'
      'MDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMTAw.'
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.'
      'ZGV2ZWxvcG1lbnQ';
}

String _stagingToken() {
  return 'waflo-pair-v1.'
      'MDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMTAw.'
      'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.'
      'c3RhZ2luZw';
}
