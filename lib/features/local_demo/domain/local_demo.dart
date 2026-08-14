import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';

/// Presentation-only QA mode. It is deliberately distinct from NORMAL and
/// server-authorized REVIEW device sessions and never carries credentials.
enum LocalDemoStatus { inactive, active }

enum LocalDemoScenario {
  home,
  scannerReady,
  scannerQrDetected,
  scannerResolving,
  scannerInvalidQr,
  scannerExpiredQr,
  scannerNetworkFailure,
  scannerPermissionDenied,
  customerZeroOfEight,
  customerFiveOfEight,
  customerRewardReady,
  stampConfirmation,
  stampSuccess,
  redeemConfirmation,
  managerApprovalRequired,
  managerApprovalPending,
  managerApprovalRejected,
  managerApprovalExpired,
  redeemSuccess,
  purchaseThresholdNotMet,
  billingBlocked,
  sessionExpired,
  deviceRevoked,
  appLock,
  deviceSecurity,
  settings,
}

enum LocalDemoScannerSimulation {
  validQr,
  invalidQr,
  expiredQr,
  networkFailure,
  reset,
}

enum LocalDemoApprovalOutcome { pending, approved, rejected, expired }

final class LocalDemoState {
  const LocalDemoState({
    this.status = LocalDemoStatus.inactive,
    this.scenario = LocalDemoScenario.home,
    this.busy = false,
  });

  final LocalDemoStatus status;
  final LocalDemoScenario scenario;
  final bool busy;

  bool get active => status == LocalDemoStatus.active;

  LocalDemoState copyWith({
    LocalDemoStatus? status,
    LocalDemoScenario? scenario,
    bool? busy,
  }) => LocalDemoState(
    status: status ?? this.status,
    scenario: scenario ?? this.scenario,
    busy: busy ?? this.busy,
  );
}

abstract interface class LocalDemoRuntime {
  bool availableFor(AppEnvironment environment);

  AuthoritativeDeviceContext get deviceContext;
  LoyaltyOperationsApi get loyaltyOperations;
  PendingOperationStore get pendingOperations;
  ManagerApprovalIntentStore get managerApprovalIntents;
  AppLockStore get appLock;

  CustomerScannerAdapter createScannerAdapter();
  Future<void> simulateScanner(LocalDemoScannerSimulation simulation);
  Future<void> prepareAppLockFixture();
  void selectScenario(LocalDemoScenario scenario);
  void setApprovalOutcome(LocalDemoApprovalOutcome outcome);
  Future<void> reset();
}

final class LocalDemoUnavailableError extends StateError {
  LocalDemoUnavailableError()
    : super('LOCAL_DEMO is unavailable in this build configuration.');
}
