import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_claim_request.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_claim_request_platform.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_complete_request.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_recovery_request.dart';
import 'package:waflo_staff/core/api/generated/staff_device_pairing/staff_device_pairing_client.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';

final class GeneratedPairingApi implements PairingApi {
  const GeneratedPairingApi(this._client, this._errorDecoder);

  final StaffDevicePairingClient _client;
  final ApiErrorDecoder _errorDecoder;

  @override
  Future<PairingClaimResult> claim(PairingClaimCommand command) async {
    try {
      final response = await _client.staffDevicePairingControllerClaim(
        body: DevicePairingClaimRequest(
          pairingToken: command.pairingToken,
          installationId: command.installationId,
          publicKey: command.publicKey,
          platform: switch (command.metadata.platform) {
            StaffMobilePlatform.ios => DevicePairingClaimRequestPlatform.ios,
            StaffMobilePlatform.android =>
              DevicePairingClaimRequestPlatform.android,
          },
          appVersion: command.metadata.appVersion,
          osVersion: command.metadata.osVersion,
          model: command.metadata.model,
        ),
      );
      final data = response.data;
      return PairingClaimResult(
        pairingPublicId: data.pairingPublicId,
        challenge: data.challenge,
        challengeExpiresAt: data.challengeExpiresAt.toUtc(),
        signatureAlgorithm: data.signatureAlgorithm,
        message: data.message,
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }

  @override
  Future<PairingChallengeResult> challenge(String pairingPublicId) async {
    try {
      final response = await _client.staffDevicePairingControllerChallenge(
        body: DevicePairingRecoveryRequest(pairingPublicId: pairingPublicId),
      );
      final data = response.data;
      return PairingChallengeResult(
        pairingPublicId: data.pairingPublicId,
        challenge: data.challenge,
        challengeExpiresAt: data.challengeExpiresAt.toUtc(),
        signatureAlgorithm: data.signatureAlgorithm,
        message: data.message,
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }

  @override
  Future<StaffDeviceSession> complete(PairingCompleteCommand command) async {
    try {
      final response = await _client.staffDevicePairingControllerComplete(
        body: DevicePairingCompleteRequest(
          pairingPublicId: command.pairingPublicId,
          challenge: command.challenge,
          signature: command.signature,
          displayName: command.displayName,
        ),
      );
      final data = response.data;
      final platform = data.device.platform.json;
      final role = data.context.role.json;
      final status = data.device.status;
      if (platform == null || role == null) {
        throw StateError('Unknown required enum in pairing response.');
      }
      return StaffDeviceSession(
        devicePublicId: data.device.publicId,
        deviceDisplayName: data.device.displayName,
        devicePlatform: platform,
        deviceStatus: status,
        sessionId: data.session.id,
        accessToken: data.session.token,
        refreshToken: data.session.refreshToken,
        accessExpiresAt: data.session.expiresAt.toUtc(),
        organizationId: data.context.organizationId,
        role: role,
        locationId: data.context.locationId,
        issuedAt: DateTime.now().toUtc(),
      );
    } on Object catch (error) {
      throw _errorDecoder.decode(error);
    }
  }
}
