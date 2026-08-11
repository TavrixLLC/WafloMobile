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
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'M3AReviewSans',
    )..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))).load();
    await (FontLoader(
          'M3AReviewArabic',
        )..addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget widget, {
    Finder? reveal,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    if (reveal != null) {
      await tester.scrollUntilVisible(
        reveal,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
    }
    final exception = tester.takeException();
    if (exception != null) {
      final detail = exception is FlutterError
          ? exception.toStringDeep()
          : exception.toString();
      throw TestFailure('$name failed to lay out:\n$detail');
    }
    if (!Platform.isLinux) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../artifacts/handoff-m3a/screenshots/$name.png'),
      );
    }
  }

  testWidgets('M3A 26-screen executable review set', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-home-en-light', _home());
    await capture(
      tester,
      '02-home-ar-rtl-light',
      _home(locale: const Locale('ar')),
    );
    await capture(tester, '03-home-dark', _home(themeMode: ThemeMode.dark));
    await capture(
      tester,
      '04-scanner-ready',
      _scanner(CustomerScannerState.ready),
    );
    await capture(
      tester,
      '05-scanner-resolving',
      _scanner(CustomerScannerState.resolving),
    );
    await capture(tester, '06-customer-membership-0-of-8', _ready(0));
    await capture(tester, '07-customer-membership-5-of-8', _ready(5));
    await capture(tester, '08-customer-membership-8-of-8', _ready(8));
    await capture(
      tester,
      '09-add-stamps',
      _ready(2),
      reveal: find.byKey(const Key('purchase-amount-field')),
    );

    final membership = _membership(2);
    const stampInput = StampOperationInput(
      amount: 1,
      purchaseAmountMinor: 10000,
      purchaseCurrency: 'IQD',
      merchantTransactionReference: 'ORDER-1042',
    );
    await capture(
      tester,
      '10-stamp-confirmation',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampReview,
          membership: membership,
          stampInput: stampInput,
          credentialAvailable: true,
        ),
      ),
      reveal: find.text('Confirm stamp issuance'),
    );
    await capture(
      tester,
      '11-stamp-success',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampSucceeded,
          membership: membership,
          stampResult: StampOperationResult.fromJson(
            _fixture('stamp-success.fixture.json'),
          ),
        ),
      ),
    );
    await capture(tester, '12-reward-ready', _ready(8));

    final finalMembership = _membership(8);
    await capture(
      tester,
      '13-redeem-confirmation',
      _operation(
        M2OperationState(
          stage: M2OperationStage.redemptionReview,
          membership: finalMembership,
          selectedReward: finalMembership.availableRewards.single,
          credentialAvailable: true,
        ),
      ),
      reveal: find.text('Confirm redemption'),
    );
    await capture(
      tester,
      '14-redeem-success-final-reset',
      _operation(
        M2OperationState(
          stage: M2OperationStage.redemptionSucceeded,
          membership: finalMembership,
          redemptionResult: RedemptionOperationResult.fromJson(
            _fixture('redeem-final-reset.fixture.json'),
          ),
        ),
      ),
    );
    await capture(
      tester,
      '15-checking-transaction',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampAmbiguous,
          pendingOperation: _pending,
        ),
      ),
    );
    await capture(
      tester,
      '16-device-revoked',
      _blocked(BootStage.deviceRevoked),
    );
    await capture(
      tester,
      '17-device-compromised',
      _blocked(BootStage.deviceCompromised),
    );
    await capture(
      tester,
      '18-session-expired',
      _blocked(BootStage.sessionExpired),
    );
    await capture(tester, '19-offline', _home(online: false));
    await capture(
      tester,
      '20-update-required-http-426',
      _blocked(BootStage.appUpdateRequired),
    );
    await capture(tester, '21-device-and-security', _deviceSecurity());
    await capture(tester, '22-app-lock', _appLock());
    await capture(
      tester,
      '23-large-text-home',
      _home(textScaler: const TextScaler.linear(2)),
    );
    await capture(
      tester,
      '24-large-text-customer',
      _ready(5, textScaler: const TextScaler.linear(2)),
    );
    await capture(
      tester,
      '25-arabic-customer-5-of-8',
      _ready(5, locale: const Locale('ar'), arabicFixture: true),
    );
    await capture(
      tester,
      '26-arabic-reward-ready-redeem',
      _ready(8, locale: const Locale('ar'), arabicFixture: true),
      reveal: find.byKey(const Key('reward-ready-outside-grid')),
    );
  });
}

Widget _home({
  bool online = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  PendingOperationRecord? pending,
}) => ProviderScope(
  key: UniqueKey(),
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
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const HomeScreen(),
  ),
);

Widget _scanner(CustomerScannerState scannerState) => _operation(
  const M2OperationState(stage: M2OperationStage.scanning),
  scanner: FixtureCustomerScannerAdapter(
    _syntheticCredential,
    autoDeliver: false,
    initialState: scannerState,
  ),
);

