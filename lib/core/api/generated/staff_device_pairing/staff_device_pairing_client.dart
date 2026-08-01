// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/device_pairing_claim_request.dart';
import '../models/device_pairing_complete_request.dart';
import '../models/device_pairing_recovery_request.dart';
import '../models/get_v1_staff_device_context_response.dart';
import '../models/post_v1_staff_devices_pairing_challenge_response.dart';
import '../models/post_v1_staff_devices_pairing_claim_response.dart';
import '../models/post_v1_staff_devices_pairing_complete_response.dart';
import '../models/post_v1_staff_devices_session_refresh_response.dart';
import '../models/staff_device_session_refresh_request.dart';

part 'staff_device_pairing_client.g.dart';

@RestApi()
abstract class StaffDevicePairingClient {
  factory StaffDevicePairingClient(Dio dio, {String? baseUrl}) =
      _StaffDevicePairingClient;

  static const Map<String, dynamic>
  staffDevicePairingControllerClaimOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_claim",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffDevicePairingControllerChallengeOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_challenge",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffDevicePairingControllerCompleteOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_complete",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffDevicePairingControllerRefreshOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_refresh",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffDevicePairingControllerLogoutOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_logout",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffDevicePairingControllerContextOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffDevicePairing"],
      'operationId': "StaffDevicePairingController_context",
      'externalDocsUrl': null,
    },
  };

  @POST('/v1/staff/devices/pairing/claim')
  Future<PostV1StaffDevicesPairingClaimResponse>
  staffDevicePairingControllerClaim({
    @Body() required DevicePairingClaimRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/pairing/challenge')
  Future<PostV1StaffDevicesPairingChallengeResponse>
  staffDevicePairingControllerChallenge({
    @Body() required DevicePairingRecoveryRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/pairing/complete')
  Future<PostV1StaffDevicesPairingCompleteResponse>
  staffDevicePairingControllerComplete({
    @Body() required DevicePairingCompleteRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/session/refresh')
  Future<PostV1StaffDevicesSessionRefreshResponse>
  staffDevicePairingControllerRefresh({
    @Body() required StaffDeviceSessionRefreshRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// [authorization] - Device session bearer token.
  ///
  /// [xWafloDeviceId] - Paired device public ID.
  ///
  /// [xWafloDeviceSessionId] - Device session ID.
  ///
  /// [xWafloRequestId] - Unique request ID.
  ///
  /// [xWafloTimestamp] - ISO-8601 request time.
  ///
  /// [xWafloNonce] - Fresh request nonce.
  ///
  /// [xWafloBodySha256] - Lowercase hexadecimal SHA-256 body digest.
  ///
  /// [xWafloSignature] - Base64url Ed25519 signature.
  @POST('/v1/staff/devices/session/logout')
  Future<void> staffDevicePairingControllerLogout({
    @Header('authorization') required String authorization,
    @Header('x-waflo-device-id') required String xWafloDeviceId,
    @Header('x-waflo-device-session-id') required String xWafloDeviceSessionId,
    @Header('x-waflo-request-id') required String xWafloRequestId,
    @Header('x-waflo-timestamp') required String xWafloTimestamp,
    @Header('x-waflo-nonce') required String xWafloNonce,
    @Header('x-waflo-body-sha256') required String xWafloBodySha256,
    @Header('x-waflo-signature') required String xWafloSignature,
    @DioOptions() RequestOptions? options,
  });

  /// [authorization] - Device session bearer token.
  ///
  /// [xWafloDeviceId] - Paired device public ID.
  ///
  /// [xWafloDeviceSessionId] - Device session ID.
  ///
  /// [xWafloRequestId] - Unique request ID.
  ///
  /// [xWafloTimestamp] - ISO-8601 request time.
  ///
  /// [xWafloNonce] - Fresh request nonce.
  ///
  /// [xWafloBodySha256] - Lowercase hexadecimal SHA-256 body digest.
  ///
  /// [xWafloSignature] - Base64url Ed25519 signature.
  @GET('/v1/staff/device-context')
  Future<GetV1StaffDeviceContextResponse> staffDevicePairingControllerContext({
    @Header('authorization') required String authorization,
    @Header('x-waflo-device-id') required String xWafloDeviceId,
    @Header('x-waflo-device-session-id') required String xWafloDeviceSessionId,
    @Header('x-waflo-request-id') required String xWafloRequestId,
    @Header('x-waflo-timestamp') required String xWafloTimestamp,
    @Header('x-waflo-nonce') required String xWafloNonce,
    @Header('x-waflo-body-sha256') required String xWafloBodySha256,
    @Header('x-waflo-signature') required String xWafloSignature,
    @DioOptions() RequestOptions? options,
  });
}
