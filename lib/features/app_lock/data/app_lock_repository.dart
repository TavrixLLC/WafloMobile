import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';

abstract interface class AppLockStore {
  AppLockConfiguration readConfiguration();
  Future<void> setConfiguration(AppLockConfiguration configuration);
  Future<void> setPin(String pin);
  Future<bool> hasPin();
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();
  Future<PinRateLimit> readRateLimit();
  Future<PinRateLimit> registerFailure(DateTime now);
  Future<void> clearRateLimit();
}

final class AppLockRepository implements AppLockStore {
  AppLockRepository(this._preferences, this._secureStore);

  static const _modeKey = 'app_lock.mode.v1';
  static const _intervalKey = 'app_lock.interval.v1';
  static const _pinMaterialKey = 'app_lock.pin_material.v1';
  static const _rateLimitKey = 'app_lock.pin_rate_limit.v1';
  static const _pinIterations = 120000;
  static final _pinPattern = RegExp(r'^[0-9]{4,6}$');

  final SharedPreferences _preferences;
  final SecureKeyValueStore _secureStore;

  @override
  AppLockConfiguration readConfiguration() => AppLockConfiguration(
    mode: switch (_preferences.getString(_modeKey)) {
      'pin' => AppLockMode.pin,
      'biometricWithPin' => AppLockMode.biometric,
      _ => AppLockMode.off,
    },
    interval: AppLockInterval.values.firstWhere(
      (value) => value.name == _preferences.getString(_intervalKey),
      orElse: () => AppLockInterval.immediately,
    ),
  );

  @override
  Future<void> setConfiguration(AppLockConfiguration configuration) async {
    await _preferences.setString(
      _modeKey,
      configuration.mode == AppLockMode.biometric
          ? 'biometricWithPin'
          : configuration.mode.name,
    );
    await _preferences.setString(_intervalKey, configuration.interval.name);
  }

  @override
  Future<void> setPin(String pin) async {
    _validatePin(pin);
    final random = Random.secure();
    final salt = List<int>.generate(24, (_) => random.nextInt(256));
    final verifier = await _derive(pin, salt);
    await _secureStore.write(
      _pinMaterialKey,
      jsonEncode({
        'version': 1,
        'iterations': _pinIterations,
        'salt': base64UrlEncode(salt),
        'verifier': base64UrlEncode(verifier),
      }),
    );
    await clearRateLimit();
  }

  @override
  Future<bool> verifyPin(String pin) async {
    if (!_pinPattern.hasMatch(pin)) return false;
    final raw = await _secureStore.read(_pinMaterialKey);
    if (raw == null) return false;
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> ||
          value['version'] != 1 ||
          value['iterations'] != _pinIterations ||
          value['salt'] is! String ||
          value['verifier'] is! String) {
        return false;
      }
      final salt = base64Url.decode(value['salt']! as String);
      final expected = base64Url.decode(value['verifier']! as String);
      final actual = await _derive(pin, salt);
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var index = 0; index < actual.length; index += 1) {
        difference |= actual[index] ^ expected[index];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  @override
  Future<bool> hasPin() async {
    final raw = await _secureStore.read(_pinMaterialKey);
    if (raw == null) return false;
    try {
      final value = jsonDecode(raw);
      return value is Map<String, Object?> &&
          value['version'] == 1 &&
          value['iterations'] == _pinIterations &&
          value['salt'] is String &&
          value['verifier'] is String &&
          base64Url.decode(value['salt']! as String).isNotEmpty &&
          base64Url.decode(value['verifier']! as String).isNotEmpty;
    } on FormatException {
      return false;
    }
  }

  @override
  Future<void> clearPin() async {
    await _secureStore.delete(_pinMaterialKey);
    await clearRateLimit();
  }

  @override
  Future<PinRateLimit> readRateLimit() async {
    final raw = await _secureStore.read(_rateLimitKey);
    if (raw == null) return const PinRateLimit(failures: 0);
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> || value['failures'] is! int) {
        return const PinRateLimit(failures: 0);
      }
      final retry = value['retryAt'];
      return PinRateLimit(
        failures: value['failures']! as int,
        retryAt: retry is String ? DateTime.tryParse(retry) : null,
      );
    } on FormatException {
      return const PinRateLimit(failures: 0);
    }
  }

  @override
  Future<PinRateLimit> registerFailure(DateTime now) async {
    final previous = await readRateLimit();
    final failures = previous.failures + 1;
    final delay = PinRateLimitPolicy.delayFor(failures);
    final retryAt = delay == Duration.zero ? null : now.toUtc().add(delay);
    await _secureStore.write(
      _rateLimitKey,
      jsonEncode({'failures': failures, 'retryAt': retryAt?.toIso8601String()}),
    );
    return PinRateLimit(failures: failures, retryAt: retryAt);
  }

  @override
  Future<void> clearRateLimit() => _secureStore.delete(_rateLimitKey);

  Future<List<int>> _derive(String pin, List<int> salt) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _pinIterations,
      bits: 256,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  static void _validatePin(String pin) {
    if (!_pinPattern.hasMatch(pin)) {
      throw const FormatException('PIN_FORMAT_INVALID');
    }
  }
}