Widget _ready(
  int progress, {
  bool online = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool arabicFixture = false,
}) => _operation(
  M2OperationState(
    stage: M2OperationStage.membershipReady,
    membership: _membership(progress, arabic: arabicFixture),
    credentialAvailable: true,
  ),
  online: online,
  locale: locale,
  themeMode: themeMode,
  textScaler: textScaler,
);

Widget _operation(
  M2OperationState state, {
  bool online = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  CustomerScannerAdapter? scanner,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    m2OperationControllerProvider.overrideWithBuild((ref, notifier) => state),
    connectivityProvider.overrideWithValue(AsyncData(online)),
    customerScannerAdapterProvider.overrideWithValue(
      scanner ??
          FixtureCustomerScannerAdapter(
            _syntheticCredential,
            autoDeliver: false,
          ),
    ),
    stampImageCacheProvider.overrideWithValue(const _FixtureImageLoader()),
  ],
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const LoyaltyOperationScreen(),
  ),
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

Widget _deviceSecurity() => ProviderScope(
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
  child: _app(child: const DeviceSecurityScreen()),
);

Widget _appLock() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    appLockControllerProvider.overrideWithBuild(
      (ref, notifier) => const AppLockState(
        configuration: AppLockConfiguration(
          mode: AppLockMode.pin,
          interval: AppLockInterval.oneMinute,
        ),
        status: AppLockStatus.locked,
      ),
    ),
  ],
  child: _app(child: const AppLockOverlay()),
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
  theme: _reviewTheme(WafloTheme.light()),
  darkTheme: _reviewTheme(WafloTheme.dark()),
  themeMode: themeMode,
  home: MediaQuery(
    data: MediaQueryData(textScaler: textScaler),
    child: child,
  ),
);

ThemeData _reviewTheme(ThemeData base) {
  TextStyle? style(TextStyle? value) => value?.copyWith(
    fontFamily: 'M3AReviewSans',
    fontFamilyFallback: const ['M3AReviewArabic'],
  );

  final source = base.textTheme;
  final text = source.copyWith(
    displayLarge: style(source.displayLarge),
    displayMedium: style(source.displayMedium),
    displaySmall: style(source.displaySmall),
    headlineLarge: style(source.headlineLarge),
    headlineMedium: style(source.headlineMedium),
    headlineSmall: style(source.headlineSmall),
    titleLarge: style(source.titleLarge),
    titleMedium: style(source.titleMedium),
    titleSmall: style(source.titleSmall),
    bodyLarge: style(source.bodyLarge),
    bodyMedium: style(source.bodyMedium),
    bodySmall: style(source.bodySmall),
    labelLarge: style(source.labelLarge),
    labelMedium: style(source.labelMedium),
    labelSmall: style(source.labelSmall),
  );
  final label = WidgetStatePropertyAll<TextStyle?>(text.labelLarge);
  return base.copyWith(
    textTheme: text,
    primaryTextTheme: text,
    appBarTheme: base.appBarTheme.copyWith(titleTextStyle: text.titleLarge),
    filledButtonTheme: FilledButtonThemeData(
      style: base.filledButtonTheme.style?.copyWith(textStyle: label),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style?.copyWith(textStyle: label),
    ),
    textButtonTheme: TextButtonThemeData(
      style: base.textButtonTheme.style?.copyWith(textStyle: label),
    ),
  );
}

ResolvedMembership _membership(int progress, {bool arabic = false}) {
  final value = _fixture('membership-resolve.fixture.json');
  final limits = value['operationLimits']! as Map<String, Object?>;
  value['customerDisplayName'] = arabic ? 'ليان السعد' : 'Lina Saad';
  value['programName'] = arabic ? 'مكافآت القهوة' : 'Counter Coffee Rewards';
  value['locale'] = arabic ? 'ar' : 'en';
  value['progress'] = progress;
  value['rewardReady'] = progress == 8;
  value['projectionVersion'] = progress + 1;
  limits['dailyRemainingStamps'] = (8 - progress).clamp(0, 4);
  if (progress < 4) {
    value['availableRewards'] = <Object?>[];
  } else if (progress == 8) {
    value['availableRewards'] = [
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
        'requiresManagerApproval': false,
      },
    ];
  }
  return ResolvedMembership.fromJson(
    value,
    allowInsecureAssets: false,
    receivedAt: DateTime(2026, DateTime.august, 11, 13, 15),
  );
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

final class _FixtureImageLoader implements StampImageLoader {
  const _FixtureImageLoader();

  @override
  String cacheKey(String digest) => digest.toLowerCase();

  @override
  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  }) async => throw StateError('Fixture uses the safe two-state fallback.');
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

final _pending = PendingOperationRecord(
  commandId: '20000000-0000-4000-8000-000000000001',
  operationType: PendingOperationType.stamp,
  membershipPublicId: 'mem_fixture_not_a_credential',
  stampAmount: 1,
  createdAt: DateTime.utc(2026, 8, 11, 12),
  lastCheckedAt: null,
  status: PendingOperationStatus.processing,
);

const _syntheticCredential =
    'customer-membership-credential-fixture-000000000000000000000000';
