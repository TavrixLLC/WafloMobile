import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
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
    Duration settle = const Duration(milliseconds: 220),
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(widget);
    await tester.pump();
    final context = tester.element(find.byType(MaterialApp));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/brand/logo/waflo-mark-primary-512.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/brand/logo/waflo-mark-white-1024.png'),
        context,
      );
    });
    await tester.pump(settle);
    final exception = tester.takeException();
    if (exception != null) throw TestFailure('$name layout failed: $exception');
    if (!Platform.isLinux) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../artifacts/m3g-a-plus/flutter-screenshots/$name.png',
        ),
      );
    }
  }

  testWidgets('M3G Direction A+ production presentation matrix', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-pairing-en-light', _pairing());
    await capture(tester, '02-home-en-light', _home());
    await capture(tester, '03-home-ar-rtl', _home(locale: const Locale('ar')));
    await capture(tester, '04-home-dark', _home(themeMode: ThemeMode.dark));
    await capture(
      tester,
      '05-home-large-text',
      _home(textScaler: const TextScaler.linear(2)),
    );
    await capture(
      tester,
      '06-scanner-ready',
      _scanner(CustomerScannerState.ready),
      settle: const Duration(milliseconds: 740),
    );
    await capture(
      tester,
      '07-scanner-detected',
      _scanner(CustomerScannerState.candidateCaptured),
    );
    await capture(
      tester,
      '08-scanner-resolving',
      _scanner(CustomerScannerState.resolving),
    );
    await capture(
      tester,
      '09-scanner-invalid',
      _scanner(CustomerScannerState.invalidQr),
    );
    await capture(
      tester,
      '10-scanner-permission-denied',
      _scanner(CustomerScannerState.cameraPermissionDenied),
    );
    await capture(
      tester,
      '11-scanner-reduced-motion',
      _scanner(CustomerScannerState.ready, disableAnimations: true),
    );
    await capture(tester, '12-customer-0-of-8', _membershipScreen(0));
    await capture(tester, '13-customer-5-of-8', _membershipScreen(5));
    await capture(tester, '14-customer-8-of-8', _membershipScreen(8));
    await capture(
      tester,
      '15-customer-ar-rtl',
      _membershipScreen(5, locale: const Locale('ar'), arabic: true),
    );
    await capture(
      tester,
      '16-customer-dark',
      _membershipScreen(5, themeMode: ThemeMode.dark),
    );
    await capture(
      tester,
      '17-customer-large-text',
      _membershipScreen(5, textScaler: const TextScaler.linear(2)),
    );
    await capture(tester, '18-stamp-confirmation', _stampReview());
    await capture(tester, '19-stamp-success', _stampSuccess());
    await capture(tester, '20-redeem-confirmation', _redemptionReview());
    await capture(
      tester,
      '21-manager-approval-required',
      _approval(ManagerApprovalState.required),
    );
    await capture(
      tester,
      '22-manager-approval-pending',
      _approval(ManagerApprovalState.pending),
    );
    await capture(
      tester,
      '23-manager-approval-rejected',
      _approval(ManagerApprovalState.rejected),
    );
    await capture(
      tester,
      '24-manager-approval-expired',
      _approval(ManagerApprovalState.expired),
    );
    await capture(tester, '25-redeem-success', _redemptionSuccess());
    await capture(tester, '26-pending-recovery', _pendingRecovery());
    await capture(tester, '27-billing-blocked', _billingBlocked());
    await capture(tester, '28-app-lock-pin', _appLock(AppLockMode.pin));
    await capture(
      tester,
      '29-app-lock-biometric',
      _appLock(AppLockMode.biometric),
    );
    await capture(tester, '30-device-security', _deviceSecurity());
    await capture(tester, '31-settings', _settings());
    await capture(
      tester,
      '32-session-expired',
      _blocked(BootStage.sessionExpired),
    );
    await capture(
      tester,
      '33-scanner-ar-rtl',
      _scanner(CustomerScannerState.ready, locale: const Locale('ar')),
    );
    await capture(
      tester,
      '34-scanner-dark',
      _scanner(CustomerScannerState.ready, themeMode: ThemeMode.dark),
    );
    await capture(
      tester,
      '35-scanner-large-text',
      _scanner(
        CustomerScannerState.ready,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await capture(
      tester,
      '36-app-lock-large-text',
      _appLock(AppLockMode.pin, textScaler: const TextScaler.linear(2)),
    );
    await capture(
      tester,
      '37-device-security-large-text',
      _deviceSecurity(textScaler: const TextScaler.linear(2)),
    );
    await capture(
      tester,
      '38-settings-large-text',
      _settings(textScaler: const TextScaler.linear(2)),
    );
  });
}

