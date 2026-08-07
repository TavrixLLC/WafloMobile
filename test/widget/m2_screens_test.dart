import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/loyalty_progress/presentation/two_state_stamp_grid.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('customer scanner is explicit and never renders QR text', (
    tester,
  ) async {
    const credential =
        'customer-membership-credential-fixture-000000000000000000000000';
    await tester.pumpWidget(
      _harness(
        const M2OperationState(stage: M2OperationStage.scanning),
        scanner: FixtureCustomerScannerAdapter(credential),
      ),
    );
    await tester.pump();

    expect(find.text('Scan customer membership'), findsOneWidget);
    expect(find.byKey(const Key('fixture-customer-scanner')), findsOneWidget);
    expect(find.text(credential), findsNothing);
    expect(find.text('Toggle camera flash'), findsOneWidget);
  });

  testWidgets('resolve loading and membership projections render safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(const M2OperationState(stage: M2OperationStage.resolving)),
    );
    expect(find.text('Resolving membership securely'), findsWidgets);

    for (final progress in [0, 5, 8]) {
      final membership = _membership(progress);
      await tester.pumpWidget(
        _harness(
          M2OperationState(
            stage: M2OperationStage.membershipReady,
            membership: membership,
            credentialAvailable: true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('$progress of 8 stamps'), findsWidgets);
      expect(find.textContaining('Synthetic customer'), findsOneWidget);
      expect(find.textContaining('mem_fixture'), findsNothing);
    }
  });

  testWidgets('stamp selector and purchase requirement are accessible', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.membershipReady,
          membership: _membership(2),
          credentialAvailable: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Stamp amount'), findsWidgets);
    expect(find.byKey(const Key('purchase-amount-field')), findsOneWidget);
    expect(
      find.byKey(const Key('transaction-reference-field')),
      findsOneWidget,
    );
    expect(find.textContaining('IQD'), findsOneWidget);
  });

  testWidgets(
    'stamp review, submission, and success use committed projection',
    (tester) async {
      final membership = _membership(2);
      await tester.pumpWidget(
        _harness(
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
        ),
      );
      expect(find.text('Review stamp issuance'), findsWidgets);
      expect(find.text('Confirm stamp issuance'), findsOneWidget);

      await tester.pumpWidget(
        _harness(
          const M2OperationState(stage: M2OperationStage.stampSubmitting),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        _harness(
          M2OperationState(
            stage: M2OperationStage.stampSucceeded,
            membership: membership,
            stampResult: StampOperationResult.fromJson(
              _fixture('stamp-success.fixture.json'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Stamps issued'), findsWidgets);
      expect(find.text('5 of 8 stamps'), findsWidgets);
      expect(find.textContaining('1 stamp issued'), findsOneWidget);
    },
  );

  testWidgets('reward list blocks Manager flow and shows final warning', (
    tester,
  ) async {
    final membership = _membership(2, managerApproval: true);
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.membershipReady,
          membership: membership,
          credentialAvailable: true,
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Manager approval required'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Manager approval required'), findsOneWidget);

    final finalMembership = _membership(8);
    final finalReward = finalMembership.availableRewards.single;
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.redemptionReview,
          membership: finalMembership,
          selectedReward: finalReward,
          credentialAvailable: true,
        ),
      ),
    );
    expect(find.textContaining('reset to 0 of 8'), findsOneWidget);
    expect(find.text('Confirm redemption'), findsOneWidget);
  });

  testWidgets('milestone and final redemption success stay exact', (
    tester,
  ) async {
    final milestone = RedemptionOperationResult.fromJson(
      _fixture('redeem-milestone.fixture.json'),
    );
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.redemptionSucceeded,
          membership: _membership(6),
          redemptionResult: milestone,
        ),
      ),
    );
    expect(find.text('Stamp progress is unchanged.'), findsOneWidget);

    final finalResult = RedemptionOperationResult.fromJson(
      _fixture('redeem-final-reset.fixture.json'),
    );
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.redemptionSucceeded,
          membership: _membership(8),
          redemptionResult: finalResult,
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('0 of 8'), findsWidgets);
  });

  testWidgets('pending result and stable errors are actionable', (
    tester,
  ) async {
    final pending = PendingOperationRecord(
      commandId: '20000000-0000-4000-8000-000000000001',
      operationType: PendingOperationType.stamp,
      membershipPublicId: 'mem_fixture',
      stampAmount: 1,
      createdAt: DateTime.utc(2026, 8, 2),
      lastCheckedAt: null,
      status: PendingOperationStatus.processing,
    );
    await tester.pumpWidget(
      _harness(
        M2OperationState(
          stage: M2OperationStage.stampAmbiguous,
          pendingOperation: pending,
          failure: const ApiFailure('OPERATION_RESULT_UNKNOWN'),
        ),
      ),
    );
    expect(find.text('Operation result pending'), findsWidgets);
    expect(find.text('Check result'), findsOneWidget);

    await tester.pumpWidget(
      _harness(
        const M2OperationState(
          stage: M2OperationStage.locationBlocked,
          failure: ApiFailure('LOCATION_EARNING_DISABLED'),
        ),
      ),
    );
    expect(find.textContaining('current location'), findsOneWidget);
  });

  testWidgets(
    'Arabic RTL, large text, dark theme, and concise semantics work',
    (tester) async {
      await tester.pumpWidget(
        _harness(
          M2OperationState(
            stage: M2OperationStage.membershipReady,
            membership: _membership(5),
            credentialAvailable: true,
          ),
          locale: const Locale('ar'),
          textScaler: const TextScaler.linear(2),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      expect(
        Directionality.of(tester.element(find.byType(TwoStateStampGrid))),
        TextDirection.rtl,
      );
      final semantics = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(TwoStateStampGrid));
      expect(node.label, contains('5'));
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}

Widget _harness(
  M2OperationState state, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
  CustomerScannerAdapter? scanner,
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
    if (scanner != null)
      customerScannerAdapterProvider.overrideWithValue(scanner),
  ],
  child: MaterialApp(
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
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: const LoyaltyOperationScreen(),
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

ResolvedMembership _membership(int progress, {bool managerApproval = false}) {
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
  } else if (managerApproval) {
    final reward =
        (value['availableRewards']! as List<Object?>).single!
            as Map<String, Object?>;
    reward['requiresManagerApproval'] = true;
  }
  return ResolvedMembership.fromJson(value, allowInsecureAssets: false);
}

Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('contracts/w4/m2/$name').readAsStringSync())
        as Map<String, Object?>;

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
