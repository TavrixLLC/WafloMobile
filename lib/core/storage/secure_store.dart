import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

final class PlatformSecureKeyValueStore implements SecureKeyValueStore {
  PlatformSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              resetOnError: false,
              migrateOnAlgorithmChange: true,
              migrateWithBackup: false,
              storageNamespace: 'waflo_staff_v1',
            ),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
              synchronizable: false,
              accountName: 'app.waflo.staff.secure.v1',
            ),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

final class MemorySecureKeyValueStore implements SecureKeyValueStore {
  MemorySecureKeyValueStore([Map<String, String>? values])
    : _values = {...?values};

  final Map<String, String> _values;
  bool failWrites = false;

  Map<String, String> get snapshot => Map.unmodifiable(_values);

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) {
      throw StateError('Simulated secure write failure.');
    }
    _values[key] = value;
  }
}
