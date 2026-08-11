enum AppLockMode { off, biometric, pin }

enum AppLockInterval {
  immediately(Duration.zero),
  oneMinute(Duration(minutes: 1)),
  fiveMinutes(Duration(minutes: 5));

  const AppLockInterval(this.duration);
  final Duration duration;
}

enum AppLockStatus { unlocked, locked, authenticating, rateLimited }

final class AppLockConfiguration {
  const AppLockConfiguration({
    this.mode = AppLockMode.off,
    this.interval = AppLockInterval.immediately,
  });

  final AppLockMode mode;
  final AppLockInterval interval;
}

final class AppLockState {
  const AppLockState({
    required this.configuration,
    required this.status,
    this.retryAt,
    this.safeErrorCode,
  });

  final AppLockConfiguration configuration;
  final AppLockStatus status;
  final DateTime? retryAt;
  final String? safeErrorCode;

  bool get isLocked =>
      configuration.mode != AppLockMode.off && status != AppLockStatus.unlocked;

  AppLockState copyWith({
    AppLockConfiguration? configuration,
    AppLockStatus? status,
    DateTime? retryAt,
    String? safeErrorCode,
    bool clearRetryAt = false,
    bool clearError = false,
  }) => AppLockState(
    configuration: configuration ?? this.configuration,
    status: status ?? this.status,
    retryAt: clearRetryAt ? null : retryAt ?? this.retryAt,
    safeErrorCode: clearError ? null : safeErrorCode ?? this.safeErrorCode,
  );
}

final class PinRateLimit {
  const PinRateLimit({required this.failures, this.retryAt});

  final int failures;
  final DateTime? retryAt;

  bool blockedAt(DateTime now) => retryAt?.isAfter(now.toUtc()) ?? false;
}

abstract final class PinRateLimitPolicy {
  static Duration delayFor(int failures) => switch (failures) {
    < 3 => Duration.zero,
    3 => const Duration(seconds: 5),
    4 => const Duration(seconds: 15),
    5 => const Duration(minutes: 1),
    _ => const Duration(minutes: 5),
  };
}
