import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/haptics/haptic_service.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_release.dart'
    as release_runtime;
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

void main() {
  test(
    'LOCAL_DEMO enters without a Staff session or Backend credential',
    () async {
      final secureStore = MemorySecureKeyValueStore();
      final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
      final container = _container(runtime, secureStore);
      addTearDown(container.dispose);

      expect(
        await container.read(localDemoControllerProvider.notifier).enter(),
        isTrue,
      );
      expect(container.read(localDemoControllerProvider).active, isTrue);
      expect(
        container.read(activeDeviceContextProvider)?.organization.displayName,
        'Waflo Demo Café',
      );
      expect(await container.read(sessionRepositoryProvider).read(), isNull);
      expect(secureStore.snapshot, isEmpty);
    },
  );

  test(
    'local stamp and approved reward paths use authoritative UI models',
    () async {
      final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
      final container = _container(runtime, MemorySecureKeyValueStore());
      addTearDown(container.dispose);
      await container.read(localDemoControllerProvider.notifier).enter();
      final demo = container.read(localDemoControllerProvider.notifier);

      await demo.prepareScenario(
        LocalDemoScenario.customerFiveOfEight,
        locale: 'en',
      );
      var operation = container.read(m2OperationControllerProvider);
      expect(operation.membership?.progress.progress, 5);
      expect(
        operation.membership?.progress.slots.where(
          (slot) => slot.name == 'filled',
        ),
        hasLength(5),
      );

      await demo.prepareScenario(LocalDemoScenario.stampSuccess, locale: 'en');
      operation = container.read(m2OperationControllerProvider);
      expect(operation.stage, M2OperationStage.stampSucceeded);
      expect(operation.stampResult?.progress.progress, 6);

      await demo.prepareScenario(
        LocalDemoScenario.managerApprovalPending,
        locale: 'en',
      );
      operation = container.read(m2OperationControllerProvider);
      expect(operation.stage, M2OperationStage.managerApprovalRequired);
      expect(operation.managerApprovalState, ManagerApprovalState.pending);

      await demo.simulateManagerApproved(locale: 'en');
      operation = container.read(m2OperationControllerProvider);
      expect(operation.stage, M2OperationStage.redemptionSucceeded);
      expect(operation.redemptionResult?.progress.progress, 0);
      expect(operation.redemptionResult?.rewardReady, isFalse);
      expect(
        operation.redemptionResult?.progress.slots,
        everyElement(StampSlotState.empty),
      );
    },
  );

  test('local loyalty fixtures preserve the locked two-state grid', () async {
    final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
    final container = _container(runtime, MemorySecureKeyValueStore());
    addTearDown(container.dispose);
    final demo = container.read(localDemoControllerProvider.notifier);
    await demo.enter();

    await demo.prepareScenario(
      LocalDemoScenario.customerZeroOfEight,
      locale: 'en',
    );
    var progress = container
        .read(m2OperationControllerProvider)
        .membership
        ?.progress;
    expect(progress?.progress, 0);
    expect(progress?.slots, everyElement(StampSlotState.empty));

    await demo.prepareScenario(
      LocalDemoScenario.customerRewardReady,
      locale: 'en',
    );
    final membership = container.read(m2OperationControllerProvider).membership;
    progress = membership?.progress;
    expect(progress?.progress, 8);
    expect(progress?.slots, everyElement(StampSlotState.filled));
    expect(membership?.rewardReady, isTrue);
  });

  test('Exit Demo clears local-only state without a server logout', () async {
    final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
    final container = _container(runtime, MemorySecureKeyValueStore());
    addTearDown(container.dispose);
    final demo = container.read(localDemoControllerProvider.notifier);
    await demo.enter();
    await demo.prepareScenario(LocalDemoScenario.stampSuccess, locale: 'en');

    await demo.exit();

    expect(container.read(localDemoControllerProvider).active, isFalse);
    expect(runtime.pendingOperations.read(), isNull);
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.idle,
    );
  });

  test('local App Lock fixture remains isolated and rate-limited', () async {
    final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
    final container = _container(runtime, MemorySecureKeyValueStore());
    addTearDown(container.dispose);
    final demo = container.read(localDemoControllerProvider.notifier);
    await demo.enter();

    await demo.prepareScenario(LocalDemoScenario.appLock, locale: 'en');

    var lock = container.read(appLockControllerProvider);
    expect(lock.configuration.mode, AppLockMode.pin);
    expect(lock.status, AppLockStatus.locked);
    expect(
      await container
          .read(appLockControllerProvider.notifier)
          .unlockWithPin('0000', DateTime.utc(2026, 8, 14)),
      isFalse,
    );
    lock = container.read(appLockControllerProvider);
    expect(lock.status, AppLockStatus.locked);
    expect(
      await container
          .read(appLockControllerProvider.notifier)
          .unlockWithPin('2468', DateTime.utc(2026, 8, 14, 0, 0, 1)),
      isTrue,
    );
    expect(
      container.read(appLockControllerProvider).status,
      AppLockStatus.unlocked,
    );
  });

  test('production rejects local runtime even when a caller requests it', () {
    final production = _environment(AppFlavor.production, localDemo: true);
    final debugRuntime = LocalDemoRuntimeDebug(forceAvailable: true);
    final releaseRuntime = release_runtime.createLocalDemoRuntime();

    expect(debugRuntime.availableFor(production), isFalse);
    expect(releaseRuntime.availableFor(production), isFalse);
    expect(
      () => releaseRuntime.deviceContext,
      throwsA(isA<LocalDemoUnavailableError>()),
    );
    expect(production.validate(), contains('PRODUCTION_LOCAL_DEMO_FORBIDDEN'));
  });

  test(
    'committed build configs enable local demo only for non-production debug',
    () {
      final development = _config('config/development.json');
      final staging = _config('config/staging.json');
      final production = _config('config/production.json');

      expect(development['WAFLO_LOCAL_DEMO_ENABLED'], 'true');
      expect(staging['WAFLO_LOCAL_DEMO_ENABLED'], 'true');
      expect(production['WAFLO_LOCAL_DEMO_ENABLED'], 'false');
      expect(production['WAFLO_API_BASE_URL'], 'https://api.waflo.app');
      expect(staging['WAFLO_API_BASE_URL'], 'https://api-staging.waflo.app');
    },
  );
}

ProviderContainer _container(
  LocalDemoRuntime runtime,
  MemorySecureKeyValueStore secureStore,
) => ProviderContainer(
  overrides: [
    environmentProvider.overrideWithValue(_environment(AppFlavor.staging)),
    localDemoRuntimeProvider.overrideWithValue(runtime),
    secureStoreProvider.overrideWithValue(secureStore),
    hapticServiceProvider.overrideWithValue(FakeHapticService()),
  ],
);

AppEnvironment _environment(AppFlavor flavor, {bool localDemo = true}) =>
    AppEnvironment(
      flavor: flavor,
      apiBaseUrl: Uri.parse(
        flavor == AppFlavor.production
            ? 'https://api.waflo.app'
            : 'https://api-staging.waflo.app',
      ),
      pairingEnvironment: flavor == AppFlavor.production
          ? 'production'
          : 'test',
      logLevel: flavor == AppFlavor.production
          ? AppLogLevel.minimal
          : AppLogLevel.info,
      allowTestAdapter: false,
      minimumVersionSource: 'backend',
      crashReportingEnabled: false,
      certificatePinningEnabled: false,
      localDemoRequested: localDemo,
      expectedNativeFlavor: flavor,
      suppliedDartEnvironment: flavor.name,
    );

Map<String, Object?> _config(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
