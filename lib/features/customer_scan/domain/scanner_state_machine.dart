enum CustomerScannerState {
  idle,
  requestingPermission,
  cameraPermissionRequired,
  cameraPermissionDenied,
  ready,
  scanning,
  candidateCaptured,
  resolving,
  invalidQr,
  unsupportedQr,
  membershipNotFound,
  membershipInactive,
  locationNotEligible,
  deviceUnauthorized,
  networkFailure,
  updateRequired,
  ambiguousRecovery,
  cancelled,
  backgrounded,
}

final class CustomerScannerStateMachine {
  CustomerScannerStateMachine({
    this.duplicateDebounce = const Duration(milliseconds: 900),
  });

  final Duration duplicateDebounce;
  CustomerScannerState state = CustomerScannerState.idle;
  DateTime? _lastCaptureAt;

  void requestPermission() => state = CustomerScannerState.requestingPermission;
  void permissionRequired() =>
      state = CustomerScannerState.cameraPermissionRequired;
  void permissionDenied() =>
      state = CustomerScannerState.cameraPermissionDenied;
  void ready() => state = CustomerScannerState.ready;

  void scanning() {
    if (state == CustomerScannerState.ready) {
      state = CustomerScannerState.scanning;
    }
  }

  bool capture(DateTime now) {
    if (state != CustomerScannerState.ready &&
        state != CustomerScannerState.scanning) {
      return false;
    }
    final previous = _lastCaptureAt;
    if (previous != null && now.difference(previous) < duplicateDebounce) {
      return false;
    }
    _lastCaptureAt = now;
    state = CustomerScannerState.candidateCaptured;
    return true;
  }

  void resolving() {
    if (state == CustomerScannerState.candidateCaptured) {
      state = CustomerScannerState.resolving;
    }
  }

  void fail(CustomerScannerState failure) {
    const allowed = {
      CustomerScannerState.invalidQr,
      CustomerScannerState.unsupportedQr,
      CustomerScannerState.membershipNotFound,
      CustomerScannerState.membershipInactive,
      CustomerScannerState.locationNotEligible,
      CustomerScannerState.deviceUnauthorized,
      CustomerScannerState.networkFailure,
      CustomerScannerState.updateRequired,
      CustomerScannerState.ambiguousRecovery,
    };
    if (!allowed.contains(failure)) {
      throw ArgumentError.value(failure, 'failure');
    }
    state = failure;
  }

  void cancel() => state = CustomerScannerState.cancelled;
  void background() => state = CustomerScannerState.backgrounded;

  void reset() {
    _lastCaptureAt = null;
    state = CustomerScannerState.idle;
  }
}
