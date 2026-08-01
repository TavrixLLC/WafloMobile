import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/models/device_context_success.dart';
import 'package:waflo_staff/core/api/generated/models/session_refresh_success.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

abstract interface class DeviceSessionApi {
  Future<StaffDeviceSession> refresh(StaffDeviceSession current);
  Future<AuthoritativeDeviceContext> getContext(StaffDeviceSession current);
  Future<void> logout(StaffDeviceSession current);
}

final class SignedDeviceApi implements DeviceSessionApi {
  const SignedDeviceApi(this._dio, this._signer, this._errorDecoder);

  static const _refreshPath = '/v1/staff/devices/session/refresh';
  static const _logoutPath = '/v1/staff/devices/session/logout';
  static const _contextPath = '/v1/staff/device-context';

  final Dio _dio;
  final DeviceRequestSigner _signer;
  final ApiErrorDecoder _errorDecoder;

  @override
  Future<StaffDeviceSession> refresh(StaffDeviceSession current) async {
    final body = jsonEncode({'refreshToken': current.refreshToken});
    try {
      final response = await _send(
        method: 'POST',
        path: _refreshPath,
        body: body,
        session: current,
      );
      final parsed = SessionRefreshSuccess.fromJson(_jsonMap(response.data));
      final replacement = parsed.data.session;
      return StaffDeviceSession(
        devicePublicId: current.devicePublicId,
        deviceDisplayName: current.deviceDisplayName,
        devicePlatform: current.devicePlatform,
        deviceStatus: current.deviceStatus,
        sessionId: replacement.id,
        accessToken: replacement.token,
        refreshToken: replacement.refreshToken,
        accessExpiresAt: replacement.expiresAt.toUtc(),
        organizationId: current.organizationId,
        role: current.role,
        locationId: current.locationId,
        issuedAt: DateTime.now().toUtc(),
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }

  @override
  Future<AuthoritativeDeviceContext> getContext(
    StaffDeviceSession current,
  ) async {
    for (var attempt = 0; attempt < 2; attempt += 1) {
      try {
        final response = await _send(
          method: 'GET',
          path: _contextPath,
          body: null,
          session: current,
        );
        final parsed = DeviceContextSuccess.fromJson(_jsonMap(response.data));
        final data = parsed.data;
        if (data.organizationId != current.organizationId ||
            data.devicePublicId != current.devicePublicId ||
            data.deviceSessionId != current.sessionId) {
          throw const ApiFailure('DEVICE_CONTEXT_MISMATCH');
        }
        final role = data.role.json;
        final platform = data.platform.json;
        if (role == null || platform == null) {
          throw const ApiFailure('INVALID_RESPONSE_BODY');
        }
        return AuthoritativeDeviceContext(
          organizationId: data.organizationId,
          organizationMemberId: data.organizationMemberId,
          role: role,
          locationId: data.locationId,
          deviceId: data.deviceId,
          devicePublicId: data.devicePublicId,
          deviceSessionId: data.deviceSessionId,
          platform: platform,
          requestId: data.requestId,
          synchronizedAt: DateTime.now().toUtc(),
        );
      } on Object catch (error) {
        final failure = _errorDecoder.decode(error);
        if (attempt == 0 && failure is NetworkFailure) {
          continue;
        }
        throw failure;
      }
    }
    throw const NetworkFailure();
  }

  @override
  Future<void> logout(StaffDeviceSession current) async {
    try {
      await _send(
        method: 'POST',
        path: _logoutPath,
        body: null,
        session: current,
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }

  Future<Response<Object?>> _send({
    required String method,
    required String path,
    required String? body,
    required StaffDeviceSession session,
  }) async {
    final bodyBytes = body == null ? const <int>[] : utf8.encode(body);
    final headers = await _signer.sign(
      method: method,
      canonicalPath: path,
      exactBodyBytes: bodyBytes,
      accessToken: session.accessToken,
      devicePublicId: session.devicePublicId,
      deviceSessionId: session.sessionId,
      organizationId: session.organizationId,
    );
    return _dio.request<Object?>(
      path,
      data: body,
      options: Options(
        method: method,
        headers: headers.toHttpHeaders(),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        followRedirects: false,
      ),
    );
  }

  static Map<String, Object?> _jsonMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    throw const ApiFailure('INVALID_RESPONSE_BODY');
  }
}