Widget _pairing() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) => const PairingViewState.welcome(),
    ),
  ],
  child: _app(child: const PairingFlowScreen()),
);

Widget _home({
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
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
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const HomeScreen(),
  ),
);

Widget _scanner(
  CustomerScannerState scannerState, {
  bool disableAnimations = false,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          const M2OperationState(stage: M2OperationStage.scanning),
    ),
    customerScannerAdapterProvider.overrideWithValue(
      FixtureCustomerScannerAdapter(
        'm3g-fixture-not-rendered',
        autoDeliver: false,
        initialState: scannerState,
      ),
    ),
  ],
  child: _app(
    disableAnimations: disableAnimations,
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const LoyaltyOperationScreen(),
  ),
);

Widget _membershipScreen(
  int progress, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool arabic = false,
}) => _operation(
  M2OperationState(
    stage: M2OperationStage.membershipReady,
    membership: _membership(progress, arabic: arabic),
    credentialAvailable: true,
  ),
  locale: locale,
  themeMode: themeMode,
  textScaler: textScaler,
);

Widget _stampReview() {
  final membership = _membership(5);
  return _operation(
    M2OperationState(
      stage: M2OperationStage.stampReview,
      membership: membership,
      stampInput: const StampOperationInput(
        amount: 1,
        purchaseAmountMinor: 6000,
        purchaseCurrency: 'IQD',
        merchantTransactionReference: 'WF-M3G-1042',
      ),
      credentialAvailable: true,
    ),
  );
}

Widget _stampSuccess() => _operation(
  M2OperationState(
    stage: M2OperationStage.stampSucceeded,
    membership: _membership(5),
    stampResult: StampOperationResult.fromJson(
      _fixture('stamp-success.fixture.json'),
    ),
  ),
);

Widget _redemptionReview() {
  final membership = _membership(8);
  return _operation(
    M2OperationState(
      stage: M2OperationStage.redemptionReview,
      membership: membership,
      selectedReward: membership.availableRewards.single,
      credentialAvailable: true,
    ),
  );
}

Widget _approval(ManagerApprovalState approval) {
  final membership = _membership(8, managerApproval: true);
  return _operation(
    M2OperationState(
      stage: M2OperationStage.managerApprovalRequired,
      membership: membership,
      selectedReward: membership.availableRewards.single,
      pendingOperation: _pending(
        approval == ManagerApprovalState.pending
            ? PendingOperationStatus.approvalPending
            : PendingOperationStatus.approvalRequired,
      ),
      managerApprovalState: approval,
    ),
  );
}

Widget _redemptionSuccess() => _operation(
  M2OperationState(
    stage: M2OperationStage.redemptionSucceeded,
    membership: _membership(8),
    redemptionResult: RedemptionOperationResult.fromJson(
      _fixture('redeem-final-reset.fixture.json'),
    ),
  ),
);

Widget _pendingRecovery() => _operation(
  M2OperationState(
    stage: M2OperationStage.redemptionAmbiguous,
    pendingOperation: _pending(PendingOperationStatus.processing),
    failure: const ApiFailure(
      'OPERATION_RESULT_UNKNOWN',
      responseReceived: false,
    ),
  ),
);

Widget _billingBlocked() => _operation(
  M2OperationState(
    stage: M2OperationStage.policyBlocked,
    membership: _membership(5),
    failure: const ApiFailure('OPERATION_BILLING_BLOCKED'),
  ),
);

Widget _appLock(
  AppLockMode mode, {
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => AppLockState(
        configuration: AppLockConfiguration(
          mode: mode,
          interval: AppLockInterval.oneMinute,
        ),
        status: AppLockStatus.locked,
      ),
    ),
  ],
  child: _app(textScaler: textScaler, child: const AppLockOverlay()),
);

