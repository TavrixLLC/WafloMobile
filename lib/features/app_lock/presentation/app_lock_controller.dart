import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';

final class AppLockController extends Notifier<AppLockState> {
  DateTime? _backgroundedAt;
  Future<bool>? _authentication;

  @override
  AppLockState build() {
    final configuration = ref
        .watch(appLockRepositoryProvider)
        .readConfiguration();
    return AppLockState(
      configuration: configuration,
      status: configuration.mode == AppLockMode.off
          ? AppLockStatus.unlocked
          : AppLockStatus.locked,
    );
  }

  Future<void> setOff() async {
    await ref.read(appLockRepositoryProvider).clearPin();
    const configuration = AppLockConfiguration();
    await ref.read(appLockRepositoryProvider).setConfiguration(configuration);
    state = const AppLockState(
      configuration: configuration,
      status: AppLockStatus.unlocked,
    );
  }

  Future<void> setPin(String pin) async {
    await ref.read(appLockRepositoryProvider).setPin(pin);
    final configuration = AppLockConfiguration(
      mode: AppLockMode.pin,
      interval: state.configuration.interval,
    );
    await ref.read(appLockRepositoryProvider).setConfiguration(configuration);
    state = AppLockState(
      configuration: configuration,
      status: AppLockStatus.unlocked,
    );
  }

  Future<bool> setBiometric(String reason) async {
    final service = ref.read(biometricServiceProvider);
    if (!await service.isAvailable() || !await service.authenticate(reason)) {
      state = state.copyWith(safeErrorCode: 'BIOMETRIC_UNAVAILABLE');
      return false;
    }
    await ref.read(appLockRepositoryProvider).clearPin();
    final configuration = AppLockConfiguration(
      mode: AppLockMode.biometric,
      interval: state.configuration.interval,
    );
    await ref.read(appLockRepositoryProvider).setConfiguration(configuration);
    state = AppLockState(
      configuration: configuration,
      status: AppLockStatus.unlocked,
    );
    return true;
  }

  Future<void> setInterval(AppLockInterval interval) async {
    final configuration = AppLockConfiguration(
      mode: state.configuration.mode,
      interval: interval,
    );
    await ref.read(appLockRepositoryProvider).setConfiguration(configuration);
    state = state.copyWith(configuration: configuration);
  }

  void onBackground(DateTime at) {
    _backgroundedAt = at.toUtc();
    if (state.configuration.mode != AppLockMode.off &&
        state.configuration.interval == AppLockInterval.immediately) {
      state = state.copyWith(status: AppLockStatus.locked, clearError: true);
    }
  }

  void onResume(DateTime at) {
    final backgrounded = _backgroundedAt;
    _backgroundedAt = null;
    if (state.configuration.mode == AppLockMode.off || backgrounded == null) {
      return;
    }
    if (at.toUtc().difference(backgrounded) >=
        state.configuration.interval.duration) {
      state = state.copyWith(status: AppLockStatus.locked, clearError: true);
    }
  }

  void lockNow() {
    if (state.configuration.mode != AppLockMode.off) {
      state = state.copyWith(status: AppLockStatus.locked, clearError: true);
    }
  }

  Future<bool> unlockWithPin(String pin, DateTime now) {
    final running = _authentication;
    if (running != null) return running;
    final operation = _unlockWithPin(pin, now.toUtc());
    _authentication = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_authentication, operation)) _authentication = null;
      }),
    );
    return operation;
  }

  Future<bool> _unlockWithPin(String pin, DateTime now) async {
    if (state.configuration.mode != AppLockMode.pin) return false;
    final repository = ref.read(appLockRepositoryProvider);
    final limit = await repository.readRateLimit();
    if (limit.blockedAt(now)) {
      state = state.copyWith(
        status: AppLockStatus.rateLimited,
        retryAt: limit.retryAt,
        safeErrorCode: 'PIN_RATE_LIMITED',
      );
      return false;
    }
    state = state.copyWith(status: AppLockStatus.authenticating);
    if (!await repository.verifyPin(pin)) {
      final updated = await repository.registerFailure(now);
      state = state.copyWith(
        status: updated.blockedAt(now)
            ? AppLockStatus.rateLimited
            : AppLockStatus.locked,
        retryAt: updated.retryAt,
        safeErrorCode: 'PIN_INVALID',
      );
      return false;
    }
    await repository.clearRateLimit();
    await _completeUnlock();
    return true;
  }

  Future<bool> unlockWithBiometric(String reason) async {
    if (state.configuration.mode != AppLockMode.biometric) return false;
    state = state.copyWith(status: AppLockStatus.authenticating);
    if (!await ref.read(biometricServiceProvider).authenticate(reason)) {
      state = state.copyWith(
        status: AppLockStatus.locked,
        safeErrorCode: 'BIOMETRIC_FAILED',
      );
      return false;
    }
    await _completeUnlock();
    return true;
  }

  Future<void> _completeUnlock() async {
    state = state.copyWith(
      status: AppLockStatus.unlocked,
      clearRetryAt: true,
      clearError: true,
    );
    if (!ref.read(localDemoControllerProvider).active) {
      await ref.read(bootControllerProvider.notifier).refreshContext();
    }
  }
}
