import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/logging/safe_logger.dart';
import 'package:waflo_staff/core/storage/preferences_repository.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';

void main() {
  test('stable error code maps to state and preserves request ID', () {
    final response = Response<Object?>(
      requestOptions: RequestOptions(path: '/fixture'),
      statusCode: 409,
      data: {
        'error': {
          'code': 'STAFF_DEVICE_NONCE_REPLAYED',
          'message': 'diagnostic text',
          'requestId': '00000000-0000-4000-8000-000000000104',
        },
      },
    );
    final failure = const ApiErrorDecoder().decode(
      DioException(requestOptions: response.requestOptions, response: response),
    );
    expect(failure.safeCode, 'STAFF_DEVICE_NONCE_REPLAYED');
    expect(failure.requestId, '00000000-0000-4000-8000-000000000104');
    expect(classifyFailure(failure), FailureDisposition.generic);
  });

  test(
    'revoked, compromised, expired, and update codes classify explicitly',
    () {
      expect(
        classifyFailure(const ApiFailure('DEVICE_REVOKED')),
        FailureDisposition.deviceRevoked,
      );
      expect(
        classifyFailure(const ApiFailure('DEVICE_COMPROMISED')),
        FailureDisposition.deviceCompromised,
      );
      expect(
        classifyFailure(const ApiFailure('STAFF_DEVICE_NOT_ACTIVE')),
        FailureDisposition.sessionExpired,
      );
      expect(
        classifyFailure(const ApiFailure('APP_UPDATE_REQUIRED')),
        FailureDisposition.updateRequired,
      );
    },
  );

  test('logger redacts representative secrets and drops unknown fields', () {
    final sink = _MemoryLogSink();
    final logger = SafeLogger(AppLogLevel.debug, sink: sink);
    const pairingQr =
        'waflo-pair-v1.MDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMTAw.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.dGVzdA';
    logger.event(
      'request.failed',
      fields: {
        'errorCode': 'DEVICE_PAIRING_INVALID',
        'requestId': 'safe-request-id',
        'accessToken': 'must-not-appear',
      },
    );
    sink.write(
      'Authorization: Device token-value $pairingQr '
      '${jsonEncode({'privateKey': 'private-value', 'nonce': 'nonce-value'})}',
    );
    final output = const SensitiveRedactor().redact(sink.messages.join('\n'));
    expect(output, contains('safe-request-id'));
    expect(output, isNot(contains('must-not-appear')));
    expect(output, isNot(contains('token-value')));
    expect(output, isNot(contains(pairingQr)));
    expect(output, isNot(contains('private-value')));
    expect(output, isNot(contains('nonce-value')));
  });

  test('locale and theme persist while safe context contains no IDs', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = PreferencesRepository(
      await SharedPreferences.getInstance(),
    );
    await repository.setLocale(const Locale('ar'));
    await repository.setThemeMode(ThemeMode.dark);
    await repository.setSafeContext(
      SafeContextCache(
        role: 'STAFF',
        platform: 'ANDROID',
        deviceDisplayName: 'Test device',
        lastSynchronizedAt: DateTime.utc(2026),
      ),
    );
    expect(repository.readLocale(), const Locale('ar'));
    expect(repository.readThemeMode(), ThemeMode.dark);
    final cache = repository.readSafeContext();
    expect(cache?.role, 'STAFF');
    expect(cache?.toJson().keys, isNot(contains('organizationId')));
  });

  test('device context exposes count without inventing backend names', () {
    final context = AuthoritativeDeviceContext(
      organizationId: 'organization-id',
      organizationMemberId: 'member-id',
      role: 'MANAGER',
      locationId: 'location-id',
      deviceId: 'device-id',
      devicePublicId: 'public-id',
      deviceSessionId: 'session-id',
      platform: 'IOS',
      requestId: 'request-id',
      synchronizedAt: DateTime.utc(2026),
    );
    expect(context.assignedLocationCount, 1);
    expect(context.toString(), isNot(contains('organization-id')));
  });
}

final class _MemoryLogSink implements SafeLogSink {
  final List<String> messages = [];

  @override
  void write(String message) => messages.add(message);
}
