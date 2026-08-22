import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/haptics/haptic_service.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/app_lock/data/biometric_service.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('local Staff PIN', () {
    late MemorySecureKeyValueStore secureStore;
    late AppLockRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      secureStore = MemorySecureKeyValueStore();
      repository = AppLockRepository(
        await SharedPreferences.getInstance(),
        secureStore,
      );
    });

    test(
      'stores verifier material without plaintext and verifies exactly',
      () async {
        await repository.setPin('4826');

        expect(secureStore.snapshot.values, isNotEmpty);
        expect(secureStore.snapshot.values.join(), isNot(contains('4826')));
        expect(await repository.hasPin(), isTrue);
        expect(await repository.verifyPin('4826'), isTrue);
        expect(await repository.verifyPin('4827'), isFalse);
        await repository.clearPin();
        expect(await repository.hasPin(), isFalse);
      },
    );

    test('legacy biometric-only configuration is disabled safely', () async {
      SharedPreferences.setMockInitialValues({'app_lock.mode.v1': 'biometric'});
      final legacy = AppLockRepository(
        await SharedPreferences.getInstance(),
        secureStore,
      );

      expect(legacy.readConfiguration().mode, AppLockMode.off);

      await legacy.setConfiguration(
        const AppLockConfiguration(mode: AppLockMode.biometric),
      );
      expect(
        (await SharedPreferences.getInstance()).getString('app_lock.mode.v1'),
        'biometricWithPin',
      );
      expect(legacy.readConfiguration().mode, AppLockMode.biometric);
    });

    test('accepts only four to six ASCII digits', () async {
      for (final invalid in ['123', '1234567', '12A4', '١٢٣٤']) {
        expect(() => repository.setPin(invalid), throwsFormatException);
      }
      await repository.setPin('123456');
      expect(await repository.verifyPin('123456'), isTrue);
    });

    test(
      'applies progressive local delays and persists no PIN attempt',
      () async {
        final now = DateTime.utc(2026, 8, 11, 12);
        final first = await repository.registerFailure(now);
        final second = await repository.registerFailure(now);
        final third = await repository.registerFailure(now);
        final fourth = await repository.registerFailure(now);

        expect(first.retryAt, isNull);
        expect(second.retryAt, isNull);
        expect(third.retryAt, now.add(const Duration(seconds: 5)));
        expect(fourth.retryAt, now.add(const Duration(seconds: 15)));
        expect(secureStore.snapshot.values.join(), isNot(contains('PIN')));
      },
    );

    test('lock interval policy remains exact', () {
      expect(AppLockInterval.immediately.duration, Duration.zero);
      expect(AppLockInterval.oneMinute.duration, const Duration(minutes: 1));
      expect(AppLockInterval.fiveMinutes.duration, const Duration(minutes: 5));
    });

    test(
      'App Lock controller applies cold-start and resume intervals',
      () async {
        await repository.setPin('4826');
        await repository.setConfiguration(
          const AppLockConfiguration(mode: AppLockMode.pin),
        );
        final container = ProviderContainer(
          overrides: [appLockRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);
        final controller = container.read(appLockControllerProvider.notifier);
        final initial = container.read(appLockControllerProvider);
        expect(initial.status, AppLockStatus.locked);

        await controller.setPin('4826');
        await controller.setInterval(AppLockInterval.oneMinute);
        final backgroundedAt = DateTime.utc(2026, 8, 11, 12);
        controller.onBackground(backgroundedAt);
        controller.onResume(backgroundedAt.add(const Duration(seconds: 59)));
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.unlocked,
        );

        controller.onBackground(backgroundedAt);
        controller.onResume(backgroundedAt.add(const Duration(minutes: 1)));
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.locked,
        );
      },
    );

    test('biometrics require a PIN and always retain PIN fallback', () async {
      final biometrics = FakeBiometricService();
      final container = ProviderContainer(
        overrides: [
          appLockRepositoryProvider.overrideWithValue(repository),
          biometricServiceProvider.overrideWithValue(biometrics),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(appLockControllerProvider.notifier);

      expect(await controller.setBiometric('Enable biometrics'), isFalse);
      expect(biometrics.calls, 0);
      expect(
        container.read(appLockControllerProvider).safeErrorCode,
        'PIN_REQUIRED',
      );

      await controller.setPin('4826');
      expect(await controller.setBiometric('Enable biometrics'), isTrue);
      expect(await repository.hasPin(), isTrue);
      expect(
        container.read(appLockControllerProvider).configuration.mode,
        AppLockMode.biometric,
      );

      controller.lockNow();
      biometrics.result = false;
      expect(await controller.unlockWithBiometric('Unlock'), isFalse);
      expect(
        container.read(appLockControllerProvider).safeErrorCode,
        'BIOMETRIC_FAILED',
      );
      expect(
        await controller.unlockWithPin('4826', DateTime.utc(2026, 8, 21)),
        isTrue,
      );
      expect(
        container.read(appLockControllerProvider).status,
        AppLockStatus.unlocked,
      );
    });

    test(
      'biometric lifecycle interruption unlocks once without relocking',
      () async {
        await repository.setPin('4826');
        await repository.setConfiguration(
          const AppLockConfiguration(mode: AppLockMode.biometric),
        );
        final biometrics = _DeferredBiometricService();
        final container = ProviderContainer(
          overrides: [
            appLockRepositoryProvider.overrideWithValue(repository),
            biometricServiceProvider.overrideWithValue(biometrics),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(appLockControllerProvider.notifier);
        final backgroundedAt = DateTime.utc(2026, 8, 21, 12);

        final first = controller.unlockWithBiometric('Unlock');
        final duplicate = controller.unlockWithBiometric('Unlock');
        expect(biometrics.calls, 1);

        controller.onBackground(backgroundedAt);
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.authenticating,
        );

        biometrics.complete(true);
        expect(await first, isTrue);
        expect(await duplicate, isTrue);
        controller.onResume(backgroundedAt.add(const Duration(seconds: 1)));

        expect(biometrics.calls, 1);
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.unlocked,
        );
      },
    );

    test(
      'biometric resume before the platform result does not relock',
      () async {
        await repository.setPin('4826');
        await repository.setConfiguration(
          const AppLockConfiguration(mode: AppLockMode.biometric),
        );
        final biometrics = _DeferredBiometricService();
        final container = ProviderContainer(
          overrides: [
            appLockRepositoryProvider.overrideWithValue(repository),
            biometricServiceProvider.overrideWithValue(biometrics),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(appLockControllerProvider.notifier);
        final backgroundedAt = DateTime.utc(2026, 8, 21, 12);

        final authentication = controller.unlockWithBiometric('Unlock');
        controller.onBackground(backgroundedAt);
        controller.onResume(backgroundedAt.add(const Duration(seconds: 1)));
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.authenticating,
        );

        biometrics.complete(true);
        expect(await authentication, isTrue);
        expect(biometrics.calls, 1);
        expect(
          container.read(appLockControllerProvider).status,
          AppLockStatus.unlocked,
        );
      },
    );

    test('cancelled biometric lifecycle falls back to the PIN', () async {
      await repository.setPin('4826');
      await repository.setConfiguration(
        const AppLockConfiguration(mode: AppLockMode.biometric),
      );
      final biometrics = _DeferredBiometricService();
      final container = ProviderContainer(
        overrides: [
          appLockRepositoryProvider.overrideWithValue(repository),
          biometricServiceProvider.overrideWithValue(biometrics),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(appLockControllerProvider.notifier);
      final backgroundedAt = DateTime.utc(2026, 8, 21, 12);

      final authentication = controller.unlockWithBiometric('Unlock');
      controller.onBackground(backgroundedAt);
      biometrics.complete(false);
      expect(await authentication, isFalse);
      controller.onResume(backgroundedAt.add(const Duration(seconds: 1)));

      expect(container.read(appLockControllerProvider).isLocked, isTrue);
      expect(
        container.read(appLockControllerProvider).safeErrorCode,
        'BIOMETRIC_FAILED',
      );
      expect(await controller.unlockWithPin('4826', backgroundedAt), isTrue);
    });
  });

  group('scanner state machine', () {
    test(
      'accepts one candidate and blocks duplicate frames while resolving',
      () {
        final machine = CustomerScannerStateMachine();
        final now = DateTime.utc(2026, 8, 11, 12);

        machine.ready();
        machine.scanning();
        expect(machine.capture(now), isTrue);
        expect(machine.state, CustomerScannerState.candidateCaptured);
        expect(machine.capture(now.add(const Duration(seconds: 2))), isFalse);
        machine.resolving();
        expect(machine.state, CustomerScannerState.resolving);
        expect(machine.capture(now.add(const Duration(seconds: 3))), isFalse);
      },
    );

    test('background blocks capture and reset discards previous candidate', () {
      final machine = CustomerScannerStateMachine();
      final now = DateTime.utc(2026, 8, 11, 12);

      machine.ready();
      machine.background();
      expect(machine.capture(now), isFalse);
      machine.reset();
      expect(machine.state, CustomerScannerState.idle);
      machine.ready();
      expect(machine.capture(now), isTrue);
    });

    test('rejects non-failure states as failure outcomes', () {
      final machine = CustomerScannerStateMachine();
      expect(
        () => machine.fail(CustomerScannerState.scanning),
        throwsArgumentError,
      );
    });

    test('distinguishes permanent camera denial for settings recovery', () {
      final machine = CustomerScannerStateMachine();

      machine.permissionDenied();
      expect(machine.state, CustomerScannerState.cameraPermissionDenied);
      machine.permissionPermanentlyDenied();
      expect(
        machine.state,
        CustomerScannerState.cameraPermissionPermanentlyDenied,
      );
    });
  });

  test('fake haptics record optional product signals in order', () async {
    final service = FakeHapticService();
    for (final event in WafloHaptic.values) {
      await service.play(event);
    }
    expect(service.events, WafloHaptic.values);
    expect(WafloHaptic.values.map((event) => event.platformPattern), [
      PlatformHapticPattern.selection,
      PlatformHapticPattern.light,
      PlatformHapticPattern.medium,
      PlatformHapticPattern.medium,
      PlatformHapticPattern.light,
      PlatformHapticPattern.medium,
    ]);
  });

  test('PIN delay curve is progressive and capped locally', () {
    expect(PinRateLimitPolicy.delayFor(1), Duration.zero);
    expect(PinRateLimitPolicy.delayFor(3), const Duration(seconds: 5));
    expect(PinRateLimitPolicy.delayFor(4), const Duration(seconds: 15));
    expect(PinRateLimitPolicy.delayFor(5), const Duration(minutes: 1));
    expect(PinRateLimitPolicy.delayFor(20), const Duration(minutes: 5));
  });
}

final class _DeferredBiometricService implements BiometricService {
  final Completer<bool> _result = Completer<bool>();
  int calls = 0;

  @override
  Future<bool> authenticate(String reason) {
    calls += 1;
    return _result.future;
  }

  @override
  Future<bool> isAvailable() async => true;

  void complete(bool value) => _result.complete(value);
}
