import 'package:flutter/foundation.dart';
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
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';
import 'package:waflo_staff/features/review_access/presentation/review_tools_screen.dart';
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

  testWidgets('tablet and resizable iPad review screenshots', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _capture(
      tester,
      '01-pairing-narrow-window',
      const Size(520, 900),
      _pairing(const PairingViewState.welcome()),
    );
    await _capture(
      tester,
      '02-pairing-portrait',
      const Size(810, 1080),
      _pairing(const PairingViewState.welcome()),
    );
    await _capture(
      tester,
      '03-pairing-landscape-ltr',
      const Size(1366, 1024),
      _pairing(const PairingViewState.welcome()),
    );
    await _capture(
      tester,
      '04-pairing-landscape-rtl',
      const Size(1366, 1024),
      _pairing(const PairingViewState.welcome(), locale: WafloLocales.arabic),
    );
    final scanner = _FixturePairingScannerAdapter();
    addTearDown(scanner.dispose);
    await _capture(
      tester,
      '05-scanner-landscape',
      const Size(1366, 1024),
      _pairing(
        const PairingViewState(stage: PairingViewStage.scanner),
        adapter: scanner,
      ),
    );
    await _capture(
      tester,
      '06-home-landscape',
      const Size(1366, 1024),
      _home(),
    );
    await _capture(
      tester,
      '07-settings-landscape-rtl',
      const Size(1366, 1024),
      _settings(locale: WafloLocales.arabic),
    );
    await _capture(
      tester,
      '08-device-security-portrait',
      const Size(810, 1080),
      _deviceSecurity(locale: WafloLocales.badini),
    );
    await _capture(
      tester,
      '09-pin-setup-landscape',
      const Size(1366, 1024),
      _pinSetup(),
    );
    await _capture(
      tester,
      '10-review-tools-landscape',
      const Size(1366, 1024),
      _reviewTools(),
      settle: true,
    );
  });

  testWidgets('compact Pairing remains pixel compatible', (tester) async {
    await _expectPhoneGolden(
      tester,
      _pairing(const PairingViewState.welcome()),
      '../../artifacts/ui-review/12-pairing-english.png',
    );
  });

  testWidgets('compact Settings remains pixel compatible', (tester) async {
    await _expectPhoneGolden(
      tester,
      _settings(),
      '../../artifacts/ui-review/16-settings-screen.png',
    );
  });

  testWidgets('compact PIN setup remains pixel compatible', (tester) async {
    await _expectPhoneGolden(
      tester,
      _pinSetup(),
      '../../artifacts/ui-review/18-pin-create-screen.png',
    );
  });
}

Future<void> _expectPhoneGolden(
  WidgetTester tester,
  Widget widget,
  String golden,
) async {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(widget);
  await tester.pump(const Duration(milliseconds: 220));
  final exception = tester.takeException();
  if (exception != null) throw TestFailure('compact layout failed: $exception');
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
}

Future<void> _capture(
  WidgetTester tester,
  String name,
  Size size,
  Widget widget, {
  bool settle = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(widget);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 220));
  }
  final exception = tester.takeException();
  if (exception != null) throw TestFailure('$name layout failed: $exception');
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../artifacts/tablet-review/$name.png'),
  );
}

Widget _pairing(
  PairingViewState state, {
  Locale locale = WafloLocales.english,
  PairingScannerAdapter? adapter,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild((ref, notifier) => state),
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
    if (adapter != null)
      pairingScannerAdapterProvider.overrideWithValue(adapter),
  ],
  child: _app(const PairingFlowScreen(), locale: locale),
);

Widget _home() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => BootState(
        stage: BootStage.pairedReady,
        context: fixtureContext(),
        session: fixtureSession(),
      ),
    ),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
  ],
  child: _app(const HomeScreen()),
);

Widget _settings({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
    themeControllerProvider.overrideWithBuild(
      (ref, notifier) => ThemeMode.system,
    ),
    rapidScanControllerProvider.overrideWithBuild((ref, notifier) => true),
    environmentProvider.overrideWithValue(_environment),
    packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
  ],
  child: _app(const SettingsScreen(), locale: locale),
);

Widget _deviceSecurity({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(mode: AppLockMode.pin),
        status: AppLockStatus.unlocked,
      ),
    ),
    packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
  ],
  child: _app(const DeviceSecurityScreen(), locale: locale),
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

Widget _reviewTools() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    reviewAccessRepositoryProvider.overrideWithValue(const _ReviewRepository()),
  ],
  child: _app(const ReviewToolsScreen()),
);

Widget _app(Widget child, {Locale locale = WafloLocales.english}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: WafloLocales.selectable,
      localizationsDelegates: wafloLocalizationDelegates,
      theme: WafloTheme.light(locale: locale),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child,
        ),
      ),
    );

final _environment = AppEnvironment(
  flavor: AppFlavor.development,
  apiBaseUrl: Uri.parse('http://127.0.0.1:3000'),
  pairingEnvironment: 'development',
  logLevel: AppLogLevel.debug,
  allowTestAdapter: true,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
  expectedNativeFlavor: AppFlavor.development,
);

final _packageInfo = PackageInfo(
  appName: 'Waflo Staff',
  packageName: 'app.waflo.staff.dev',
  version: '2.4.0',
  buildNumber: '240',
);

final class _FixturePairingScannerAdapter implements PairingScannerAdapter {
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.ready,
  );
  final ValueNotifier<bool> _torch = ValueNotifier(false);

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torch;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => const ColoredBox(color: Color(0xFF181312));

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

final class _ReviewRepository implements ReviewAccessRepository {
  const _ReviewRepository();

  static const scenariosFixture = [
    ReviewScenarioSummary(
      id: ReviewScenario.customerNew,
      progress: 0,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'VALID',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.customerActive,
      progress: 5,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'VALID',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.customerRewardReady,
      progress: 8,
      goal: 8,
      rewardReady: true,
      credentialStatus: 'VALID',
    ),
  ];

  @override
  Future<int> reset() async => scenariosFixture.length;

  @override
  Future<List<ReviewScenarioSummary>> scenarios() async => scenariosFixture;

  @override
  Future<ReviewScenarioSummary> select(ReviewScenario scenario) async =>
      scenariosFixture.firstWhere((item) => item.id == scenario);
}
