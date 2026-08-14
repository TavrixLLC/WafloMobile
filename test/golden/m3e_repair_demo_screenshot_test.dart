import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_navigation.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls_debug.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_scenarios_screen.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
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

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget widget, {
    Future<void> Function()? prepare,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(widget);
    await tester.pump(const Duration(milliseconds: 180));
    if (prepare != null) await prepare();
    final exception = tester.takeException();
    if (exception != null) throw TestFailure('$name layout failed: $exception');
    if (!Platform.isLinux) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../artifacts/handoff-m3e-repair-demo-access/screenshots/$name.png',
        ),
      );
    }
  }

  testWidgets('M3E repaired local Demo Access visual review set', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-demo-access-en', _demoAccess());
    await capture(
      tester,
      '02-demo-access-ar',
      _demoAccess(locale: const Locale('ar')),
    );
    await capture(tester, '03-demo-scenarios', _scenarioHub());
    await capture(
      tester,
      '04-demo-scenarios-ar-dark-large',
      _scenarioHub(
        locale: const Locale('ar'),
        themeMode: ThemeMode.dark,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await capture(tester, '05-demo-home', _home());
    await capture(
      tester,
      '06-demo-scanner-controls',
      _scanner(),
      prepare: () async {
        await tester.tap(find.byKey(const Key('local-demo-scanner-controls')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
      },
    );
  });
}

Widget _demoAccess({Locale locale = const Locale('en')}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    localDemoControllerProvider.overrideWithBuild(
      (ref, notifier) => const LocalDemoState(),
    ),
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          const PairingViewState(stage: PairingViewStage.localDemoIntro),
    ),
  ],
  child: _app(locale: locale, child: const PairingFlowScreen()),
);

Widget _scenarioHub({
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    localDemoControllerProvider.overrideWithBuild(
      (ref, notifier) => const LocalDemoState(
        status: LocalDemoStatus.active,
        scenario: LocalDemoScenario.home,
      ),
    ),
  ],
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const LocalDemoScenariosScreen(),
  ),
);

Widget _home() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    localDemoControllerProvider.overrideWithBuild(
      (ref, notifier) => const LocalDemoState(status: LocalDemoStatus.active),
    ),
    localDemoScenarioRouteProvider.overrideWithValue('/demo-scenarios'),
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => const BootState(stage: BootStage.unpaired),
    ),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
  ],
  child: _app(child: const HomeScreen()),
);

Widget _scanner() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    localDemoControllerProvider.overrideWithBuild(
      (ref, notifier) => const LocalDemoState(
        status: LocalDemoStatus.active,
        scenario: LocalDemoScenario.scannerReady,
      ),
    ),
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          const M2OperationState(stage: M2OperationStage.scanning),
    ),
    customerScannerAdapterProvider.overrideWithValue(
      FixtureCustomerScannerAdapter(
        'local-demo-fixture-not-rendered',
        autoDeliver: false,
        initialState: CustomerScannerState.ready,
      ),
    ),
    localDemoScannerControlsBuilderProvider.overrideWithValue(
      () => const DebugLocalDemoScannerControls(),
    ),
  ],
  child: _app(child: const LoyaltyOperationScreen()),
);

Widget _app({
  required Widget child,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  theme: WafloTheme.light(locale: locale),
  darkTheme: WafloTheme.dark(locale: locale),
  themeMode: themeMode,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: textScaler),
    child: child!,
  ),
  home: child,
);

final _environment = AppEnvironment(
  flavor: AppFlavor.staging,
  apiBaseUrl: Uri.parse('https://api-staging.waflo.app'),
  pairingEnvironment: 'test',
  logLevel: AppLogLevel.info,
  allowTestAdapter: false,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
  localDemoRequested: true,
  expectedNativeFlavor: AppFlavor.staging,
  suppliedDartEnvironment: 'staging',
);
