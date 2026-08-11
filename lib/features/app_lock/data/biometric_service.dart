import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

abstract interface class BiometricService {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

final class PlatformBiometricService implements BiometricService {
  PlatformBiometricService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _authentication.isDeviceSupported() &&
          (await _authentication.getAvailableBiometrics()).isNotEmpty;
    } on LocalAuthException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _authentication.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: false,
      );
    } on LocalAuthException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

final class FakeBiometricService implements BiometricService {
  FakeBiometricService({this.available = true, this.result = true});

  bool available;
  bool result;
  int calls = 0;

  @override
  Future<bool> authenticate(String reason) async {
    calls += 1;
    return result;
  }

  @override
  Future<bool> isAvailable() async => available;
}
