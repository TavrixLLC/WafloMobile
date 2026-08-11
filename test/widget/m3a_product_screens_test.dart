import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/app_lifecycle.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('task-first Home exposes one dominant scan action', (
    tester,
  ) async {
    await tester.pumpWidget(_home());

    expect(find.byKey(const Key('task-first-home')), findsOneWidget);
    expect(find.byKey(const Key('primary-scan-customer')), findsOneWidget);
    expect(find.text('Fixture Coffee'), findsOneWidget);
    expect(find.text('Main branch'), findsOneWidget);
    expect(find.text('Device & Security'), findsOneWidget);
    expect(find.text('Settings'), findsWidgets);
    expect(find.textContaining('00000000-'), findsNothing);
    expect(find.textContaining('session'), findsNothing);
  });

  testWidgets('pending command is above scan and blocks new scanning', (
    tester,
  ) async {
    await tester.pumpWidget(_home(pending: _pending));

    expect(find.byKey(const Key('pending-operation-home')), findsOneWidget);
    final scan = tester.widget<InkWell>(
      find.byKey(const Key('primary-scan-customer')),
    );
    expect(scan.onTap, isNull);
    expect(find.text('Do not scan this customer again yet.'), findsOneWidget);
  });

  testWidgets('offline Home blocks mutation and explains no queue', (
    tester,
  ) async {
    await tester.pumpWidget(_home(online: false));

    final scan = tester.widget<InkWell>(
      find.byKey(const Key('primary-scan-customer')),
    );
    expect(scan.onTap, isNull);
    expect(find.textContaining('No loyalty change was queued'), findsOneWidget);
  });

  testWidgets('Device & Security exposes useful fields but no secure IDs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootControllerProvider.overrideWithBuild(
            (ref, notifier) => BootState(
              stage: BootStage.pairedReady,
              context: fixtureContext(),
              session: fixtureSession(),
            ),
          ),
          appLockControllerProvider.overrideWithBuild(
            (ref, notifier) => const AppLockState(
              configuration: AppLockConfiguration(
                mode: AppLockMode.pin,
                interval: AppLockInterval.oneMinute,
              ),
              status: AppLockStatus.unlocked,
            ),
          ),
          packageInfoProvider.overrideWithValue(
            AsyncData(
              PackageInfo(
                appName: 'Waflo Staff',
                packageName: 'app.waflo.staff',
                version: '1.0.0',
                buildNumber: '1',
              ),
            ),
          ),
        ],
        child: _app(const DeviceSecurityScreen()),
      ),
    );

    expect(find.text('Security: Protected'), findsOneWidget);
    expect(find.text('Test staff device'), findsOneWidget);
    expect(find.text('Fixture Coffee'), findsOneWidget);
    expect(find.text('Main branch'), findsOneWidget);
    expect(find.text('Local Staff PIN'), findsOneWidget);
    expect(find.textContaining('00000000-'), findsNothing);
    expect(find.textContaining('token'), findsNothing);
    expect(find.textContaining('nonce'), findsNothing);
  });

  testWidgets(
    'PIN and biometric lock states remain understandable without haptics',
    (tester) async {
      await tester.pumpWidget(_locked(AppLockMode.pin));
      expect(find.byKey(const Key('app-lock-overlay')), findsOneWidget);
      expect(find.byKey(const Key('unlock-pin-field')), findsOneWidget);
      expect(find.text('Unlock'), findsOneWidget);

      await tester.pumpWidget(_locked(AppLockMode.biometric));
      await tester.pump();
      expect(find.byKey(const Key('biometric-unlock')), findsOneWidget);
      expect(find.text('Unlock with biometrics'), findsOneWidget);
    },
  );

  testWidgets('App Lock settings identify the lock as local-only', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLockControllerProvider.overrideWithBuild(
            (ref, notifier) => const AppLockState(
              configuration: AppLockConfiguration(),
              status: AppLockStatus.unlocked,
            ),
          ),
        ],
        child: _app(const AppLockSettingsScreen()),
      ),
    );

    expect(find.textContaining('protects this phone only'), findsOneWidget);
    expect(find.textContaining('server permissions'), findsOneWidget);
    expect(find.text('Biometric'), findsOneWidget);
    expect(find.text('Local Staff PIN'), findsOneWidget);
    expect(find.text('Immediately'), findsOneWidget);
    expect(find.text('After 5 minutes'), findsOneWidget);
    expect(find.textContaining('Manager PIN'), findsNothing);
  });

  testWidgets('background state immediately covers customer content', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootControllerProvider.overrideWithBuild(
            (ref, notifier) => BootState(
              stage: BootStage.pairedReady,
              context: fixtureContext(),
              session: fixtureSession(),
            ),
          ),
          appLockControllerProvider.overrideWithBuild(
            (ref, notifier) => const AppLockState(
              configuration: AppLockConfiguration(),
              status: AppLockStatus.unlocked,
            ),
          ),
          m2OperationControllerProvider.overrideWithBuild(
            (ref, notifier) => const M2OperationState.idle(),
          ),
        ],
        child: _app(
          const AppLifecycleBoundary(child: Text('Sensitive customer')),
        ),
      ),
    );

    expect(find.byKey(const Key('privacy-cover')), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byKey(const Key('privacy-cover')), findsOneWidget);
  });
}

Widget _home({bool online = true, PendingOperationRecord? pending}) =>
    ProviderScope(
      overrides: [
        bootControllerProvider.overrideWithBuild(
          (ref, notifier) => BootState(
            stage: BootStage.pairedReady,
            context: fixtureContext(),
            session: fixtureSession(),
          ),
        ),
        m2OperationControllerProvider.overrideWithBuild(
          (ref, notifier) => pending == null
              ? const M2OperationState.idle()
              : M2OperationState(
                  stage: M2OperationStage.stampAmbiguous,
                  pendingOperation: pending,
                ),
        ),
        connectivityProvider.overrideWithValue(AsyncData(online)),
      ],
      child: _app(const HomeScreen()),
    );

Widget _locked(AppLockMode mode) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => AppLockState(
        configuration: AppLockConfiguration(mode: mode),
        status: AppLockStatus.locked,
      ),
    ),
  ],
  child: _app(const AppLockOverlay()),
);

Widget _app(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  theme: WafloTheme.light(),
  home: child,
);

final _pending = PendingOperationRecord(
  commandId: '20000000-0000-4000-8000-000000000001',
  operationType: PendingOperationType.stamp,
  membershipPublicId: 'mem_fixture_not_a_credential',
  stampAmount: 1,
  createdAt: DateTime.utc(2026, 8, 11, 12),
  lastCheckedAt: null,
  status: PendingOperationStatus.processing,
);
