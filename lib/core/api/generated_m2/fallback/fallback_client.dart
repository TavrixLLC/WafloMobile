// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/get_v1_staff_device_context_response.dart';
import '../models/get_v1_staff_operations_commands_command_id_response.dart';
import '../models/get_v1_staff_operations_operation_public_id_response.dart';
import '../models/membership_resolve_request.dart';
import '../models/post_v1_staff_memberships_resolve_response.dart';
import '../models/post_v1_staff_operations_redeem_response.dart';
import '../models/post_v1_staff_operations_stamps_response.dart';
import '../models/redeem_request.dart';
import '../models/stamp_request.dart';

part 'fallback_client.g.dart';

@RestApi()
abstract class FallbackClient {
  factory FallbackClient(Dio dio, {String? baseUrl}) = _FallbackClient;

  static const Map<String, dynamic> getStaffMobileDeviceContextOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "getStaffMobileDeviceContext",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic>
  resolveMembershipForStaffMobileOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>[],
      'operationId': "resolveMembershipForStaffMobile",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic> issueStaffMobileStampsOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "issueStaffMobileStamps",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> redeemStaffMobileRewardOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "redeemStaffMobileReward",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> getStaffMobileOperationOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "getStaffMobileOperation",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic> recoverStaffMobileCommandOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>[],
          'operationId': "recoverStaffMobileCommand",
          'externalDocsUrl': null,
        },
      };

  @GET('/v1/staff/device-context')
  Future<GetV1StaffDeviceContextResponse> getStaffMobileDeviceContext({
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/memberships/resolve')
  Future<PostV1StaffMembershipsResolveResponse>
  resolveMembershipForStaffMobile({
    @Body() required MembershipResolveRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/operations/stamps')
  Future<PostV1StaffOperationsStampsResponse> issueStaffMobileStamps({
    @Header('x-idempotency-key') required String xIdempotencyKey,
    @Body() required StampRequest body,
    @DioOptions() RequestOptions? options,
  });

  @POST('/v1/staff/operations/redeem')
  Future<PostV1StaffOperationsRedeemResponse> redeemStaffMobileReward({
    @Header('x-idempotency-key') required String xIdempotencyKey,
    @Body() required RedeemRequest body,
    @DioOptions() RequestOptions? options,
  });

  @GET('/v1/staff/operations/{operationPublicId}')
  Future<GetV1StaffOperationsOperationPublicIdResponse>
  getStaffMobileOperation({
    @Path('operationPublicId') required String operationPublicId,
    @DioOptions() RequestOptions? options,
  });

  @GET('/v1/staff/operations/commands/{commandId}')
  Future<GetV1StaffOperationsCommandsCommandIdResponse>
  recoverStaffMobileCommand({
    @Path('commandId') required String commandId,
    @DioOptions() RequestOptions? options,
  });
}
