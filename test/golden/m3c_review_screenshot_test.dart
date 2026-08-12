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
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('M3DReviewSans')
          ..addFont(rootBundle.load('assets/brand/fonts/Manrope-Regular.ttf')))
        .load();
    await (FontLoader('M3DReviewArabic')..addFont(
          rootBundle.load('assets/brand/fonts/NotoSansArabic-Regular.ttf'),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> capture(WidgetTester tester, String name, Widget widget) async {
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
    await tester.pump(const Duration(milliseconds: 120));
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
        matchesGoldenFile(
          '../../artifacts/handoff-m3d-brand/screenshots/after/production-v1/$name.png',
        ),
      );
    }
  }

  testWidgets('M3D branded Production-v1 review set', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await capture(tester, '01-redeem-no-approval', _redemptionReview());
    await capture(tester, '02-manager-approval-required', _approval());
    await capture(
      tester,
      '03-manager-approval-pending',
      _approval(approvalState: ManagerApprovalState.pending),
    );
    await capture(
      tester,
      '04-manager-approval-rejected',
      _approval(approvalState: ManagerApprovalState.rejected),
    );
    await capture(
      tester,
      '05-manager-approval-expired',
      _approval(approvalState: ManagerApprovalState.expired),
    );
    await capture(
      tester,
      '06-manager-approval-invalid-mismatch',
      _approval(approvalState: ManagerApprovalState.mismatch),
    );
    await capture(
      tester,
      '07-manager-approval-stale',
      _approval(approvalState: ManagerApprovalState.stale),
    );
    await capture(
      tester,
      '08-manager-approver-inactive',
      _approval(approvalState: ManagerApprovalState.approverInactive),
    );
    await capture(
      tester,
      '09-approved-redeem-retry',
      _approval(approvalState: ManagerApprovalState.checking),
    );
    await capture(tester, '10-approved-redeem-success', _success());
    await capture(tester, '11-approved-retry-ambiguous', _ambiguous());
    await capture(
      tester,
      '12-billing-blocked',
      _failure('OPERATION_BILLING_BLOCKED'),
    );
    await capture(
      tester,
      '13-purchase-threshold-not-met',
      _failure('PURCHASE_THRESHOLD_NOT_MET'),
    );
    await capture(
      tester,
      '14-staff-user-deactivated',
      _blocked(BootStage.staffUserDeactivated),
    );
    await capture(
      tester,
      '15-staff-membership-inactive',
      _blocked(BootStage.staffMembershipInactive),
    );
    await capture(
      tester,
      '16-staff-device-revoked',
      _blocked(BootStage.deviceRevoked),
    );
    await capture(
      tester,
      '17-staff-location-assignment-invalid',
      _blocked(BootStage.staffLocationAssignmentInvalid),
    );
    await capture(tester, '18-pairing-internal-error', _pairingFailure());
    await capture(
      tester,
      '19-ar-manager-approval-required',
      _approval(locale: const Locale('ar'), arabic: true),
    );
    await capture(
      tester,
      '20-ar-manager-approval-pending',
      _approval(
        approvalState: ManagerApprovalState.pending,
        locale: const Locale('ar'),
        arabic: true,
      ),
    );
    await capture(
      tester,
      '21-ar-manager-approval-rejected',
      _approval(
        approvalState: ManagerApprovalState.rejected,
        locale: const Locale('ar'),
        arabic: true,
      ),
    );
    await capture(
      tester,
      '22-dark-manager-approval-required',
      _approval(themeMode: ThemeMode.dark),
    );
    await capture(
      tester,
      '23-large-text-manager-approval-required',
      _approval(textScaler: const TextScaler.linear(2)),
    );
  });
}

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

Widget _approval({
  ManagerApprovalState approvalState = ManagerApprovalState.required,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  TextScaler textScaler = TextScaler.noScaling,
  bool arabic = false,
}) {
  final membership = _membership(8, arabic: arabic, managerApproval: true);
  return _operation(
    M2OperationState(
      stage: M2OperationStage.managerApprovalRequired,
      membership: membership,
      selectedReward: membership.availableRewards.single,
      pendingOperation: _pending(
        approvalState == ManagerApprovalState.pending
            ? PendingOperationStatus.approvalPending
            : PendingOperationStatus.approvalRequired,
      ),
      managerApprovalState: approvalState,
    ),
    locale: locale,
    themeMode: themeMode,
    textScaler: textScaler,
  );
}

Widget _success() => _operation(
  M2OperationState(
    stage: M2OperationStage.redemptionSucceeded,
    membership: _membership(8, managerApproval: true),
    pendingOperation: _pending(PendingOperationStatus.completed),
    redemptionResult: RedemptionOperationResult.fromJson(
      _fixture('redeem-final-reset.fixture.json'),
    ),
  ),
);

Widget _ambiguous() => _operation(
  M2OperationState(
    stage: M2OperationStage.redemptionAmbiguous,
    pendingOperation: _pending(PendingOperationStatus.processing),
    failure: const ApiFailure(
      'OPERATION_RESULT_UNKNOWN',
      responseReceived: false,
    ),
  ),
);

Widget _failure(String code) {
  final threshold = code == 'PURCHASE_THRESHOLD_NOT_MET';
  return _operation(
    M2OperationState(
      stage: M2OperationStage.policyBlocked,
      membership: _membership(5),
      pendingOperation: threshold
          ? null
          : _pending(PendingOperationStatus.failed),
      failure: ApiFailure(code),
      credentialAvailable: threshold,
    ),
  );
}

Widget _pairingFailure() => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild(
      (ref, notifier) => const PairingViewState(
        stage: PairingViewStage.error,
        failure: ApiFailure('INTERNAL_ERROR', httpStatus: 500),
      ),
    ),
  ],
  child: _app(child: const PairingFlowScreen()),
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
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    m2OperationControllerProvider.overrideWithBuild((ref, notifier) => state),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
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
    fontFamily: 'M3DReviewSans',
    fontFamilyFallback: const ['M3DReviewArabic'],
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
    receivedAt: DateTime(2026, DateTime.august, 11, 13, 15),
  );
}

PendingOperationRecord _pending(PendingOperationStatus status) =>
    PendingOperationRecord(
      commandId: '20000000-0000-4000-8000-000000000001',
      operationType: PendingOperationType.redemption,
      membershipPublicId: 'mem_fixture_not_a_credential',
      entitlementPublicId: '40000000-0000-4000-8000-000000000002',
      finalReward: true,
      createdAt: DateTime.utc(2026, 8, 11, 12),
      lastCheckedAt: DateTime.utc(2026, 8, 11, 12, 5),
      status: status,
    );

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
