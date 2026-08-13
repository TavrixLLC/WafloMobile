import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/misc.dart' show Override;
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
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';
import 'package:waflo_staff/features/review_access/presentation/review_access_controller.dart';
import 'package:waflo_staff/features/review_access/presentation/review_tools_screen.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
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
    Future<void> Function(WidgetTester tester)? prepare,
    Duration settle = const Duration(milliseconds: 160),
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
    if (prepare != null) await prepare(tester);
    final exception = tester.takeException();
    if (exception != null) {
      throw TestFailure('$name failed to lay out:\n$exception');
    }
    if (!Platform.isLinux) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../artifacts/handoff-m3e-review-access/screenshots/$name.png',
        ),
      );
    }
  }

  testWidgets('M3E executable Review Access and scanner review matrix', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-pairing-normal-en', _pairing());
    await capture(
      tester,
      '02-pairing-normal-ar',
      _pairing(locale: const Locale('ar')),
    );
    await capture(
      tester,
      '03-review-access-en',
      _pairing(stage: PairingViewStage.reviewAccess),
    );
    await capture(
      tester,
      '04-review-access-ar',
      _pairing(
        stage: PairingViewStage.reviewAccess,
        locale: const Locale('ar'),
      ),
    );
    await capture(
      tester,
      '05-review-invalid-credential',
      _pairing(
        stage: PairingViewStage.error,
        failure: const ApiFailure('REVIEW_ACCESS_INVALID', httpStatus: 401),
        reviewFlow: true,
      ),
    );
    await capture(
      tester,
      '06-review-connecting',
      _pairing(
        stage: PairingViewStage.progress,
        progress: PairingProgress.claiming,
        reviewFlow: true,
      ),
    );
    await capture(tester, '07-review-home', _home());
    await capture(tester, '08-review-tools', _reviewTools());
    await capture(
      tester,
      '09-review-scenario-picker',
      _reviewTools(selected: ReviewScenario.customerActive),
    );
    await capture(
      tester,
      '10-scanner-idle',
      _scanner(CustomerScannerState.initializingCamera),
    );
    await capture(
      tester,
      '11-scanner-active-beam',
      _scanner(CustomerScannerState.ready),
      settle: const Duration(milliseconds: 760),
    );
    await capture(
      tester,
      '12-scanner-qr-detected',
      _scanner(CustomerScannerState.candidateCaptured),
    );
    await capture(
      tester,
      '13-scanner-resolving',
      _scanner(CustomerScannerState.resolving),
    );
    await capture(
      tester,
      '14-scanner-invalid-qr',
      _scanner(CustomerScannerState.invalidQr),
    );
    await capture(
      tester,
      '15-scanner-offline-after-detection',
      _scanner(CustomerScannerState.networkFailure),
    );
    await capture(
      tester,
      '16-scanner-permission-denied',
      _scanner(CustomerScannerState.cameraPermissionDenied),
    );
    await capture(
      tester,
      '17-scanner-permission-permanent',
      _scanner(CustomerScannerState.cameraPermissionPermanentlyDenied),
    );
    await capture(
      tester,
      '18-scanner-flashlight-enabled',
      _scanner(CustomerScannerState.ready, torch: true),
    );
    await capture(
      tester,
      '19-scanner-arabic',
      _scanner(CustomerScannerState.ready, locale: const Locale('ar')),
    );
    await capture(
      tester,
      '20-scanner-dark',
      _scanner(CustomerScannerState.ready, themeMode: ThemeMode.dark),
    );
    await capture(
      tester,
      '21-scanner-large-text',
      _scanner(
        CustomerScannerState.ready,
        textScaler: const TextScaler.linear(2),
      ),
    );
    await capture(tester, '22-customer-0-of-8', _membershipScreen(0));
    await capture(tester, '23-customer-5-of-8', _membershipScreen(5));
    await capture(
      tester,
      '24-customer-8-of-8-reward-ready',
      _membershipScreen(8),
    );

    final membership = _membership(2);
    const stampInput = StampOperationInput(
      amount: 1,
      purchaseAmountMinor: 10000,
      purchaseCurrency: 'IQD',
      merchantTransactionReference: 'DEMO-1042',
    );
    await capture(
      tester,
      '25-stamp-confirmation',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampReview,
          membership: membership,
          stampInput: stampInput,
          credentialAvailable: true,
        ),
      ),
    );
    await capture(
      tester,
      '26-stamp-success',
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
    final approvalMembership = _membership(8, managerApproval: true);
    await capture(
      tester,
      '27-manager-approval-required',
      _operation(
        M2OperationState(
          stage: M2OperationStage.managerApprovalRequired,
          membership: approvalMembership,
          selectedReward: approvalMembership.availableRewards.single,
          pendingOperation: _approvalPending,
          managerApprovalState: ManagerApprovalState.required,
        ),
      ),
    );
    await capture(tester, '28-review-demo-indicator', _settings());
    await capture(
      tester,
      '29-review-exit',
      _reviewTools(),
      prepare: (tester) async {
        await tester.tap(find.text('Exit Demo'));
        await tester.pumpAndSettle();
      },
    );
    await capture(tester, '30-app-lock-review-session', _appLock());
  });
}

Widget _pairing({
  PairingViewStage stage = PairingViewStage.welcome,
  PairingProgress? progress,
  AppFailure? failure,
  bool reviewFlow = false,
  Locale locale = const Locale('en'),
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) => PairingViewState(
        stage: stage,
        progress: progress,
        failure: failure,
        reviewFlow: reviewFlow,
      ),
    ),
  ],
  child: _app(locale: locale, child: const PairingFlowScreen()),
);

