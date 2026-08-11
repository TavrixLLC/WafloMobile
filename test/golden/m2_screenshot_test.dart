import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'WafloSans',
    )..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'))).load();
    await (FontLoader(
          'WafloArabic',
        )..addFont(rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf')))
        .load();
  });

  Future<void> capture(WidgetTester tester, String name, Widget widget) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    if (Platform.isLinux) {
      expect(tester.takeException(), isNull);
    } else {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/m2/$name.png'),
      );
    }
  }

  testWidgets('M2 25-screen Flutter evidence set', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-home-scan-customer', _home());
    await capture(
      tester,
      '02-customer-scanner',
      _operation(const M2OperationState(stage: M2OperationStage.scanning)),
    );
    await capture(
      tester,
      '03-resolving',
      _operation(const M2OperationState(stage: M2OperationStage.resolving)),
    );
    await capture(tester, '04-membership-0-of-8', _ready(0));
    await capture(tester, '05-membership-5-of-8', _ready(5));
    await capture(tester, '06-membership-8-final-ready', _ready(8));
    await capture(tester, '07-stamp-amount-selector', _ready(2));
    await capture(tester, '08-purchase-requirement', _ready(2));

    final membership = _membership(2);
    const stampInput = StampOperationInput(
      amount: 1,
      purchaseAmountMinor: 10000,
      purchaseCurrency: 'IQD',
    );
    await capture(
      tester,
      '09-stamp-review',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampReview,
          membership: membership,
          stampInput: stampInput,
          credentialAvailable: true,
        ),
      ),
    );
    final stampResult = StampOperationResult.fromJson(
      _fixture('stamp-success.fixture.json'),
    );
    await capture(
      tester,
      '10-stamp-success',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampSucceeded,
          membership: membership,
          stampResult: stampResult,
        ),
      ),
    );
    await capture(
      tester,
      '11-milestone-unlocked',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampSucceeded,
          membership: _membership(5),
          stampResult: _milestoneStampResult(),
        ),
      ),
    );
    await capture(tester, '12-reward-list', _ready(2));
    await capture(
      tester,
      '13-manager-approval-required',
      _operation(
        M2OperationState(
          stage: M2OperationStage.managerApprovalRequired,
          membership: membership,
          selectedReward: membership.availableRewards.first,
          managerApprovalState: ManagerApprovalState.required,
        ),
      ),
    );

    final finalMembership = _membership(8);
    await capture(
      tester,
      '14-final-redemption-warning',
      _operation(
        M2OperationState(
          stage: M2OperationStage.redemptionReview,
          membership: finalMembership,
          selectedReward: finalMembership.availableRewards.first,
          credentialAvailable: true,
        ),
      ),
    );
    await capture(
      tester,
      '15-milestone-redemption-success',
      _operation(
        M2OperationState(
          stage: M2OperationStage.redemptionSucceeded,
          membership: membership,
          redemptionResult: RedemptionOperationResult.fromJson(
            _fixture('redeem-milestone.fixture.json'),
          ),
        ),
      ),
    );
    await capture(
      tester,
      '16-final-redemption-0-of-8',
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

    final pending = PendingOperationRecord(
      commandId: '20000000-0000-4000-8000-000000000001',
      operationType: PendingOperationType.stamp,
      membershipPublicId: 'mem_fixture_not_a_credential',
      stampAmount: 1,
      createdAt: DateTime.utc(2026, 8, 2),
      lastCheckedAt: null,
      status: PendingOperationStatus.processing,
    );
    await capture(
      tester,
      '17-pending-operation-recovery',
      _operation(
        M2OperationState(
          stage: M2OperationStage.stampAmbiguous,
          pendingOperation: pending,
        ),
      ),
    );
    await capture(
      tester,
      '18-daily-cap-error',
      _failure('DAILY_STAMP_LIMIT_REACHED'),
    );
    await capture(
      tester,
      '19-currency-error',
      _failure('PURCHASE_CURRENCY_MISMATCH'),
    );
    await capture(
      tester,
      '20-wrong-location',
      _failure('LOCATION_NOT_AUTHORIZED', location: true),
    );
    await capture(tester, '21-offline', _ready(5, online: false));
    await capture(
      tester,
      '22-arabic-membership',
      _ready(5, locale: const Locale('ar')),
    );
    await capture(
      tester,
      '23-arabic-redemption',
      _operation(
        M2OperationState(
          stage: M2OperationStage.redemptionReview,
          membership: finalMembership,
          selectedReward: finalMembership.availableRewards.first,
          credentialAvailable: true,
        ),
        locale: const Locale('ar'),
      ),
    );
    await capture(
      tester,
      '24-dark-theme',
      _ready(5, themeMode: ThemeMode.dark),
    );
    await capture(
      tester,
      '25-large-text',
      _ready(5, textScaler: const TextScaler.linear(2)),
    );
  });
}

Widget _home() => ProviderScope(
  overrides: [
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
  child: _app(child: const HomeScreen()),
);

Widget _ready(
  int progress, {
  bool online = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
}) => _operation(
  M2OperationState(
    stage: M2OperationStage.membershipReady,
    membership: _membership(progress),
    credentialAvailable: true,
  ),
  online: online,
  locale: locale,
  themeMode: themeMode,
  textScaler: textScaler,
);

Widget _failure(String code, {bool location = false}) => _operation(
  M2OperationState(
    stage: location
        ? M2OperationStage.locationBlocked
        : M2OperationStage.policyBlocked,
    failure: ApiFailure(code, requestId: 'req_fixture_support'),
  ),
);

Widget _operation(
  M2OperationState state, {
  bool online = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
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
      FixtureCustomerScannerAdapter(_syntheticCredential),
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
  theme: WafloTheme.light(),
  darkTheme: WafloTheme.dark(),
  themeMode: themeMode,
  home: MediaQuery(
    data: MediaQueryData(textScaler: textScaler),
    child: child,
  ),
);

ResolvedMembership _membership(int progress) {
  final value = _fixture('membership-resolve.fixture.json');
  final limits = value['operationLimits']! as Map<String, Object?>;
  value['progress'] = progress;
  value['rewardReady'] = progress == 8;
  value['projectionVersion'] = progress + 1;
  limits['dailyRemainingStamps'] = (8 - progress).clamp(0, 4);
  if (progress == 8) {
    value['availableRewards'] = [
      <String, Object?>{
        'publicId': '40000000-0000-4000-8000-000000000002',
        'finalReward': true,
        'threshold': 8,
        'name': 'Fixture final reward',
        'description': 'A sanitized final reward.',
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
    receivedAt: DateTime(2026, DateTime.august, 7, 23, 40),
  );
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

StampOperationResult _milestoneStampResult() {
  final redemption = _fixture('redeem-milestone.fixture.json');
  return StampOperationResult.fromJson(<String, Object?>{
    'operationPublicId': '30000000-0000-4000-8000-000000000005',
    'commandId': '20000000-0000-4000-8000-000000000005',
    'replayed': false,
    'beforeProgress': 5,
    'progress': 6,
    'goal': 8,
    'rewardReady': false,
    'completedCycles': 0,
    'projectionVersion': 7,
    'unlockedRewards': [
      <String, Object?>{
        'publicId': '10000000-0000-4000-8000-000000000001',
        'threshold': 4,
        'status': 'AVAILABLE',
        'final': false,
      },
    ],
    'requestId': redemption['requestId'],
  });
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
  }) async => throw StateError('Synthetic artwork failure exercises fallback');
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

const _syntheticCredential =
    'customer-membership-credential-fixture-000000000000000000000000';
