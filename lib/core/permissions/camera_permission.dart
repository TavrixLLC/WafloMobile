import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionAccess { granted, denied, permanentlyDenied, restricted }

abstract interface class CameraPermissionGateway {
  Future<CameraPermissionAccess> status();
  Future<CameraPermissionAccess> request();
  Future<bool> openSettings();
}

final class PermissionHandlerCameraPermissionGateway
    implements CameraPermissionGateway {
  const PermissionHandlerCameraPermissionGateway();

  @override
  Future<CameraPermissionAccess> status() async =>
      _mapStatus(await Permission.camera.status);

  @override
  Future<CameraPermissionAccess> request() async =>
      _mapStatus(await Permission.camera.request());

  @override
  Future<bool> openSettings() => openAppSettings();

  static CameraPermissionAccess _mapStatus(PermissionStatus status) {
    if (status.isGranted) return CameraPermissionAccess.granted;
    if (status.isPermanentlyDenied) {
      return CameraPermissionAccess.permanentlyDenied;
    }
    if (status.isRestricted) return CameraPermissionAccess.restricted;
    return CameraPermissionAccess.denied;
  }
}

/// Owns camera permission requests so rebuilds and lifecycle callbacks cannot
/// create concurrent native prompts.
final class CameraPermissionCoordinator {
  CameraPermissionCoordinator(this._gateway);

  final CameraPermissionGateway _gateway;
  Future<CameraPermissionAccess>? _requestInFlight;

  /// Checks current access without displaying a native permission prompt.
  Future<CameraPermissionAccess> checkAccess() => _gateway.status();

  /// Requests access only when the current status is requestable.
  Future<CameraPermissionAccess> requestAccess() {
    final running = _requestInFlight;
    if (running != null) return running;
    final operation = _requestAccess();
    _requestInFlight = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_requestInFlight, operation)) {
          _requestInFlight = null;
        }
      }),
    );
    return operation;
  }

  Future<CameraPermissionAccess> _requestAccess() async {
    final current = await _gateway.status();
    if (current != CameraPermissionAccess.denied) return current;
    return _gateway.request();
  }

  Future<bool> openSettings() => _gateway.openSettings();
}
