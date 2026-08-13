import 'dart:convert';

import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';

enum StaffSessionMode { normal, review }

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
    this.sessionMode = StaffSessionMode.normal,
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
  final StaffSessionMode sessionMode;

  bool get isReview => sessionMode == StaffSessionMode.review;

  bool isExpired(DateTime now, {Duration skew = const Duration(minutes: 1)}) =>
      !accessExpiresAt.isAfter(now.toUtc().add(skew));

  Map<String, Object?> toJson() => {
    'recordVersion': 2,
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
    'sessionMode': sessionMode.name.toUpperCase(),
  };

  @override
  String toString() =>
      'StaffDeviceSession(device: [REDACTED], session: [REDACTED], status: $deviceStatus)';

  static StaffDeviceSession fromJson(Object? value) {
    if (value is! Map<String, Object?> ||
        (value['recordVersion'] != 1 && value['recordVersion'] != 2)) {
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

    final rawMode = value['recordVersion'] == 1
        ? 'NORMAL'
        : stringField('sessionMode', maximum: 16);
    final sessionMode = switch (rawMode) {
      'NORMAL' => StaffSessionMode.normal,
      'REVIEW' => StaffSessionMode.review,
      _ => throw const FormatException('Invalid sessionMode.'),
    };
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
      sessionMode: sessionMode,
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

enum PairingTransactionStage {
  claimPending,
  claimed,
  signing,
  completing,
  persisting,
}

final class PairingTransaction {
  const PairingTransaction({
    required this.pairingPublicId,
    required this.stage,
    required this.updatedAt,
    this.challenge,
    this.challengeExpiresAt,
    this.message,
    this.signature,
    this.sessionMode = StaffSessionMode.normal,
  });

  final String pairingPublicId;
  final PairingTransactionStage stage;
  final String? challenge;
  final DateTime? challengeExpiresAt;
  final String? message;
  final String? signature;
  final DateTime updatedAt;
  final StaffSessionMode sessionMode;

  bool get isRecoverable =>
      stage == PairingTransactionStage.claimPending ||
      stage == PairingTransactionStage.claimed ||
      stage == PairingTransactionStage.signing;

  bool get isCompletionAmbiguous =>
      stage == PairingTransactionStage.completing ||
      stage == PairingTransactionStage.persisting;
}

final class PairingTransactionRepository {
  PairingTransactionRepository(this._store, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const _key = 'pairing.transaction.v2';
  static const _legacyKey = 'pairing.transaction.v1';
  static const _recordVersion = 3;
  final SecureKeyValueStore _store;
  final DateTime Function() _now;

  Future<void> mark({
    required String pairingPublicId,
    required PairingTransactionStage stage,
    String? challenge,
    DateTime? challengeExpiresAt,
    String? message,
    String? signature,
    StaffSessionMode? sessionMode,
  }) async {
    final current = await read();
    await save(
      PairingTransaction(
        pairingPublicId: pairingPublicId,
        stage: stage,
        challenge: challenge ?? current?.challenge,
        challengeExpiresAt: challengeExpiresAt ?? current?.challengeExpiresAt,
        message: message ?? current?.message,
        signature: signature ?? current?.signature,
        sessionMode:
            sessionMode ?? current?.sessionMode ?? StaffSessionMode.normal,
        updatedAt: _now().toUtc(),
      ),
    );
  }

  Future<void> save(PairingTransaction transaction) async {
    try {
      await _store.write(
        _key,
        jsonEncode({
          'recordVersion': _recordVersion,
          'pairingPublicId': transaction.pairingPublicId,
          'stage': transaction.stage.name,
          if (transaction.challenge != null) 'challenge': transaction.challenge,
          if (transaction.challengeExpiresAt != null)
            'challengeExpiresAt': transaction.challengeExpiresAt!
                .toUtc()
                .toIso8601String(),
          if (transaction.message != null) 'message': transaction.message,
          if (transaction.signature != null) 'signature': transaction.signature,
          'updatedAt': transaction.updatedAt.toUtc().toIso8601String(),
          'sessionMode': transaction.sessionMode.name.toUpperCase(),
        }),
      );
      final verified = await read();
      if (verified == null ||
          verified.pairingPublicId != transaction.pairingPublicId ||
          verified.stage != transaction.stage) {
        throw const FormatException('Pairing transaction verification failed.');
      }
    } on SecurePersistenceFailure {
      rethrow;
    } on Object {
      throw const SecurePersistenceFailure();
    }
  }

  Future<PairingTransaction?> read() async {
    final current = await _store.read(_key);
    if (current != null) {
      return _decode(current);
    }
    final legacy = await _store.read(_legacyKey);
    if (legacy == null) {
      return null;
    }
    return _decodeLegacy(legacy);
  }

  Future<PairingTransactionStage?> readStage() async {
    return (await read())?.stage;
  }

  PairingTransaction _decode(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> ||
          (value['recordVersion'] != 2 &&
              value['recordVersion'] != _recordVersion)) {
        return _ambiguous();
      }
      final pairingPublicId = value['pairingPublicId'];
      final stage = value['stage'];
      final updatedAt = DateTime.tryParse(value['updatedAt'] as String? ?? '');
      if (pairingPublicId is! String ||
          pairingPublicId.isEmpty ||
          stage is! String ||
          updatedAt == null) {
        return _ambiguous(pairingPublicId: pairingPublicId as String?);
      }
      final resolvedStage = PairingTransactionStage.values.firstWhere(
        (candidate) => candidate.name == stage,
        orElse: () => PairingTransactionStage.persisting,
      );
      final challenge = value['challenge'];
      final challengeExpiresAt = DateTime.tryParse(
        value['challengeExpiresAt'] as String? ?? '',
      );
      final message = value['message'];
      final signature = value['signature'];
      final rawMode = value['recordVersion'] == 2
          ? 'NORMAL'
          : value['sessionMode'];
      final sessionMode = switch (rawMode) {
        'NORMAL' => StaffSessionMode.normal,
        'REVIEW' => StaffSessionMode.review,
        _ => StaffSessionMode.normal,
      };
      final needsChallenge =
          resolvedStage != PairingTransactionStage.claimPending;
      final needsSignature =
          resolvedStage == PairingTransactionStage.signing ||
          resolvedStage == PairingTransactionStage.completing ||
          resolvedStage == PairingTransactionStage.persisting;
      if ((needsChallenge &&
              (challenge is! String ||
                  challengeExpiresAt == null ||
                  message is! String)) ||
          (needsSignature && signature is! String)) {
        return _ambiguous(pairingPublicId: pairingPublicId);
      }
      return PairingTransaction(
        pairingPublicId: pairingPublicId,
        stage: resolvedStage,
        challenge: challenge as String?,
        challengeExpiresAt: challengeExpiresAt?.toUtc(),
        message: message as String?,
        signature: signature as String?,
        updatedAt: updatedAt.toUtc(),
        sessionMode: sessionMode,
      );
    } on Object {
      return _ambiguous();
    }
  }

  PairingTransaction _decodeLegacy(String raw) {
    try {
      final value = jsonDecode(raw);
      if (value is! Map<String, Object?> || value['recordVersion'] != 1) {
        return _ambiguous();
      }
      final pairingPublicId = value['pairingPublicId'];
      final stage = value['stage'];
      final updatedAt = DateTime.tryParse(value['updatedAt'] as String? ?? '');
      if (pairingPublicId is! String ||
          pairingPublicId.isEmpty ||
          stage is! String ||
          updatedAt == null) {
        return _ambiguous(pairingPublicId: pairingPublicId as String?);
      }
      if (stage == 'claim' || stage == 'signing') {
        return PairingTransaction(
          pairingPublicId: pairingPublicId,
          stage: PairingTransactionStage.claimPending,
          updatedAt: updatedAt.toUtc(),
          sessionMode: StaffSessionMode.normal,
        );
      }
      return _ambiguous(pairingPublicId: pairingPublicId);
    } on Object {
      return _ambiguous();
    }
  }

  PairingTransaction _ambiguous({String? pairingPublicId}) =>
      PairingTransaction(
        pairingPublicId: pairingPublicId ?? '',
        stage: PairingTransactionStage.persisting,
        updatedAt: _now().toUtc(),
        sessionMode: StaffSessionMode.normal,
      );

  Future<void> clear() async {
    await _store.delete(_key);
    await _store.delete(_legacyKey);
  }
}
