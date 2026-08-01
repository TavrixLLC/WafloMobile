import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

final class DeviceIdentity {
  const DeviceIdentity({
    required this.installationId,
    required this.keyAlgorithm,
    required this.publicKey,
    required this.privateKeyReference,
    required this.createdAt,
    required this.keyVersion,
  });

  final String installationId;
  final String keyAlgorithm;
  final String publicKey;
  final String privateKeyReference;
  final DateTime createdAt;
  final int keyVersion;

  @override
  String toString() =>
      'DeviceIdentity(installationId: [REDACTED], algorithm: $keyAlgorithm, keyVersion: $keyVersion)';
}

final class DeviceIdentityRepository {
  DeviceIdentityRepository(
    this._store, {
    Ed25519? algorithm,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _algorithm = algorithm ?? Ed25519(),
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  static const _identityKey = 'device.identity.v1';
  static const _privateKeyReference = 'device.identity.v1#private';
  static const _recordVersion = 1;
  static const _spkiPrefix = <int>[
    0x30,
    0x2a,
    0x30,
    0x05,
    0x06,
    0x03,
    0x2b,
    0x65,
    0x70,
    0x03,
    0x21,
    0x00,
  ];

  final SecureKeyValueStore _store;
  final Ed25519 _algorithm;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<DeviceIdentity?> load() async {
    final raw = await _store.read(_identityKey);
    if (raw == null) {
      return null;
    }
    return _decode(raw).identity;
  }

  Future<DeviceIdentity> loadOrCreate() async {
    final existing = await load();
    if (existing != null) {
      return existing;
    }
    final keyPair = await _algorithm.newKeyPair();
    try {
      final privateBytes = await keyPair.extractPrivateKeyBytes();
      final publicKey = await keyPair.extractPublicKey();
      final createdAt = _now().toUtc();
      final record = _IdentityRecord(
        identity: DeviceIdentity(
          installationId: _uuid.v4(),
          keyAlgorithm: 'Ed25519',
          publicKey: _encodeSpki(publicKey.bytes),
          privateKeyReference: _privateKeyReference,
          createdAt: createdAt,
          keyVersion: 1,
        ),
        privateKeyBytes: privateBytes,
        publicKeyBytes: publicKey.bytes,
      );
      await _store.write(_identityKey, jsonEncode(record.toJson()));
      return record.identity;
    } finally {
      keyPair.destroy();
    }
  }

  Future<String> signUtf8(String message) async {
    final raw = await _store.read(_identityKey);
    if (raw == null) {
      throw const LocalSecurityFailure('LOCAL_KEY_MISSING');
    }
    final record = _decode(raw);
    final keyPair = SimpleKeyPairData(
      record.privateKeyBytes,
      publicKey: SimplePublicKey(
        record.publicKeyBytes,
        type: KeyPairType.ed25519,
      ),
      type: KeyPairType.ed25519,
    );
    try {
      final signature = await _algorithm.sign(
        utf8.encode(message),
        keyPair: keyPair,
      );
      return _base64UrlNoPadding(signature.bytes);
    } finally {
      keyPair.destroy();
    }
  }

  Future<void> delete() => _store.delete(_identityKey);

  _IdentityRecord _decode(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> ||
          value['recordVersion'] != _recordVersion) {
        throw const FormatException('Unsupported identity record.');
      }
      final installationId = value['installationId'];
      final algorithm = value['keyAlgorithm'];
      final publicKey = value['publicKey'];
      final privateKey = value['privateKey'];
      final publicKeyRaw = value['publicKeyRaw'];
      final createdAt = value['createdAt'];
      final keyVersion = value['keyVersion'];
      if (installationId is! String ||
          algorithm is! String ||
          algorithm != 'Ed25519' ||
          publicKey is! String ||
          privateKey is! String ||
          publicKeyRaw is! String ||
          createdAt is! String ||
          keyVersion is! int) {
        throw const FormatException('Corrupt identity record.');
      }
      final parsedDate = DateTime.tryParse(createdAt);
      final privateBytes = _base64UrlDecode(privateKey);
      final publicBytes = _base64UrlDecode(publicKeyRaw);
      if (parsedDate == null ||
          privateBytes.length != 32 ||
          publicBytes.length != 32 ||
          publicKey != _encodeSpki(publicBytes)) {
        throw const FormatException('Invalid identity material.');
      }
      return _IdentityRecord(
        identity: DeviceIdentity(
          installationId: installationId,
          keyAlgorithm: algorithm,
          publicKey: publicKey,
          privateKeyReference: _privateKeyReference,
          createdAt: parsedDate,
          keyVersion: keyVersion,
        ),
        privateKeyBytes: privateBytes,
        publicKeyBytes: publicBytes,
      );
    } on FormatException {
      throw const LocalSecurityFailure('LOCAL_KEY_CORRUPT');
    }
  }

  static String _encodeSpki(List<int> publicKeyBytes) =>
      base64.encode([..._spkiPrefix, ...publicKeyBytes]);

  static String _base64UrlNoPadding(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static Uint8List _base64UrlDecode(String value) {
    final padded = value.padRight((value.length + 3) ~/ 4 * 4, '=');
    return base64Url.decode(padded);
  }
}

final class _IdentityRecord {
  const _IdentityRecord({
    required this.identity,
    required this.privateKeyBytes,
    required this.publicKeyBytes,
  });

  final DeviceIdentity identity;
  final List<int> privateKeyBytes;
  final List<int> publicKeyBytes;

  Map<String, Object?> toJson() => {
    'recordVersion': 1,
    'installationId': identity.installationId,
    'keyAlgorithm': identity.keyAlgorithm,
    'publicKey': identity.publicKey,
    'privateKey': DeviceIdentityRepository._base64UrlNoPadding(privateKeyBytes),
    'publicKeyRaw': DeviceIdentityRepository._base64UrlNoPadding(
      publicKeyBytes,
    ),
    'createdAt': identity.createdAt.toUtc().toIso8601String(),
    'keyVersion': identity.keyVersion,
  };
}