Widget _home() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
  ],
  child: _app(child: const HomeScreen()),
);

Widget _reviewTools({ReviewScenario? selected}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(),
    reviewAccessRepositoryProvider.overrideWithValue(
      const _FixtureReviewRepository(),
    ),
    reviewAccessControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          ReviewToolsState(scenarios: _scenarios, selected: selected),
    ),
  ],
  child: _app(child: const ReviewToolsScreen()),
);

Widget _settings() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(),
    environmentProvider.overrideWithValue(_environment),
    themeControllerProvider.overrideWithBuild(
      (ref, notifier) => ThemeMode.system,
    ),
    rapidScanControllerProvider.overrideWithBuild((ref, notifier) => true),
    packageInfoProvider.overrideWithValue(AsyncData(_packageInfo)),
  ],
  child: _app(child: const SettingsScreen()),
);

Widget _appLock() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(),
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

Widget _scanner(
  CustomerScannerState state, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool torch = false,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(locale: locale),
    environmentProvider.overrideWithValue(_environment),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          const M2OperationState(stage: M2OperationStage.scanning),
    ),
    customerScannerAdapterProvider.overrideWithValue(
      FixtureCustomerScannerAdapter(
        'review-fixture-never-rendered',
        autoDeliver: false,
        initialState: state,
        initialTorchEnabled: torch,
      ),
    ),
  ],
  child: _app(
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
    child: const LoyaltyOperationScreen(),
  ),
);

Widget _membershipScreen(int progress) => _operation(
  M2OperationState(
    stage: M2OperationStage.membershipReady,
    membership: _membership(progress),
    credentialAvailable: true,
  ),
);

Widget _operation(M2OperationState state) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    ..._reviewSessionOverrides(),
    environmentProvider.overrideWithValue(_environment),
    m2OperationControllerProvider.overrideWithBuild((ref, notifier) => state),
    stampImageCacheProvider.overrideWithValue(const _FixtureImageLoader()),
  ],
  child: _app(child: const LoyaltyOperationScreen()),
);

List<Override> _reviewSessionOverrides({Locale locale = const Locale('en')}) =>
    [
      bootControllerProvider.overrideWithBuild(
        (ref, notifier) => BootState(
          stage: BootStage.pairedReady,
          context: fixtureContext(),
          session: fixtureSession(sessionMode: StaffSessionMode.review),
        ),
      ),
      connectivityProvider.overrideWithValue(const AsyncData(true)),
    ];

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
  home: MediaQuery(
    data: MediaQueryData(textScaler: textScaler),
    child: child,
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
  packageName: 'app.waflo.staff',
  version: '1.0.0',
  buildNumber: '1',
);

ResolvedMembership _membership(int progress, {bool managerApproval = false}) {
  final value = _fixture('membership-resolve.fixture.json');
  final limits = value['operationLimits']! as Map<String, Object?>;
  value['customerDisplayName'] = 'Lina Saad';
  value['programName'] = 'Counter Coffee Rewards';
  value['locale'] = 'en';
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
            'name': 'Coffee of your choice',
            'description': 'A reward for the completed cycle.',
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
    receivedAt: DateTime(2026, DateTime.august, 14, 13, 15),
  );
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

final _approvalPending = PendingOperationRecord(
  commandId: '20000000-0000-4000-8000-000000000001',
  operationType: PendingOperationType.redemption,
  membershipPublicId: 'review-membership-fixture',
  entitlementPublicId: '40000000-0000-4000-8000-000000000002',
  finalReward: true,
  createdAt: DateTime.utc(2026, 8, 14, 12),
  lastCheckedAt: DateTime.utc(2026, 8, 14, 12, 5),
  status: PendingOperationStatus.approvalRequired,
);

const _scenarios = <ReviewScenarioSummary>[
  ReviewScenarioSummary(
    id: ReviewScenario.customerNew,
    progress: 0,
    goal: 8,
    rewardReady: false,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.customerActive,
    progress: 5,
    goal: 8,
    rewardReady: false,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.customerRewardReady,
    progress: 8,
    goal: 8,
    rewardReady: true,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.managerApprovalRequired,
    progress: 8,
    goal: 8,
    rewardReady: true,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.purchaseThresholdFailure,
    progress: 5,
    goal: 8,
    rewardReady: false,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.billingBlocked,
    progress: 5,
    goal: 8,
    rewardReady: false,
    credentialStatus: 'ACTIVE',
  ),
  ReviewScenarioSummary(
    id: ReviewScenario.invalidQr,
    progress: 0,
    goal: 8,
    rewardReady: false,
    credentialStatus: 'REVOKED',
  ),
];

final class _FixtureReviewRepository implements ReviewAccessRepository {
  const _FixtureReviewRepository();

  @override
  Future<int> reset() async => _scenarios.length;

  @override
  Future<List<ReviewScenarioSummary>> scenarios() async => _scenarios;

  @override
  Future<ReviewScenarioSummary> select(ReviewScenario scenario) async =>
      _scenarios.firstWhere((item) => item.id == scenario);
}

final class _FixtureImageLoader implements StampImageLoader {
  const _FixtureImageLoader();

  @override
  String cacheKey(String digest) => digest.toLowerCase();

  @override
  Future<Uint8List> load({
    required Uri url,
    required String digest,
    required bool allowInsecure,
  }) async => throw StateError('Review fixtures use the two-state fallback.');
}
