// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/pairing_challenge_request.dart';
import '../models/pairing_challenge_success.dart';
import '../models/pairing_claim_request.dart';
import '../models/pairing_claim_success.dart';
import '../models/pairing_complete_request.dart';
import '../models/pairing_complete_success.dart';

part 'pairing_client.g.dart';

@RestApi()
abstract class PairingClient {
  factory PairingClient(Dio dio, {String? baseUrl}) = _PairingClient;

  static const Map<String, dynamic> claimStaffDevicePairingOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>["Pairing"],
          'operationId': "claimStaffDevicePairing",
          'externalDocsUrl': null,
        },
      };
  static const Map<String, dynamic>
  getStaffDevicePairingChallengeOpenapiExtras = <String, dynamic>{
    'openapi': <String, dynamic>{
      'tags': <String>["Pairing"],
      'operationId': "getStaffDevicePairingChallenge",
      'externalDocsUrl': null,
    },
  };
  static const Map<String, dynamic> completeStaffDevicePairingOpenapiExtras =
      <String, dynamic>{
        'openapi': <String, dynamic>{
          'tags': <String>["Pairing"],
          'operationId': "completeStaffDevicePairing",
          'externalDocsUrl': null,
        },
      };

  /// Claim a one-time pairing QR
  @POST('/v1/staff/devices/pairing/claim')
  Future<PairingClaimSuccess> claimStaffDevicePairing({
    @Body() required PairingClaimRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// Recover an unexpired claimed challenge
  @POST('/v1/staff/devices/pairing/challenge')
  Future<PairingChallengeSuccess> getStaffDevicePairingChallenge({
    @Body() required PairingChallengeRequest body,
    @DioOptions() RequestOptions? options,
  });

  /// Verify the Ed25519 challenge signature and create the device session
  @POST('/v1/staff/devices/pairing/complete')
  Future<PairingCompleteSuccess> completeStaffDevicePairing({
    @Body() required PairingCompleteRequest body,
    @DioOptions() RequestOptions? options,
  });
}
