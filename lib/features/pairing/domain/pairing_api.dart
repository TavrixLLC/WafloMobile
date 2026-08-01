import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

enum StaffMobilePlatform { ios, android }

final class SafeDeviceMetadata {
  const SafeDeviceMetadata({
    required this.platform,
    required this.appVersion,
    this.osVersion,
    this.model,
  });

  final StaffMobilePlatform platform;
  final String appVersion;
  final String? osVersion;
  final String? model;
}

abstract interface class DeviceMetadataProvider {
  Future<SafeDeviceMetadata> load();
}

final class PairingClaimCommand {
  const PairingClaimCommand({
    required this.pairingToken,
    required this.installationId,
    required this.publicKey,
    required this.metadata,
  });

  final String pairingToken;
  final String installationId;
  final String publicKey;
  final SafeDeviceMetadata metadata;
}

final class PairingClaimResult {
  const PairingClaimResult({
    required this.pairingPublicId,
    required this.challenge,
    required this.challengeExpiresAt,
    required this.signatureAlgorithm,
    required this.message,
  });

  final String pairingPublicId;
  final String challenge;
  final DateTime challengeExpiresAt;
  final String signatureAlgorithm;
  final String message;
}

final class PairingChallengeResult {
  const PairingChallengeResult({
    required this.pairingPublicId,
    required this.challenge,
    required this.challengeExpiresAt,
    required this.signatureAlgorithm,
    required this.message,
  });

  final String pairingPublicId;
  final String challenge;
  final DateTime challengeExpiresAt;
  final String signatureAlgorithm;
  final String message;
}

final class PairingCompleteCommand {
  const PairingCompleteCommand({
    required this.pairingPublicId,
    required this.challenge,
    required this.signature,
    this.displayName,
  });

  final String pairingPublicId;
  final String challenge;
  final String signature;
  final String? displayName;
}

abstract interface class PairingApi {
  Future<PairingClaimResult> claim(PairingClaimCommand command);
  Future<PairingChallengeResult> challenge(String pairingPublicId);
  Future<StaffDeviceSession> complete(PairingCompleteCommand command);
}
