sealed class AppFailure implements Exception {
  const AppFailure(this.safeCode, {this.requestId, this.httpStatus});

  final String safeCode;
  final String? requestId;
  final int? httpStatus;

  @override
  String toString() => 'AppFailure($safeCode, requestId: $requestId)';
}

final class ApiFailure extends AppFailure {
  const ApiFailure(
    super.safeCode, {
    super.requestId,
    super.httpStatus,
    this.responseReceived = true,
  });

  final bool responseReceived;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure() : super('BACKEND_UNAVAILABLE');
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure(this.issues) : super('CONFIGURATION_ERROR');

  final List<String> issues;
}

final class LocalSecurityFailure extends AppFailure {
  const LocalSecurityFailure(super.safeCode);
}

final class SecurePersistenceFailure extends AppFailure {
  const SecurePersistenceFailure() : super('SECURE_PERSISTENCE_FAILED');
}

enum FailureDisposition {
  pairingExpired,
  pairingUsed,
  pairingInvalid,
  sessionExpired,
  deviceRevoked,
  deviceCompromised,
  updateRequired,
  backendUnavailable,
  localSecurity,
  retryable,
  generic,
}

FailureDisposition classifyFailure(AppFailure failure) =>
    switch (failure.safeCode) {
      'DEVICE_PAIRING_EXPIRED' => FailureDisposition.pairingExpired,
      'DEVICE_PAIRING_ALREADY_USED' => FailureDisposition.pairingUsed,
      'DEVICE_PAIRING_INVALID' => FailureDisposition.pairingInvalid,
      'STAFF_DEVICE_REVOKED' => FailureDisposition.deviceRevoked,
      'STAFF_DEVICE_COMPROMISED' => FailureDisposition.deviceCompromised,
      'APP_UPDATE_REQUIRED' ||
      'STAFF_APP_VERSION_UNSUPPORTED' => FailureDisposition.updateRequired,
      'STAFF_DEVICE_SESSION_EXPIRED' ||
      'STAFF_DEVICE_NOT_ACTIVE' => FailureDisposition.sessionExpired,
      'BACKEND_UNAVAILABLE' => FailureDisposition.backendUnavailable,
      'LOCAL_KEY_MISSING' ||
      'LOCAL_KEY_CORRUPT' ||
      'SECURE_PERSISTENCE_FAILED' => FailureDisposition.localSecurity,
      'RATE_LIMITED' || 'INTERNAL_ERROR' => FailureDisposition.retryable,
      _ => FailureDisposition.generic,
    };
