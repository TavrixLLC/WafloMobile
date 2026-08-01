// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'staff_operations_client.g.dart';

@RestApi()
abstract class StaffOperationsClient {
  factory StaffOperationsClient(Dio dio, {String? baseUrl}) =
      _StaffOperationsClient;

  static const Map<String, dynamic>
  staffOperationsControllerResolveOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffOperations"],
      'operationId': "StaffOperationsController_resolve",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffOperationsControllerIssueOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffOperations"],
      'operationId': "StaffOperationsController_issue",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffOperationsControllerRedeemOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffOperations"],
      'operationId': "StaffOperationsController_redeem",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffOperationsControllerReverseOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffOperations"],
      'operationId': "StaffOperationsController_reverse",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic>
  staffOperationsControllerStatusOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["StaffOperations"],
      'operationId': "StaffOperationsController_status",
      'externalDocsUrl': null,
    },
  };

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
  @POST('/v1/staff/memberships/resolve')
  Future<void> staffOperationsControllerResolve({
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
  @POST('/v1/staff/operations/stamps')
  Future<void> staffOperationsControllerIssue({
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
  @POST('/v1/staff/operations/redeem')
  Future<void> staffOperationsControllerRedeem({
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
  @POST('/v1/staff/operations/reverse')
  Future<void> staffOperationsControllerReverse({
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
  @GET('/v1/staff/operations/{operationPublicId}')
  Future<void> staffOperationsControllerStatus({
    @Path('operationPublicId') required String operationPublicId,
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
