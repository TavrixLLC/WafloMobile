import 'dart:convert';

import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

final class StaffDeviceSession {
  const StaffDeviceSession({
    required this.devicePublicId,
    required this.deviceDisplayName,
    required this.devicePlatform,
    required this.deviceStatus,
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.organizationId,
    required this.role,
    required this.locationId,
    required this.issuedAt,
  });

  final String devicePublicId;
  final String deviceDisplayName;
  final String devicePlatform;
  final String deviceStatus;
  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final String organizationId;
  final String role;
  final String locationId;
  final DateTime issuedAt;

  bool isExpired(DateTime now, {Duration skew = const Duration(minutes: 1)}) =>
      !accessExpiresAt.isAfter(now.toUtc().add(skew));

  Map<String, Object?> toJson() => {
    'recordVersion': 1,
    'devicePublicId': devicePublicId,
    'deviceDisplayName': deviceDisplayName,
    'devicePlatform': devicePlatform,
    'deviceStatus': deviceStatus,
    'sessionId': sessionId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessExpiresAt': accessExpiresAt.toUtc().toIso8601String(),
    'organizationId': organizationId,
    'role': role,
    'locationId': locationId,
    'issuedAt': issuedAt.toUtc().toIso8601String(),
  };

  @override
  String toString() =>
      'StaffDeviceSession(device: [REDACTED], session: [REDACTED], status: $deviceStatus)';

  static StaffDeviceSession fromJson(Object? value) {
    if (value is! Map<String, Object?> || value['recordVersion'] != 1) {
      throw const FormatException('Unsupported session record.');
    }
    String stringField(String name, {int minimum = 1, int maximum = 512}) {
      final field = value[name];
      if (field is! String ||
          field.length < minimum ||
          field.length > maximum) {
        throw FormatException('Invalid $name.');
      }
      return field;
    }

    DateTime dateField(String name) {
      final parsed = DateTime.tryParse(stringField(name, maximum: 40));
      if (parsed == null) {
        throw FormatException('Invalid $name.');
      }
      return parsed.toUtc();
    }

    return StaffDeviceSession(
      devicePublicId: stringField('devicePublicId', maximum: 64),
      deviceDisplayName: stringField('deviceDisplayName', maximum: 120),
      devicePlatform: stringField('devicePlatform', maximum: 32),
      deviceStatus: stringField('deviceStatus', maximum: 32),
      sessionId: stringField('sessionId', maximum: 64),
      accessToken: stringField('accessToken', minimum: 40),
      refreshToken: stringField('refreshToken', minimum: 40),
      accessExpiresAt: dateField('accessExpiresAt'),
      organizationId: stringField('organizationId', maximum: 64),
      role: stringField('role', maximum: 32),
      locationId: stringField('locationId', maximum: 64),
      issuedAt: dateField('issuedAt'),
    );
  }
}

final class StaffDeviceSessionRepository {
  StaffDeviceSessionRepository(this._store);

  static const _sessionKey = 'staff_device.session.v1';
  final SecureKeyValueStore _store;

  Future<StaffDeviceSession?> read() async {
    final raw = await _store.read(_sessionKey);
    if (raw == null) {
      return null;
    }
    try {
      return StaffDeviceSession.fromJson(jsonDecode(raw));
    } on FormatException {
      throw const LocalSecurityFailure('LOCAL_SESSION_CORRUPT');
    }
  }

  Future<void> replaceAtomically(StaffDeviceSession session) async {
    try {
      await _store.write(_sessionKey, jsonEncode(session.toJson()));
      final verified = await read();
      if (verified == null || verified.sessionId != session.sessionId) {
        throw const FormatException('Session verification failed.');
      }
    } on Object {
      throw const SecurePersistenceFailure();
    }
  }

  Future<void> clear() => _store.delete(_sessionKey);
}

enum PairingTransactionStage { claim, signing, completing, persisting }

final class PairingTransactionRepository {
  PairingTransactionRepository(this._store);

  static const _key = 'pairing.transaction.v1';
  final SecureKeyValueStore _store;

  Future<void> mark({
    required String pairingPublicId,
    required PairingTransactionStage stage,
  }) => _store.write(
    _key,
    jsonEncode({
      'recordVersion': 1,
      'pairingPublicId': pairingPublicId,
      'stage': stage.name,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }),
  );

  Future<PairingTransactionStage?> readStage() async {
    final raw = await _store.read(_key);
    if (raw == null) {
      return null;
    }
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> || value['recordVersion'] != 1) {
        return PairingTransactionStage.persisting;
      }
      final stage = value['stage'];
      if (stage is! String) {
        return PairingTransactionStage.persisting;
      }
      return PairingTransactionStage.values.firstWhere(
        (candidate) => candidate.name == stage,
        orElse: () => PairingTransactionStage.persisting,
      );
    } on FormatException {
      return PairingTransactionStage.persisting;
    }
  }

  Future<void> clear() => _store.delete(_key);
}
