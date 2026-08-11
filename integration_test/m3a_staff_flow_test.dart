import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import 'm2_app_integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M3A rapid Staff flow and recovery remain safe', (tester) async {
    const credential =
        'customer-membership-credential-fixture-not-a-real-credential-0001';

    // 01 paired boot and 02 explicit scanner.
    final store = MemoryPendingOperationStore();
    final api = EmulatorLoyaltyApi(membership: m2IntegrationMembership(2));
    final container = m2IntegrationContainer(api: api, store: store);
    addTearDown(container.dispose);
    final controller = container.read(m2OperationControllerProvider.notifier);
    expect(container.read(bootControllerProvider).stage, BootStage.pairedReady);
    controller.startScanning();
    await pumpM2IntegrationApp(tester, container);
    expect(find.byKey(const Key('fixture-customer-scanner')), findsOneWidget);
    expect(find.text(credential), findsNothing);

    // 03 resolve and 04 compact authoritative customer state.
    await controller.resolveCandidate(credential, locale: 'en');
    await pumpM2IntegrationApp(tester, container);
    expect(find.byKey(const Key('customer-membership-screen')), findsOneWidget);
    expect(find.text('Sanitized Customer'), findsOneWidget);
    expect(
      container.read(m2OperationControllerProvider).credentialAvailable,
      isTrue,
    );

    // 05 review, 06 double-tap protection, and 07 committed success.
    controller.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: 'SAFE-LOCAL-REFERENCE',
    );
    await pumpM2IntegrationApp(tester, container);
    expect(find.byKey(const Key('operation-confirmation')), findsOneWidget);
    await Future.wait([
      controller.confirmStamp(locale: 'en'),
      controller.confirmStamp(locale: 'en'),
    ]);
    expect(api.issueCommandIds, hasLength(1));
    expect(
      container.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampSucceeded,
    );
    expect(
      container.read(m2OperationControllerProvider).credentialAvailable,
      isFalse,
    );
    await pumpM2IntegrationApp(tester, container);
    expect(find.byKey(const Key('scan-next-customer')), findsOneWidget);

    // 08 Rapid Scan clears all sensitive operation state before scanning.
    await controller.resetForNextCustomer();
    controller.startScanning();
    final reset = container.read(m2OperationControllerProvider);
    expect(reset.stage, M2OperationStage.scanning);
    expect(reset.membership, isNull);
    expect(reset.stampInput, isNull);
    expect(reset.selectedReward, isNull);
    expect(reset.credentialAvailable, isFalse);
    expect(store.value, isNull);

    // 09 backgrounding clears the active credential and leaves no QR journal.
    await controller.resolveCandidate(credential, locale: 'en');
    controller.onBackground();
    expect(
      container.read(m2OperationControllerProvider).credentialAvailable,
      isFalse,
    );
    expect(store.value?.toJson().containsKey('qrPayload') ?? false, isFalse);

    // 10 ambiguous submission survives, 11 blocks scanning, and 12 recovers
    // under the exact same command rather than creating a new mutation.
    final recoveryStore = MemoryPendingOperationStore();
    final recoveryApi = EmulatorLoyaltyApi(
      membership: m2IntegrationMembership(2),
      issueFailure: const ApiFailure(
        'OPERATION_RESULT_UNKNOWN',
        responseReceived: false,
      ),
      recovery: m2CompletedStampRecovery(),
    );
    final recoveryContainer = m2IntegrationContainer(
      api: recoveryApi,
      store: recoveryStore,
    );
    addTearDown(recoveryContainer.dispose);
    final recoveryController = recoveryContainer.read(
      m2OperationControllerProvider.notifier,
    );
    recoveryController.startScanning();
    await recoveryController.resolveCandidate(credential, locale: 'en');
    recoveryController.prepareStampReview(
      amount: 1,
      purchaseAmountText: '10.000',
      transactionReferenceText: '',
    );
    await recoveryController.confirmStamp(locale: 'en');
    expect(
      recoveryContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampAmbiguous,
    );
    recoveryController.startScanning();
    expect(
      recoveryContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampAmbiguous,
    );
    await recoveryController.recoverPending();
    expect(recoveryApi.issueCommandIds, hasLength(1));
    expect(
      recoveryContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.stampSucceeded,
    );

    // 13 final redemption is authoritative, 14 resets to all EMPTY, and
    // 15 its success can transition safely to the next customer.
    final finalStore = MemoryPendingOperationStore();
    final finalMembership = m2IntegrationMembership(8);
    final finalApi = EmulatorLoyaltyApi(
      membership: finalMembership,
      redemption: m2FinalRedemptionResult(),
    );
    final finalContainer = m2IntegrationContainer(
      api: finalApi,
      store: finalStore,
    );
    addTearDown(finalContainer.dispose);
    final finalController = finalContainer.read(
      m2OperationControllerProvider.notifier,
    );
    finalController.startScanning();
    await finalController.resolveCandidate(credential, locale: 'en');
    await finalController.prepareRedemption(
      finalMembership.availableRewards.first,
      locale: 'en',
    );
    await finalController.confirmRedemption(locale: 'en');
    final redemption = finalContainer
        .read(m2OperationControllerProvider)
        .redemptionResult!;
    expect(redemption.progress.progress, 0);
    expect(
      redemption.progress.slots.every((slot) => slot == StampSlotState.empty),
      isTrue,
    );
    await finalController.resetForNextCustomer();
    finalController.startScanning();
    expect(
      finalContainer.read(m2OperationControllerProvider).stage,
      M2OperationStage.scanning,
    );
  });
}
