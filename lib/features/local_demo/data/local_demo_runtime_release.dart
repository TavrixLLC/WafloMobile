import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/operation_recovery/pending_operation.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/reward_redemption/data/manager_approval_store.dart';

LocalDemoRuntime createLocalDemoRuntime() => const _ReleaseLocalDemoRuntime();

/// The product-mode implementation is an explicit deny-all object. The debug
/// fixture implementation is excluded by the conditional export above.
final class _ReleaseLocalDemoRuntime implements LocalDemoRuntime {
  const _ReleaseLocalDemoRuntime();

  Never get _unavailable => throw LocalDemoUnavailableError();

  @override
  bool availableFor(AppEnvironment environment) => false;

  @override
  AppLockStore get appLock => _unavailable;

  @override
  AuthoritativeDeviceContext get deviceContext => _unavailable;

  @override
  LoyaltyOperationsApi get loyaltyOperations => _unavailable;

  @override
  ManagerApprovalIntentStore get managerApprovalIntents => _unavailable;

  @override
  PendingOperationStore get pendingOperations => _unavailable;

  @override
  CustomerScannerAdapter createScannerAdapter() => _unavailable;

  @override
  Future<void> simulateScanner(LocalDemoScannerSimulation simulation) async =>
      _unavailable;

  @override
  Future<void> prepareAppLockFixture() async => _unavailable;

  @override
  Future<void> reset() async => _unavailable;

  @override
  void selectScenario(LocalDemoScenario scenario) => _unavailable;

  @override
  void setApprovalOutcome(LocalDemoApprovalOutcome outcome) => _unavailable;
}
