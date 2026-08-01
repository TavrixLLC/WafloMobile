// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/device_context_success.dart';
import '../models/iso_date_time.dart';
import '../models/session_refresh_request.dart';
import '../models/session_refresh_success.dart';
import '../models/uuid.dart';

part 'device_session_client.g.dart';

@RestApi()
abstract class DeviceSessionClient {
  factory DeviceSessionClient(Dio dio, {String? baseUrl}) =
      _DeviceSessionClient;

  static const Map<String, dynamic> refreshStaffDeviceSessionOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>["Device session"],
          'operationId': "refreshStaffDeviceSession",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> logoutStaffDeviceSessionOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>["Device session"],
          'operationId': "logoutStaffDeviceSession",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> getStaffDeviceContextOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>["Device session"],
          'operationId': "getStaffDeviceContext",
          'externalDocsUrl': null,
        },
      };

  /// Rotate the current signed device session.
  ///
  /// Sign with the current session. A success revokes it and returns a new session ID, access token, and refresh token.
  ///
  /// [xWafloBodySha256] - Lowercase SHA-256 hex of the exact transmitted body bytes; hash zero bytes when no body is present.
  ///
  /// [xWafloSignature] - Unpadded base64url Ed25519 signature over the canonical nine-line envelope.
  @POST('/v1/staff/devices/session/refresh')
  Future<SessionRefreshSuccess> refreshStaffDeviceSession({
    @Header('X-Waflo-Device-Id') required Uuid xWafloDeviceId,
    @Header('X-Waflo-Device-Session-Id') required Uuid xWafloDeviceSessionId,
    @Header('X-Waflo-Request-Id') required String xWafloRequestId,
    @Header('X-Waflo-Timestamp') required IsoDateTime xWafloTimestamp,
    @Header('X-Waflo-Nonce') required String xWafloNonce,
    @Header('X-Waflo-Body-Sha256') required String xWafloBodySha256,
    @Header('X-Waflo-Signature') required String xWafloSignature,
    @Body() required SessionRefreshRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// Revoke the current signed device session.
  ///
  /// [xWafloBodySha256] - Lowercase SHA-256 hex of the exact transmitted body bytes; hash zero bytes when no body is present.
  ///
  /// [xWafloSignature] - Unpadded base64url Ed25519 signature over the canonical nine-line envelope.
  @POST('/v1/staff/devices/session/logout')
  Future<void> logoutStaffDeviceSession({
    @Header('X-Waflo-Device-Id') required Uuid xWafloDeviceId,
    @Header('X-Waflo-Device-Session-Id') required Uuid xWafloDeviceSessionId,
    @Header('X-Waflo-Request-Id') required String xWafloRequestId,
    @Header('X-Waflo-Timestamp') required IsoDateTime xWafloTimestamp,
    @Header('X-Waflo-Nonce') required String xWafloNonce,
    @Header('X-Waflo-Body-Sha256') required String xWafloBodySha256,
    @Header('X-Waflo-Signature') required String xWafloSignature,
    @DioOptions() RequestOptions? options,
  });

  /// Return the verified Staff device context.
  ///
  /// [xWafloBodySha256] - Lowercase SHA-256 hex of the exact transmitted body bytes; hash zero bytes when no body is present.
  ///
  /// [xWafloSignature] - Unpadded base64url Ed25519 signature over the canonical nine-line envelope.
  @GET('/v1/staff/device-context')
  Future<DeviceContextSuccess> getStaffDeviceContext({
    @Header('X-Waflo-Device-Id') required Uuid xWafloDeviceId,
    @Header('X-Waflo-Device-Session-Id') required Uuid xWafloDeviceSessionId,
    @Header('X-Waflo-Request-Id') required String xWafloRequestId,
    @Header('X-Waflo-Timestamp') required IsoDateTime xWafloTimestamp,
    @Header('X-Waflo-Nonce') required String xWafloNonce,
    @Header('X-Waflo-Body-Sha256') required String xWafloBodySha256,
    @Header('X-Waflo-Signature') required String xWafloSignature,
    @DioOptions() RequestOptions? options,
  });
}
