import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_scenarios_screen.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';
import 'package:waflo_staff/features/review_access/presentation/review_tools_screen.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

const _iPadPortrait = Size(810, 1080);
const _iPadProLandscape = Size(1366, 1024);
const _androidPortrait = Size(800, 1280);
const _androidLandscape = Size(1280, 800);
const _narrowIpadWindow = Size(520, 900);
const _mediumIpadWindow = Size(744, 900);
const _phone = Size(390, 844);

void main() {
  testWidgets('Home uses a bounded tablet workspace in both orientations', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_iPadPortrait, _androidLandscape]) {
      await _pumpAt(tester, size, _homeHarness());

      final content = find.byKey(const Key('waflo-responsive-content'));
      expect(content, findsOneWidget);
      expect(
        tester.getSize(content).width,
        lessThanOrEqualTo(WafloLayout.maximumWideContentWidth),
      );
      final scan = find.byKey(const Key('home-primary-pane'));
      final controls = find.byKey(const Key('home-control-pane'));
      expect(scan, findsOneWidget);
      expect(controls, findsOneWidget);
      if (size.width < WafloLayout.wideBreakpoint) {
        expect(tester.getTopLeft(scan).dx, tester.getTopLeft(controls).dx);
        expect(tester.getSize(scan).width, lessThanOrEqualTo(760));
      } else {
        expect(
          tester.getTopLeft(scan).dx,
          isNot(tester.getTopLeft(controls).dx),
        );
        expect(tester.getSize(scan).width, lessThanOrEqualTo(720));
      }
      expect(find.byKey(const Key('home-device-security')), findsOneWidget);
      expect(find.byKey(const Key('home-settings')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });

  testWidgets('RTL Home mirrors the tablet workspace without overflow', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    await _pumpAt(
      tester,
      _iPadProLandscape,
      _homeHarness(locale: WafloLocales.sorani),
    );

    final home = find.byKey(const Key('task-first-home'));
    expect(Directionality.of(tester.element(home)), TextDirection.rtl);
    expect(
      tester.getTopLeft(find.byKey(const Key('primary-scan-customer'))).dx,
      greaterThan(
        tester.getTopLeft(find.byKey(const Key('home-device-security'))).dx,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings, Device & Security, and dialog stay bounded in RTL', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    await _pumpAt(
      tester,
      _iPadProLandscape,
      _settingsHarness(locale: WafloLocales.arabic),
    );
    var content = find.byKey(const Key('waflo-responsive-content'));
    expect(tester.getSize(content).width, lessThanOrEqualTo(1120));
    expect(Directionality.of(tester.element(content)), TextDirection.rtl);
    final preferences = find.byKey(const Key('settings-preferences-pane'));
    final system = find.byKey(const Key('settings-system-pane'));
    expect(preferences, findsOneWidget);
    expect(system, findsOneWidget);
    expect(
      tester.getTopLeft(preferences).dx,
      greaterThan(tester.getTopLeft(system).dx),
    );
    expect(tester.takeException(), isNull);

    await _pumpAt(
      tester,
      _androidPortrait,
      _deviceSecurityHarness(locale: WafloLocales.badini),
    );
    content = find.byKey(const Key('waflo-responsive-content'));
    expect(tester.getSize(content).width, lessThanOrEqualTo(800));
    expect(Directionality.of(tester.element(content)), TextDirection.rtl);
    expect(find.byKey(const Key('device-identity-pane')), findsOneWidget);
    expect(find.byKey(const Key('device-policy-pane')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('sign-out')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('sign-out')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpAt(
      tester,
      _iPadProLandscape,
      _deviceSecurityHarness(locale: WafloLocales.arabic),
    );
    final identity = find.byKey(const Key('device-identity-pane'));
    final policy = find.byKey(const Key('device-policy-pane'));
    expect(identity, findsOneWidget);
    expect(policy, findsOneWidget);
    expect(
      tester.getTopLeft(identity).dx,
      greaterThan(tester.getTopLeft(policy).dx),
    );
    expect(find.byKey(const Key('device-actions-group')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pairing follows compact, medium, and wide resize classes', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_phone, _narrowIpadWindow]) {
      await _pumpAt(
        tester,
        size,
        _pairingHarness(const PairingViewState.welcome()),
      );
      expect(find.byKey(const Key('waflo-adaptive-compact')), findsOneWidget);
      expect(find.byKey(const Key('pairing-security-rail')), findsNothing);
      expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '$size');
    }

    await _pumpAt(
      tester,
      _mediumIpadWindow,
      _pairingHarness(const PairingViewState.welcome()),
    );
    expect(find.byKey(const Key('waflo-adaptive-medium')), findsOneWidget);
    expect(find.byKey(const Key('pairing-security-rail')), findsOneWidget);
    final mediumWorkspace = find.byKey(const Key('pairing-medium-workspace'));
    final mediumActions = find.byKey(const Key('pairing-actions-group'));
    expect(tester.getSize(mediumWorkspace).width, lessThanOrEqualTo(640));
    expect(tester.getSize(mediumActions).width, lessThanOrEqualTo(420));
    expect(
      tester.getCenter(mediumActions).dx,
      closeTo(tester.getCenter(mediumWorkspace).dx, 1),
    );
    expect(
      tester.getCenter(mediumWorkspace).dy,
      closeTo(_mediumIpadWindow.height / 2, 32),
    );
    expect(
      tester.getBottomRight(mediumActions).dy,
      lessThan(_mediumIpadWindow.height * .75),
    );
    expect(tester.takeException(), isNull);

    await _pumpAt(
      tester,
      _iPadProLandscape,
      _pairingHarness(
        const PairingViewState.welcome(),
        locale: WafloLocales.sorani,
      ),
    );
    expect(find.byKey(const Key('waflo-adaptive-wide')), findsOneWidget);
    final workspace = find.byKey(const Key('pairing-wide-workspace'));
    final introduction = find.byKey(const Key('pairing-introduction-pane'));
    final actions = find.byKey(const Key('pairing-action-pane'));
    final divider = find.byKey(const Key('pairing-workspace-divider'));
    expect(workspace, findsOneWidget);
    expect(introduction, findsOneWidget);
    expect(actions, findsOneWidget);
    expect(divider, findsOneWidget);
    expect(tester.getSize(workspace).width, lessThanOrEqualTo(980));
    expect(
      tester.getCenter(workspace).dx,
      closeTo(_iPadProLandscape.width / 2, 1),
    );
    expect(
      tester.getTopLeft(introduction).dx,
      greaterThan(tester.getTopLeft(actions).dx),
    );
    expect(
      tester.getTopLeft(introduction).dx - tester.getTopRight(actions).dx,
      inInclusiveRange(40, 64),
    );
    expect(
      tester.getCenter(introduction).dy,
      closeTo(tester.getCenter(actions).dy, 1),
    );
    expect(
      tester.getSize(find.byKey(const Key('scan-pairing-code'))).width,
      lessThanOrEqualTo(480),
    );
    await tester.tap(find.byKey(const Key('pairing-language-control')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const Key('pairing-language-sheet-content')))
          .width,
      lessThanOrEqualTo(680),
    );
    expect(
      Directionality.of(
        tester.element(find.byKey(const Key('pairing-language-ckb'))),
      ),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pairing portrait stays grouped on iPad and Android tablets', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_iPadPortrait, _androidPortrait]) {
      await _pumpAt(
        tester,
        size,
        _pairingHarness(const PairingViewState.welcome()),
      );
      final workspace = find.byKey(const Key('pairing-medium-workspace'));
      final actions = find.byKey(const Key('pairing-actions-group'));

      expect(find.byKey(const Key('waflo-adaptive-medium')), findsOneWidget);
      expect(tester.getSize(workspace).width, lessThanOrEqualTo(640));
      expect(tester.getCenter(workspace).dx, closeTo(size.width / 2, 1));
      expect(tester.getCenter(workspace).dy, closeTo(size.height / 2, 64));
      expect(tester.getBottomRight(actions).dy, lessThan(size.height * .7));
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });

  testWidgets('Pairing wide workspace mirrors across all supported scripts', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_iPadProLandscape, _androidLandscape]) {
      for (final locale in WafloLocales.selectable) {
        await _pumpAt(
          tester,
          size,
          _pairingHarness(const PairingViewState.welcome(), locale: locale),
        );
        final workspace = find.byKey(const Key('pairing-wide-workspace'));
        final introduction = find.byKey(const Key('pairing-introduction-pane'));
        final actions = find.byKey(const Key('pairing-action-pane'));
        final isRtl = WafloLocales.usesArabicScript(locale);
        final reason = '${size.width}x${size.height} ${locale.toLanguageTag()}';

        expect(
          Directionality.of(tester.element(workspace)),
          isRtl ? TextDirection.rtl : TextDirection.ltr,
          reason: reason,
        );
        expect(
          tester.getCenter(introduction).dx,
          isRtl
              ? greaterThan(tester.getCenter(actions).dx)
              : lessThan(tester.getCenter(actions).dx),
          reason: reason,
        );
        expect(
          tester.getCenter(workspace).dx,
          closeTo(size.width / 2, 1),
          reason: reason,
        );
        expect(tester.takeException(), isNull, reason: reason);
      }
    }
  });

  testWidgets('manual pairing and scanner controls remain tablet-sized', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    await _pumpAt(
      tester,
      _androidLandscape,
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.manualEntry),
        locale: WafloLocales.arabic,
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('waflo-page-content'))).width,
      lessThanOrEqualTo(WafloLayout.maximumFormWidth),
    );
    expect(find.byKey(const Key('manual-code-input')), findsOneWidget);
    expect(find.byKey(const Key('manual-code-continue')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final adapter = _PairingFixtureAdapter();
    addTearDown(adapter.dispose);
    await _pumpAt(
      tester,
      _iPadPortrait,
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.scanner),
        adapter: adapter,
      ),
    );
    expect(
      find.byKey(const Key('scanner-compact-control-deck')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await _pumpAt(
      tester,
      _iPadProLandscape,
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.scanner),
        adapter: adapter,
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('scanner-controls-content'))).width,
      lessThanOrEqualTo(WafloLayout.maximumWideContentWidth),
    );
    expect(
      find.byKey(const Key('professional-scanner-overlay')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('manual-code-entry')), findsOneWidget);
    expect(find.byKey(const Key('scanner-wide-control-deck')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PIN keypad stays compact on iPad and Android landscape', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_iPadPortrait, _androidLandscape]) {
      await _pumpAt(tester, size, _pinSetupHarness());
      expect(
        tester.getSize(find.byKey(const Key('pin-setup-keypad'))).width,
        lessThanOrEqualTo(420),
      );
      if (size.width >= WafloLayout.wideBreakpoint) {
        expect(find.byKey(const Key('pin-security-pane')), findsOneWidget);
      } else {
        expect(find.byKey(const Key('waflo-adaptive-medium')), findsOneWidget);
      }
      expect(tester.takeException(), isNull, reason: '$size');
    }

    await _pumpAt(tester, _iPadProLandscape, _lockOverlayHarness());
    expect(tester.getSize(find.byType(GridView)).width, lessThanOrEqualTo(420));
    expect(find.byKey(const Key('unlock-security-pane')), findsOneWidget);
    expect(find.byKey(const Key('unlock-controls-pane')), findsOneWidget);
    expect(find.byKey(const Key('unlock-with-pin')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('App Lock settings split modes from timeout controls when wide', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    await _pumpAt(tester, _iPadProLandscape, _appLockSettingsHarness());
    final modes = find.byKey(const Key('app-lock-modes-pane'));
    final interval = find.byKey(const Key('app-lock-interval-pane'));
    expect(modes, findsOneWidget);
    expect(interval, findsOneWidget);
    expect(
      tester.getTopLeft(modes).dx,
      lessThan(tester.getTopLeft(interval).dx),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('membership form and confirmation are bounded on tablets', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    final membership = _membership();
    await _pumpAt(
      tester,
      _androidPortrait,
      _loyaltyHarness(
        M2OperationState(
          stage: M2OperationStage.membershipReady,
          membership: membership,
          credentialAvailable: true,
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const Key('waflo-responsive-content'))).width,
      lessThanOrEqualTo(680),
    );
    expect(find.byKey(const Key('purchase-amount-field')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pumpAt(
      tester,
      _iPadProLandscape,
      _loyaltyHarness(
        M2OperationState(
          stage: M2OperationStage.stampReview,
          membership: membership,
          credentialAvailable: true,
          stampInput: const StampOperationInput(
            amount: 1,
            purchaseAmountMinor: 10000,
            purchaseCurrency: 'IQD',
          ),
        ),
        locale: WafloLocales.arabic,
      ),
    );
    expect(find.byKey(const Key('operation-confirmation')), findsOneWidget);
    expect(
      tester.getSize(find.byType(WafloSurfaceCard).first).width,
      lessThanOrEqualTo(680),
    );
    expect(
      Directionality.of(
        tester.element(find.byKey(const Key('operation-confirmation'))),
      ),
      TextDirection.rtl,
    );
    expect(find.byKey(const Key('confirm-operation')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('review tools remain readable in tablet portrait and landscape', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    for (final size in [_iPadPortrait, _androidLandscape]) {
      await _pumpAt(tester, size, _reviewToolsHarness());
      await tester.pumpAndSettle();
      final content = find.byKey(const Key('waflo-responsive-content'));
      expect(
        tester.getSize(content).width,
        lessThanOrEqualTo(WafloLayout.maximumWideContentWidth),
      );
      expect(find.byKey(const Key('review-scenarios-pane')), findsOneWidget);
      expect(find.byKey(const Key('review-actions-pane')), findsOneWidget);
      if (size.width >= WafloLayout.wideBreakpoint) {
        expect(
          tester.getTopLeft(find.byKey(const Key('review-scenarios-pane'))).dx,
          greaterThan(
            tester.getTopLeft(find.byKey(const Key('review-actions-pane'))).dx,
          ),
        );
      }
      expect(tester.takeException(), isNull, reason: '$size');
    }
  });

  testWidgets('Demo review scenario groups adapt from one to two columns', (
    tester,
  ) async {
    _resetViewAfterTest(tester);
    await _pumpAt(tester, _androidPortrait, _localDemoHarness());
    expect(find.byKey(const Key('scenario-groups-wide')), findsNothing);
    expect(tester.takeException(), isNull);

    await _pumpAt(tester, _androidLandscape, _localDemoHarness());
    final primary = find.byKey(const Key('scenario-groups-primary'));
    final secondary = find.byKey(const Key('scenario-groups-secondary'));
    expect(primary, findsOneWidget);
    expect(secondary, findsOneWidget);
    expect(
      tester.getTopLeft(primary).dx,
      lessThan(tester.getTopLeft(secondary).dx),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAt(WidgetTester tester, Size size, Widget widget) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(widget);
  await tester.pump();
}

void _resetViewAfterTest(WidgetTester tester) {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _app(Widget child, {Locale locale = WafloLocales.english}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: WafloLocales.selectable,
      localizationsDelegates: wafloLocalizationDelegates,
      theme: WafloTheme.light(locale: locale),
      home: child,
    );

Widget _homeHarness({Locale locale = WafloLocales.english}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => BootState(
        stage: BootStage.pairedReady,
        context: fixtureContext(),
        session: fixtureSession(),
      ),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
  ],
  child: _app(const HomeScreen(), locale: locale),
);

Widget _settingsHarness({Locale locale = WafloLocales.english}) =>
    ProviderScope(
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

Widget _deviceSecurityHarness({Locale locale = WafloLocales.english}) =>
    ProviderScope(
      key: UniqueKey(),
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
            configuration: AppLockConfiguration(mode: AppLockMode.pin),
            status: AppLockStatus.unlocked,
          ),
        ),
        packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
      ],
      child: _app(const DeviceSecurityScreen(), locale: locale),
    );

Widget _pairingHarness(
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

Widget _pinSetupHarness() => ProviderScope(
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

Widget _appLockSettingsHarness() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(mode: AppLockMode.pin),
        status: AppLockStatus.unlocked,
      ),
    ),
  ],
  child: _app(const AppLockSettingsScreen()),
);

Widget _lockOverlayHarness() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(mode: AppLockMode.pin),
        status: AppLockStatus.locked,
      ),
    ),
  ],
  child: _app(const AppLockOverlay()),
);

Widget _loyaltyHarness(
  M2OperationState state, {
  Locale locale = WafloLocales.english,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    m2OperationControllerProvider.overrideWithBuild((ref, notifier) => state),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
    environmentProvider.overrideWithValue(_environment),
    stampImageCacheProvider.overrideWithValue(const _FixtureStampImageLoader()),
  ],
  child: _app(const LoyaltyOperationScreen(), locale: locale),
);

Widget _reviewToolsHarness() => ProviderScope(
  key: UniqueKey(),
  overrides: [reviewAccessRepositoryProvider.overrideWithValue(_ReviewRepo())],
  child: _app(const ReviewToolsScreen()),
);

Widget _localDemoHarness() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    localDemoControllerProvider.overrideWithBuild(
      (ref, notifier) => const LocalDemoState(status: LocalDemoStatus.active),
    ),
  ],
  child: _app(const LocalDemoScenariosScreen()),
);

ResolvedMembership _membership() {
  final json =
      jsonDecode(
            File(
              'contracts/w4/m2/membership-resolve.fixture.json',
            ).readAsStringSync(),
          )
          as Map<String, Object?>;
  return ResolvedMembership.fromJson(json, allowInsecureAssets: false);
}

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
  version: '1.0.0',
  buildNumber: '1',
);

final class _FixtureStampImageLoader implements StampImageLoader {
  const _FixtureStampImageLoader();

  @override
  String cacheKey(String digest) => digest.toLowerCase();

  @override
  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  }) async => base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
}

final class _PairingFixtureAdapter implements PairingScannerAdapter {
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
  }) => const ColoredBox(color: Colors.black);

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

final class _ReviewRepo implements ReviewAccessRepository {
  static const values = [
    ReviewScenarioSummary(
      id: ReviewScenario.customerNew,
      progress: 0,
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
  Future<int> reset() async => values.length;

  @override
  Future<List<ReviewScenarioSummary>> scenarios() async => values;

  @override
  Future<ReviewScenarioSummary> select(ReviewScenario scenario) async =>
      values.firstWhere((item) => item.id == scenario);
}
