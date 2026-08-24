import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/permissions/camera_permission.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';

void main() {
  test('customer scanner reports denial before starting the camera', () async {
    final gateway = _FakeCameraPermissionGateway(
      current: CameraPermissionAccess.denied,
      requestResult: CameraPermissionAccess.denied,
    );
    final adapter = MobileCustomerScannerAdapter(
      permissionCoordinator: CameraPermissionCoordinator(gateway),
    );
    addTearDown(adapter.dispose);

    await adapter.start();

    expect(adapter.state.value, CustomerScannerState.cameraPermissionDenied);
    expect(gateway.requestCalls, 1);
  });

  test(
    'customer scanner maps restricted access to the Settings path',
    () async {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.restricted,
      );
      final adapter = MobileCustomerScannerAdapter(
        permissionCoordinator: CameraPermissionCoordinator(gateway),
      );
      addTearDown(adapter.dispose);

      await adapter.start();

      expect(
        adapter.state.value,
        CustomerScannerState.cameraPermissionPermanentlyDenied,
      );
      expect(gateway.requestCalls, 0);
    },
  );

  test('customer lifecycle resume checks access without prompting', () async {
    final gateway = _FakeCameraPermissionGateway(
      current: CameraPermissionAccess.denied,
      requestResult: CameraPermissionAccess.denied,
    );
    final adapter = MobileCustomerScannerAdapter(
      permissionCoordinator: CameraPermissionCoordinator(gateway),
    );
    addTearDown(adapter.dispose);
    await adapter.start();
    expect(gateway.requestCalls, 1);

    await adapter.background();
    await adapter.foreground();

    expect(adapter.state.value, CustomerScannerState.cameraPermissionDenied);
    expect(gateway.requestCalls, 1);
  });

  test(
    'pairing scanner reports permanent denial before camera startup',
    () async {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.permanentlyDenied,
      );
      final adapter = MobilePairingScannerAdapter(
        permissionCoordinator: CameraPermissionCoordinator(gateway),
      );
      addTearDown(adapter.dispose);

      await adapter.start();

      expect(
        adapter.state.value,
        CustomerScannerState.cameraPermissionPermanentlyDenied,
      );
      expect(gateway.requestCalls, 0);
    },
  );
}

final class _FakeCameraPermissionGateway implements CameraPermissionGateway {
  _FakeCameraPermissionGateway({
    required this.current,
    this.requestResult = CameraPermissionAccess.denied,
  });

  CameraPermissionAccess current;
  final CameraPermissionAccess requestResult;
  int requestCalls = 0;

  @override
  Future<CameraPermissionAccess> status() async => current;

  @override
  Future<CameraPermissionAccess> request() async {
    requestCalls += 1;
    current = requestResult;
    return current;
  }

  @override
  Future<bool> openSettings() async => true;
}
