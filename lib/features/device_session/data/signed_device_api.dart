import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/models/get_v1_staff_device_context_response.dart';
import 'package:waflo_staff/core/api/generated/models/post_v1_staff_devices_session_refresh_response.dart';
import 'package:waflo_staff/core/api/generated_m2/models/get_v1_staff_device_context_response.dart'
    as m2;
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/version/mobile_semantic_version.dart';
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
      final parsed = PostV1StaffDevicesSessionRefreshResponse.fromJson(
        _jsonMap(response.data),
      );
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
        sessionMode: current.sessionMode,
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
        final responseBody = _jsonMap(response.data);
        final rawData = _jsonMap(responseBody['data']);
        validateSessionMode(rawData, current);
        if (rawData.containsKey('appVersionSupported')) {
          return parseM2ContextResponse(responseBody, current);
        }
        final parsed = GetV1StaffDeviceContextResponse.fromJson(responseBody);
        final data = parsed.data;
        if (data.device.publicId != current.devicePublicId) {
          throw const ApiFailure('DEVICE_CONTEXT_MISMATCH');
        }
        final role = data.staff.role.json;
        final platform = data.device.platform.json;
        final status = data.device.status.json;
        if (role == null || platform == null || status == null) {
          throw const ApiFailure('INVALID_RESPONSE_BODY');
        }
        if (data.appPolicy.updateRequired) {
          throw const ApiFailure('APP_UPDATE_REQUIRED', httpStatus: 426);
        }
        return AuthoritativeDeviceContext(
          organization: OrganizationContext(
            publicId: data.organization.publicId,
            displayName: data.organization.displayName,
          ),
          staff: StaffContext(
            publicId: data.staff.publicId,
            displayName: data.staff.displayName,
            role: role,
          ),
          device: DeviceContextSummary(
            publicId: data.device.publicId,
            displayName: data.device.displayName,
            status: status,
            platform: platform,
            appVersion: data.device.appVersion,
          ),
          currentLocation: LocationContext(
            publicId: data.currentLocation.publicId,
            displayName: data.currentLocation.displayName,
            earningAllowed: data.currentLocation.earningAllowed,
            redemptionAllowed: data.currentLocation.redemptionAllowed,
          ),
          assignedLocations: data.assignedLocations
              .map(
                (location) => LocationContext(
                  publicId: location.publicId,
                  displayName: location.displayName,
                  earningAllowed: location.earningAllowed,
                  redemptionAllowed: location.redemptionAllowed,
                ),
              )
              .toList(growable: false),
          appPolicy: AppUpdatePolicy(
            minimumSupportedVersion: data.appPolicy.minimumSupportedVersion,
            updateRequired: data.appPolicy.updateRequired,
          ),
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

  static AuthoritativeDeviceContext parseM2ContextResponse(
    Map<String, Object?> responseBody,
    StaffDeviceSession current,
  ) {
    final parsed = m2.GetV1StaffDeviceContextResponse.fromJson(responseBody);
    final data = parsed.data;
    final role = data.role.json;
    final platform = data.platform.json;
    if (role == null ||
        platform == null ||
        data.organizationId != current.organizationId ||
        data.locationId != current.locationId ||
        data.devicePublicId != current.devicePublicId ||
        data.deviceSessionId != current.sessionId ||
        role != current.role ||
        platform != current.devicePlatform ||
        data.requestId != parsed.requestId) {
      throw const ApiFailure('DEVICE_CONTEXT_MISMATCH');
    }
    if (!data.appVersionSupported) {
      throw const ApiFailure('STAFF_APP_VERSION_UNSUPPORTED', httpStatus: 426);
    }
    if (!isStrictMobileSemanticVersion(data.appVersion) ||
        !isStrictMobileSemanticVersion(data.minimumSupportedAppVersion)) {
      throw const ApiFailure('INVALID_RESPONSE_BODY');
    }
    return AuthoritativeDeviceContext(
      organization: OrganizationContext(
        publicId: data.organizationId,
        displayName: '',
      ),
      staff: StaffContext(publicId: '', displayName: '', role: role),
      device: DeviceContextSummary(
        publicId: data.devicePublicId,
        displayName: current.deviceDisplayName,
        status: current.deviceStatus,
        platform: platform,
        appVersion: data.appVersion,
      ),
      currentLocation: LocationContext(
        publicId: data.locationId,
        displayName: '',
        earningAllowed: false,
        redemptionAllowed: false,
        capabilitiesKnown: false,
      ),
      assignedLocations: const [],
      appPolicy: AppUpdatePolicy(
        minimumSupportedVersion: data.minimumSupportedAppVersion,
        updateRequired: false,
      ),
      requestId: parsed.requestId,
      synchronizedAt: DateTime.now().toUtc(),
    );
  }

  static void validateSessionMode(
    Map<String, Object?> data,
    StaffDeviceSession current,
  ) {
    if (current.isReview) {
      throw const LocalSecurityFailure('LEGACY_REVIEW_SESSION_FORBIDDEN');
    }
    final wireMode = data['sessionMode'];
    if (wireMode != null && wireMode != 'NORMAL') {
      throw const ApiFailure('DEVICE_CONTEXT_MISMATCH');
    }
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
    if (session.isReview) {
      throw const LocalSecurityFailure('LEGACY_REVIEW_SESSION_FORBIDDEN');
    }
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
        contentType: body == null ? null : Headers.jsonContentType,
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
