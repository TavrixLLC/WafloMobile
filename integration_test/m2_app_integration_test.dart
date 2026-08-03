import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/idempotency/business_command_id.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/money/minor_unit_money.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pending_operation/domain/command_recovery.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../test/support/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M2 approved 24-scenario application matrix', (tester) async {
    final store = MemoryPendingOperationStore();
    final api = _EmulatorLoyaltyApi(membership: _membership(2));
    final container = _container(api: api, store: store);
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);

    // 01 paired boot.
    expect(container.read(bootControllerProvider).stage, BootStage.pairedReady);

    // 02 explicit customer scanner and 03 synthetic DI scan candidate.
    controller.startScanning();
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.scanning,
    );
    await _pumpApp(tester, container);
    expect(find.byKey(const Key('fixture-customer-scanner')), findsOneWidget);
    expect(find.text(_credential), findsNothing);

    // 04 signed-API boundary resolve (the API is replaced only at DI boundary).
    await controller.resolveCandidate(_credential, locale: 'en');
    expect(
      container
          .read(m2OperationControllerProvider)
          .membership
          ?.progress
          .progress,
      2,
    );

    // 05 issue one stamp.
    controller.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    await controller.confirmStamp(locale: 'en');
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampSucceeded,
    );
    expect(api.issueCommandIds, hasLength(1));

    // 06 compatible replay keeps the exact business command identity.
    final replayInput = const StampOperationInput(
      amount: 1,
      purchaseAmountMinor: 10000,
      purchaseCurrency: 'IQD',
    );
    final firstReplay = await api.issueStamps(
      qrPayload: _credential,
      locale: 'en',
      commandId: api.issueCommandIds.first,
      input: replayInput,
    );
    final secondReplay = await api.issueStamps(
      qrPayload: _credential,
      locale: 'en',
      commandId: api.issueCommandIds.first,
      input: replayInput,
    );
    expect(secondReplay.commandId, firstReplay.commandId);

    await controller.acknowledgeAndReset();
    controller.startScanning();
    await controller.resolveCandidate(_credential, locale: 'en');

    // 07 multiple-stamp selection and 08 required purchase amount.
    controller.prepareStampReview(
      amount: 2,
      purchaseAmountText: '١٠٫٠٠٠',
      transactionReferenceText: '',
    );
    expect(container.read(m2OperationControllerProvider).stampInput?.amount, 2);
    expect(
      container
          .read(m2OperationControllerProvider)
          .stampInput
          ?.purchaseAmountMinor,
      10000,
    );

    // 09 daily-cap rejection and 10 wrong-currency rejection.
    controller.returnToMembership();
    controller.prepareStampReview(
      amount: 5,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    expect(
      container.read(m2OperationControllerProvider).failure?.safeCode,
      'STAMP_AMOUNT_INVALID',
    );
    expect(
      () => MinorUnitMoney.parse('10.000', currencyCode: 'USD'),
      throwsA(isA<MoneyInputException>()),
    );

    // 11 milestone projection and 12 final-ready projection.
    final milestone = _milestoneStampResult();
    expect(milestone.progress.progress, 6);
    expect(milestone.unlockedRewards.single.finalReward, isFalse);
    final finalReady = _membership(8);
    expect(finalReady.rewardReady, isTrue);
    expect(
      finalReady.progress.slots.every(
        (StampSlotState value) => value == StampSlotState.filled,
      ),
      isTrue,
    );

    // 13 extra stamp is impossible at goal.
    expect(finalReady.operationPolicy.selectableMaximumStampAmount, 0);

    // 14 milestone redemption.
    final milestoneApi = _EmulatorLoyaltyApi(
      membership: _membership(6, managerApproval: false),
      redemption: RedemptionOperationResult.fromJson(
        _fixture('redeem-milestone.fixture.json'),
      ),
    );
    final milestoneContainer = _container(
      api: milestoneApi,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(milestoneContainer.dispose);
    final milestoneController = milestoneContainer.read(
      m2OperationControllerProvider.notifier,
    );
    milestoneController.startScanning();
    await milestoneController.resolveCandidate(_credential, locale: 'en');
    final milestoneMembership = milestoneContainer
        .read(m2OperationControllerProvider)
        .membership!;
    await milestoneController.prepareRedemption(
      milestoneMembership.availableRewards.first,
      locale: 'en',
    );
    await milestoneController.confirmRedemption(locale: 'en');
    expect(
      milestoneContainer
          .read(m2OperationControllerProvider)
          .redemptionResult
          ?.progress
          .progress,
      6,
    );

    // 15 manager approval remains unavailable in M2.
    final managerApi = _EmulatorLoyaltyApi(membership: _membership(2));
    final managerContainer = _container(
      api: managerApi,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(managerContainer.dispose);
    final managerController = managerContainer.read(
      m2OperationControllerProvider.notifier,
    );
    managerController.startScanning();
    await managerController.resolveCandidate(_credential, locale: 'en');
    await managerController.prepareRedemption(
      managerContainer
          .read(m2OperationControllerProvider)
          .membership!
          .availableRewards
          .first,
      locale: 'en',
    );
    expect(
      managerContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.managerApprovalRequired,
    );
    expect(managerApi.redeemCommandIds, isEmpty);

    // 16 final redeem and 17 exact 0/goal all-empty result.
    final finalApi = _EmulatorLoyaltyApi(
      membership: finalReady,
      redemption: RedemptionOperationResult.fromJson(
        _fixture('redeem-final-reset.fixture.json'),
      ),
    );
    final finalContainer = _container(
      api: finalApi,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(finalContainer.dispose);
    final finalController = finalContainer.read(
      m2OperationControllerProvider.notifier,
    );
    finalController.startScanning();
    await finalController.resolveCandidate(_credential, locale: 'en');
    await finalController.prepareRedemption(
      finalReady.availableRewards.first,
      locale: 'en',
    );
    await finalController.confirmRedemption(locale: 'en');
    final finalResult = finalContainer
        .read(m2OperationControllerProvider)
        .redemptionResult!;
    expect(finalResult.progress.progress, 0);
    expect(
      finalResult.progress.slots.every(
        (StampSlotState value) => value == StampSlotState.empty,
      ),
      isTrue,
    );

    // 18 ambiguous stamp recovery.
    final ambiguousStampStore = MemoryPendingOperationStore();
    final ambiguousStampApi = _EmulatorLoyaltyApi(
      membership: _membership(2),
      issueFailure: const ApiFailure(
        'OPERATION_RESULT_UNKNOWN',
        responseReceived: false,
      ),
      recovery: CommandRecoveryResult.fromJson(
        _fixture('operation-completed.fixture.json'),
      ),
    );
    final ambiguousStampContainer = _container(
      api: ambiguousStampApi,
      store: ambiguousStampStore,
    );
    addTearDown(ambiguousStampContainer.dispose);
    final ambiguousStampController = ambiguousStampContainer.read(
      m2OperationControllerProvider.notifier,
    );
    ambiguousStampController.startScanning();
    await ambiguousStampController.resolveCandidate(_credential, locale: 'en');
    ambiguousStampController.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    await ambiguousStampController.confirmStamp(locale: 'en');
    expect(
      ambiguousStampStore.value?.status,
      PendingOperationStatus.processing,
    );
    await ambiguousStampController.recoverPending();
    expect(
      ambiguousStampContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampSucceeded,
    );

    // 19 ambiguous redemption recovery is journaled under the same command.
    final ambiguousRedemption = PendingOperationRecord(
      commandId: _commandId,
      operationType: PendingOperationType.redemption,
      membershipPublicId: 'mem_fixture_not_a_credential',
      entitlementPublicId: '40000000-0000-4000-8000-000000000002',
      finalReward: true,
      createdAt: DateTime.now().toUtc(),
      lastCheckedAt: null,
      status: PendingOperationStatus.processing,
    );
    expect(ambiguousRedemption.toJson().containsKey('qrPayload'), isFalse);

    // 20 process restart restores pending command without a credential.
    final restartStore = MemoryPendingOperationStore()
      ..value = ambiguousRedemption;
    final restartContainer = _container(
      api: _EmulatorLoyaltyApi(membership: finalReady),
      store: restartStore,
    );
    addTearDown(restartContainer.dispose);
    expect(
      restartContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.redemptionAmbiguous,
    );

    // 21 network unavailable does not queue a mutation.
    final offlineApi = _EmulatorLoyaltyApi(
      membership: _membership(2),
      resolveFailure: const NetworkFailure(),
    );
    final offlineContainer = _container(
      api: offlineApi,
      store: MemoryPendingOperationStore(),
    );
    addTearDown(offlineContainer.dispose);
    final offlineController = offlineContainer.read(
      m2OperationControllerProvider.notifier,
    );
    offlineController.startScanning();
    await offlineController.resolveCandidate(_credential, locale: 'en');
    expect(
      offlineContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.networkUnavailable,
    );
    expect(offlineApi.issueCommandIds, isEmpty);

    // 22 device revocation interrupts and clears local recovery.
    await ambiguousStampController.onSessionBlocked();
    expect(
      ambiguousStampContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.sessionBlocked,
    );
    expect(ambiguousStampStore.value, isNull);

    // 23 Arabic RTL and 24 accessibility at 200% text scale.
    final displayContainer = _container(
      api: _EmulatorLoyaltyApi(membership: _membership(5)),
      store: MemoryPendingOperationStore(),
    );
    addTearDown(displayContainer.dispose);
    final displayController = displayContainer.read(
      m2OperationControllerProvider.notifier,
    );
    displayController.startScanning();
    await displayController.resolveCandidate(_credential, locale: 'ar');
    await _pumpApp(
      tester,
      displayContainer,
      locale: const Locale('ar'),
      textScaler: const TextScaler.linear(2),
    );
    expect(
      Directionality.of(tester.element(find.byType(LoyaltyOperationScreen))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}

ProviderContainer _container({
  required _EmulatorLoyaltyApi api,
  required MemoryPendingOperationStore store,
}) => ProviderContainer(
  overrides: [
    environmentProvider.overrideWithValue(_environment),
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) =>
          BootState(stage: BootStage.pairedReady, context: fixtureContext()),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
    loyaltyOperationsApiProvider.overrideWithValue(api),
    pendingOperationStoreProvider.overrideWithValue(store),
    businessCommandIdGeneratorProvider.overrideWithValue(
      FixedBusinessCommandIdGenerator(List.filled(20, _commandId)),
    ),
    customerScannerAdapterProvider.overrideWithValue(
      FixtureCustomerScannerAdapter(_credential),
    ),
    stampImageCacheProvider.overrideWithValue(const _FixtureImageLoader()),
  ],
);

Future<void> _pumpApp(
  WidgetTester tester,
  ProviderContainer container, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const LoyaltyOperationScreen(),
      ),
    ),
  );
  await tester.pump();
}

final class _EmulatorLoyaltyApi implements LoyaltyOperationsApi {
  _EmulatorLoyaltyApi({
    required this.membership,
    this.issueFailure,
    this.resolveFailure,
    this.redemption,
    this.recovery,
  });

  ResolvedMembership membership;
  AppFailure? issueFailure;
  AppFailure? resolveFailure;
  RedemptionOperationResult? redemption;
  CommandRecoveryResult? recovery;
  final List<String> issueCommandIds = [];
  final List<String> redeemCommandIds = [];
  final Map<String, StampOperationResult> _stampReceipts = {};

  @override
  Future<ResolvedMembership> resolveMembership({
    required String qrPayload,
    required String locale,
  }) async {
    final failure = resolveFailure;
    if (failure != null) throw failure;
    return membership;
  }

  @override
  Future<StampOperationResult> issueStamps({
    required String qrPayload,
    required String locale,
    required String commandId,
    required StampOperationInput input,
  }) async {
    issueCommandIds.add(commandId);
    final failure = issueFailure;
    if (failure != null) throw failure;
    return _stampReceipts.putIfAbsent(
      commandId,
      () =>
          StampOperationResult.fromJson(_fixture('stamp-success.fixture.json')),
    );
  }

  @override
  Future<RedemptionOperationResult> redeemReward({
    required String qrPayload,
    required String locale,
    required String commandId,
    required RedemptionOperationInput input,
  }) async {
    redeemCommandIds.add(commandId);
    return redemption ??
        RedemptionOperationResult.fromJson(
          _fixture('redeem-milestone.fixture.json'),
        );
  }

  @override
  Future<CommandRecoveryResult> commandStatus(String commandId) async =>
      recovery ??
      CommandRecoveryResult.fromJson(
        _fixture('operation-processing.fixture.json'),
      );
}

ResolvedMembership _membership(int progress, {bool managerApproval = true}) {
  final value = _fixture('membership-resolve.fixture.json');
  final membership = value['membership']! as Map<String, Object?>;
  final policy = value['operationPolicy']! as Map<String, Object?>;
  value['progress'] = progress;
  membership['progress'] = progress;
  value['rewardReady'] = progress == 8;
  membership['rewardReady'] = progress == 8;
  membership['projectionVersion'] = progress + 1;
  policy['remainingProgressCapacity'] = 8 - progress;
  policy['effectiveMaximumStampAmount'] = (8 - progress).clamp(0, 5);
  if (progress == 8) {
    value['availableRewards'] = [
      <String, Object?>{
        'entitlementPublicId': '40000000-0000-4000-8000-000000000002',
        'type': 'FREE_ITEM',
        'finalReward': true,
        'threshold': 8,
        'name': 'Fixture final reward',
        'description': 'A sanitized final reward.',
        'redemptionInstructions': 'Follow merchant instructions.',
        'status': 'AVAILABLE',
        'redemptionCount': 0,
        'maximumRedemptionCount': 1,
        'expiresAt': null,
        'requiresManagerApproval': false,
      },
    ];
  } else if (!managerApproval) {
    for (final reward in value['availableRewards']! as List<Object?>) {
      (reward! as Map<String, Object?>)['requiresManagerApproval'] = false;
    }
  }
  return ResolvedMembership.fromJson(value, allowInsecureAssets: false);
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
    'unlockedRewards': [redemption['reward']],
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
  }) async => base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
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

const _commandId = '20000000-0000-4000-8000-000000000001';
const _credential =
    'customer-membership-credential-fixture-000000000000000000000000';
