import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

import '../support/fixtures.dart';

void main() {
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
