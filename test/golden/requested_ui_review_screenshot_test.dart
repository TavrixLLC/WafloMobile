import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Manrope')
          ..addFont(rootBundle.load('assets/brand/fonts/Manrope-Regular.ttf')))
        .load();
    await (FontLoader('NotoSansArabic')..addFont(
          rootBundle.load('assets/brand/fonts/NotoSansArabic-Variable.ttf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('requested UI review screenshots', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await _capture(tester, '01-device-revoked', _revoked());
    await _capture(tester, '02-app-lock-settings', _appLockSettings());
    await _capture(tester, '03-biometric-pin-fallback', _biometricFallback());
    await _capture(tester, '04-device-security-unavailable', _deviceSecurity());
    await _capture(tester, '05-home', _home());
    await _capture(tester, '06-approved-device', _approvedDevice());
    await _capture(tester, '07-language-selector', _settings());
    await _capture(
      tester,
      '08-badini-screen',
      _home(locale: WafloLocales.badini),
    );
    await _capture(
      tester,
      '09-sorani-screen',
      _home(locale: WafloLocales.sorani),
    );
    await _capture(
      tester,
      '10-arabic-rtl-navigation',
      _settings(locale: WafloLocales.arabic),
    );
    await _capture(tester, '11-english-ltr-navigation', _settings());
    await _capture(tester, '12-pairing-english', _pairingWelcome());
    await _captureLanguageSheet(
      tester,
      '13-pairing-language-sheet',
      _pairingWelcome(),
    );
    await _captureLanguageSheet(
      tester,
      '14-pairing-arabic-selection',
      _pairingWelcome(locale: WafloLocales.arabic),
    );
    await _captureLanguageSheet(
      tester,
      '15-pairing-kurdish-section',
      _pairingWelcome(locale: WafloLocales.badini),
    );
    await _capture(tester, '16-settings-screen', _settings());
    await _capture(tester, '17-home-screen', _home());
    await _capture(tester, '18-pin-create-screen', _pinSetup());
  });
}

Future<void> _capture(WidgetTester tester, String name, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump(const Duration(milliseconds: 220));
  final exception = tester.takeException();
  if (exception != null) throw TestFailure('$name layout failed: $exception');
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../artifacts/ui-review/$name.png'),
  );
}

Future<void> _captureLanguageSheet(
  WidgetTester tester,
  String name,
  Widget widget,
) async {
  await tester.pumpWidget(widget);
  await tester.pump(const Duration(milliseconds: 220));
  await tester.tap(find.byKey(const Key('pairing-language-control')));
  await tester.pumpAndSettle();
  final exception = tester.takeException();
  if (exception != null) throw TestFailure('$name layout failed: $exception');
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../artifacts/ui-review/$name.png'),
  );
}

Widget _revoked() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => const BootState(stage: BootStage.deviceRevoked),
    ),
  ],
  child: _app(
    const BlockedScreen(state: BootState(stage: BootStage.deviceRevoked)),
  ),
);

Widget _appLockSettings() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(),
        status: AppLockStatus.unlocked,
      ),
    ),
  ],
  child: _app(const AppLockSettingsScreen()),
);

Widget _pinSetup() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(),
        status: AppLockStatus.unlocked,
      ),
    ),
  ],
  child: _app(const PinSetupScreen()),
);

Widget _biometricFallback() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(mode: AppLockMode.biometric),
        status: AppLockStatus.locked,
        safeErrorCode: 'BIOMETRIC_FAILED',
      ),
    ),
  ],
  child: _app(const AppLockOverlay()),
);

Widget _deviceSecurity() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    activeDeviceContextProvider.overrideWithValue(_unavailableContext),
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(mode: AppLockMode.pin),
        status: AppLockStatus.unlocked,
      ),
    ),
    packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
  ],
  child: _app(const DeviceSecurityScreen()),
);

Widget _home({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => const BootState(stage: BootStage.unpaired),
    ),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
  ],
  child: _app(const HomeScreen(), locale: locale),
);

Widget _approvedDevice() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) => PairingViewState(
        stage: PairingViewStage.success,
        context: fixtureContext(),
      ),
    ),
    localeControllerProvider.overrideWithBuild(
      (ref, notifier) => WafloLocales.english,
    ),
  ],
  child: _app(const PairingFlowScreen()),
);

Widget _pairingWelcome({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) => const PairingViewState.welcome(),
    ),
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
  ],
  child: _app(const PairingFlowScreen(), locale: locale),
);

Widget _settings({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
    themeControllerProvider.overrideWithBuild(
      (ref, notifier) => ThemeMode.system,
    ),
    rapidScanControllerProvider.overrideWithBuild((ref, notifier) => true),
    environmentProvider.overrideWithValue(
      AppEnvironment(
        flavor: AppFlavor.development,
        apiBaseUrl: Uri.parse('http://10.0.2.2:3000'),
        pairingEnvironment: 'development',
        logLevel: AppLogLevel.debug,
        allowTestAdapter: true,
        minimumVersionSource: 'backend',
        crashReportingEnabled: false,
        certificatePinningEnabled: false,
      ),
    ),
    packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
  ],
  child: _app(const SettingsScreen(), locale: locale),
);

Widget _app(Widget child, {Locale locale = WafloLocales.english}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: WafloLocales.selectable,
      localizationsDelegates: wafloLocalizationDelegates,
      theme: WafloTheme.light(locale: locale),
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: child,
      ),
    );

final _packageInfo = PackageInfo(
  appName: 'Waflo Staff',
  packageName: 'app.waflo.staff',
  version: '2.4.0',
  buildNumber: '240',
);

final _unavailableContext = AuthoritativeDeviceContext(
  organization: const OrganizationContext(publicId: 'org', displayName: ''),
  staff: const StaffContext(publicId: 'staff', displayName: '', role: 'STAFF'),
  device: const DeviceContextSummary(
    publicId: 'device',
    displayName: 'Counter phone',
    status: 'ACTIVE',
    platform: 'ANDROID',
    appVersion: '2.4.0',
  ),
  currentLocation: const LocationContext(
    publicId: 'location',
    displayName: '',
    earningAllowed: false,
    redemptionAllowed: false,
    capabilitiesKnown: false,
  ),
  assignedLocations: const [],
  appPolicy: const AppUpdatePolicy(
    minimumSupportedVersion: '1.0.0',
    updateRequired: false,
  ),
  requestId: 'request',
  synchronizedAt: DateTime.utc(2026, 8, 21, 12),
);