Widget _deviceSecurity({TextScaler textScaler = TextScaler.noScaling}) =>
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        activeDeviceContextProvider.overrideWithValue(fixtureContext()),
        appLockControllerProvider.overrideWithBuild(
          (ref, notifier) => const AppLockState(
            configuration: AppLockConfiguration(
              mode: AppLockMode.biometric,
              interval: AppLockInterval.oneMinute,
            ),
            status: AppLockStatus.unlocked,
          ),
        ),
        packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
      ],
      child: _app(textScaler: textScaler, child: const DeviceSecurityScreen()),
    );

Widget _settings({TextScaler textScaler = TextScaler.noScaling}) =>
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        environmentProvider.overrideWithValue(_environment),
        themeControllerProvider.overrideWithBuild(
          (ref, notifier) => ThemeMode.system,
        ),
        rapidScanControllerProvider.overrideWithBuild((ref, notifier) => true),
        packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
      ],
      child: _app(textScaler: textScaler, child: const SettingsScreen()),
    );

Widget _blocked(BootStage stage) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => BootState(stage: stage),
    ),
  ],
  child: _app(
    child: BlockedScreen(state: BootState(stage: stage)),
  ),
);

Widget _operation(
  M2OperationState state, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    activeDeviceContextProvider.overrideWithValue(fixtureContext()),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
    m2OperationControllerProvider.overrideWithBuild((ref, notifier) => state),
    stampImageCacheProvider.overrideWithValue(const _FixtureImageLoader()),
  ],
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const LoyaltyOperationScreen(),
  ),
);

Widget _app({
  required Widget child,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
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
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: textScaler,
      disableAnimations: disableAnimations,
    ),
    child: child,
  ),
);

ResolvedMembership _membership(
  int progress, {
  bool arabic = false,
  bool managerApproval = false,
}) {
  final value = _fixture('membership-resolve.fixture.json');
  final limits = value['operationLimits']! as Map<String, Object?>;
  value['customerDisplayName'] = arabic ? 'ليان السعد' : 'Lina Saad';
  value['programName'] = arabic ? 'مكافآت القهوة' : 'Counter Coffee Rewards';
  value['locale'] = arabic ? 'ar' : 'en';
  value['progress'] = progress;
  value['rewardReady'] = progress == 8;
  value['projectionVersion'] = progress + 1;
  limits['dailyRemainingStamps'] = (8 - progress).clamp(0, 4);
  value['availableRewards'] = progress == 8
      ? <Object?>[
          <String, Object?>{
            'publicId': '40000000-0000-4000-8000-000000000002',
            'finalReward': true,
            'threshold': 8,
            'name': arabic ? 'قهوة من اختيارك' : 'Coffee of your choice',
            'description': arabic
                ? 'مكافأة الدورة المكتملة.'
                : 'A reward for the completed cycle.',
            'status': 'AVAILABLE',
            'redemptionCount': 0,
            'maximumRedemptionCount': 1,
            'expiresAt': null,
            'requiresManagerApproval': managerApproval,
          },
        ]
      : <Object?>[];
  return ResolvedMembership.fromJson(
    value,
    allowInsecureAssets: false,
    receivedAt: DateTime(2026, DateTime.august, 15, 13, 15),
  );
}

PendingOperationRecord _pending(PendingOperationStatus status) =>
    PendingOperationRecord(
      commandId: '20000000-0000-4000-8000-000000000001',
      operationType: PendingOperationType.redemption,
      membershipPublicId: 'm3g-membership-fixture',
      entitlementPublicId: '40000000-0000-4000-8000-000000000002',
      finalReward: true,
      createdAt: DateTime.utc(2026, 8, 15, 12),
      lastCheckedAt: DateTime.utc(2026, 8, 15, 12, 5),
      status: status,
    );

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

final _packageInfo = PackageInfo(
  appName: 'Waflo Staff',
  packageName: 'app.waflo.staff',
  version: '2.4.0',
  buildNumber: '240',
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
  expectedNativeFlavor: AppFlavor.staging,
  suppliedDartEnvironment: 'staging',
);

final class _FixtureImageLoader implements StampImageLoader {
  const _FixtureImageLoader();

  @override
  String cacheKey(String digest) => digest.toLowerCase();

  @override
  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  }) async => throw StateError('M3G goldens use the two-state fallback.');
}
