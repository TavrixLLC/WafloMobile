import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/permissions/camera_permission.dart';

void main() {
  group('CameraPermissionCoordinator', () {
    test('uses an existing grant without showing a native prompt', () async {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.granted,
      );
      final coordinator = CameraPermissionCoordinator(gateway);

      expect(await coordinator.requestAccess(), CameraPermissionAccess.granted);
      expect(gateway.statusCalls, 1);
      expect(gateway.requestCalls, 0);
    });

    test(
      'first request continues immediately when access is granted',
      () async {
        final gateway = _FakeCameraPermissionGateway(
          current: CameraPermissionAccess.denied,
          requestResult: CameraPermissionAccess.granted,
        );
        final coordinator = CameraPermissionCoordinator(gateway);

        expect(
          await coordinator.requestAccess(),
          CameraPermissionAccess.granted,
        );
        expect(gateway.requestCalls, 1);
      },
    );

    test('returns denied after a rejected native prompt', () async {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.denied,
        requestResult: CameraPermissionAccess.denied,
      );

      expect(
        await CameraPermissionCoordinator(gateway).requestAccess(),
        CameraPermissionAccess.denied,
      );
      expect(gateway.requestCalls, 1);
    });

    test(
      'permanent denial and restriction never trigger another prompt',
      () async {
        for (final access in [
          CameraPermissionAccess.permanentlyDenied,
          CameraPermissionAccess.restricted,
        ]) {
          final gateway = _FakeCameraPermissionGateway(current: access);

          expect(
            await CameraPermissionCoordinator(gateway).requestAccess(),
            access,
          );
          expect(gateway.requestCalls, 0);
        }
      },
    );

    test('concurrent callers share one native permission request', () async {
      final requestResult = Completer<CameraPermissionAccess>();
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.denied,
        pendingRequest: requestResult.future,
      );
      final coordinator = CameraPermissionCoordinator(gateway);

      final first = coordinator.requestAccess();
      final second = coordinator.requestAccess();
      await Future<void>.delayed(Duration.zero);

      expect(gateway.statusCalls, 1);
      expect(gateway.requestCalls, 1);
      requestResult.complete(CameraPermissionAccess.granted);
      expect(await Future.wait([first, second]), [
        CameraPermissionAccess.granted,
        CameraPermissionAccess.granted,
      ]);
    });

    test(
      'Settings return is rechecked without another permission prompt',
      () async {
        final gateway = _FakeCameraPermissionGateway(
          current: CameraPermissionAccess.permanentlyDenied,
        );
        final coordinator = CameraPermissionCoordinator(gateway);

        expect(await coordinator.openSettings(), isTrue);
        gateway.current = CameraPermissionAccess.granted;

        expect(await coordinator.checkAccess(), CameraPermissionAccess.granted);
        expect(gateway.openSettingsCalls, 1);
        expect(gateway.requestCalls, 0);
      },
    );
  });
}

final class _FakeCameraPermissionGateway implements CameraPermissionGateway {
  _FakeCameraPermissionGateway({
    required this.current,
    this.requestResult = CameraPermissionAccess.denied,
    this.pendingRequest,
  });

  CameraPermissionAccess current;
  final CameraPermissionAccess requestResult;
  final Future<CameraPermissionAccess>? pendingRequest;
  int statusCalls = 0;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<CameraPermissionAccess> status() async {
    statusCalls += 1;
    return current;
  }

  @override
  Future<CameraPermissionAccess> request() async {
    requestCalls += 1;
    final result = await (pendingRequest ?? Future.value(requestResult));
    current = result;
    return result;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCalls += 1;
    return true;
  }
}
