// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/device_pairing_challenge_request.dart';
import '../models/device_pairing_claim_request.dart';
import '../models/device_pairing_complete_request.dart';
import '../models/get_v1_staff_device_context_response.dart';
import '../models/get_v1_staff_operations_commands_command_id_response.dart';
import '../models/get_v1_staff_operations_operation_public_id_response.dart';
import '../models/membership_resolve_request.dart';
import '../models/post_v1_staff_devices_pairing_challenge_response.dart';
import '../models/post_v1_staff_devices_pairing_claim_response.dart';
import '../models/post_v1_staff_devices_pairing_complete_response.dart';
import '../models/post_v1_staff_devices_session_logout_response.dart';
import '../models/post_v1_staff_devices_session_refresh_response.dart';
import '../models/post_v1_staff_memberships_resolve_response.dart';
import '../models/post_v1_staff_operations_redeem_response.dart';
import '../models/post_v1_staff_operations_stamps_response.dart';
import '../models/redemption_request.dart';
import '../models/staff_device_session_refresh_request.dart';
import '../models/stamp_request.dart';

part 'fallback_client.g.dart';

@RestApi()
abstract class FallbackClient {
  factory FallbackClient(Dio dio, {String? baseUrl}) = _FallbackClient;

  static const Map<String, dynamic> staffDevicePairingClaimOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDevicePairingClaim",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> staffDevicePairingChallengeOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDevicePairingChallenge",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> staffDevicePairingCompleteOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDevicePairingComplete",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> staffDeviceSessionRefreshOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDeviceSessionRefresh",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> staffDeviceSessionLogoutOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDeviceSessionLogout",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> staffDeviceContextOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "staffDeviceContext",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> resolveMembershipM2OpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "resolveMembershipM2",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> issueStampsM2OpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "issueStampsM2",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> redeemRewardM2OpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "redeemRewardM2",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> operationStatusByPublicIdM2OpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "operationStatusByPublicIdM2",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> operationStatusByCommandIdM2OpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "operationStatusByCommandIdM2",
          'externalDocsUrl': null,
        },
      };

  @POST('/v1/staff/devices/pairing/claim')
  Future<PostV1StaffDevicesPairingClaimResponse> staffDevicePairingClaim({
    @Body() required DevicePairingClaimRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/pairing/challenge')
  Future<PostV1StaffDevicesPairingChallengeResponse>
  staffDevicePairingChallenge({
    @Body() required DevicePairingChallengeRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/pairing/complete')
  Future<PostV1StaffDevicesPairingCompleteResponse> staffDevicePairingComplete({
    @Body() required DevicePairingCompleteRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/session/refresh')
  Future<PostV1StaffDevicesSessionRefreshResponse> staffDeviceSessionRefresh({
    @Body() required StaffDeviceSessionRefreshRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/devices/session/logout')
  Future<PostV1StaffDevicesSessionLogoutResponse> staffDeviceSessionLogout({
    @DioOptions() RequestOptions? options,
  });

  @GET('/v1/staff/device-context')
  Future<GetV1StaffDeviceContextResponse> staffDeviceContext({
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/memberships/resolve')
  Future<PostV1StaffMembershipsResolveResponse> resolveMembershipM2({
    @Body() required MembershipResolveRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// [xIdempotencyKey] - Stable command UUID. Retain it for ambiguous-result recovery.
  @POST('/v1/staff/operations/stamps')
  Future<PostV1StaffOperationsStampsResponse> issueStampsM2({
    @Header('x-idempotency-key') required String xIdempotencyKey,
    @Body() required StampRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// [xIdempotencyKey] - Stable command UUID. Retain it for ambiguous-result recovery.
  @POST('/v1/staff/operations/redeem')
  Future<PostV1StaffOperationsRedeemResponse> redeemRewardM2({
    @Header('x-idempotency-key') required String xIdempotencyKey,
    @Body() required RedemptionRequest body,
    @DioOptions() RequestOptions? options,
  });

  @GET('/v1/staff/operations/{operationPublicId}')
  Future<GetV1StaffOperationsOperationPublicIdResponse>
  operationStatusByPublicIdM2({
    @Path('operationPublicId') required String operationPublicId,
    @DioOptions() RequestOptions? options,
  });

  @GET('/v1/staff/operations/commands/{commandId}')
  Future<GetV1StaffOperationsCommandsCommandIdResponse>
  operationStatusByCommandIdM2({
    @Path('commandId') required String commandId,
    @DioOptions() RequestOptions? options,
  });
}
