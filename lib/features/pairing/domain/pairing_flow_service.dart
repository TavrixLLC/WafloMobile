import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

enum PairingProgress {
  validating,
  creatingIdentity,
  claiming,
  signing,
  completing,
  saving,
  loadingContext,
}

final class PairingFlowResult {
  const PairingFlowResult({required this.context});

  final AuthoritativeDeviceContext context;
}

final class PairingFlowService {
  PairingFlowService(
    this._parser,
    this._identityRepository,
    this._pairingApi,
    this._metadataProvider,
    this._sessionRepository,
    this._transactionRepository,
    this._sessionManager, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PairingQrParser _parser;
  final DeviceIdentityRepository _identityRepository;
  final PairingApi _pairingApi;
  final DeviceMetadataProvider _metadataProvider;
  final StaffDeviceSessionRepository _sessionRepository;
  final PairingTransactionRepository _transactionRepository;
  final SessionManager _sessionManager;
  final DateTime Function() _now;

  Future<PairingFlowResult> pair(
    String rawQr, {
    required void Function(PairingProgress progress) onProgress,
  }) async {
    onProgress(PairingProgress.validating);
    final payload = _parser.parse(rawQr);
    await _transactionRepository.mark(
      pairingPublicId: payload.pairingPublicId,
      stage: PairingTransactionStage.claim,
    );

    onProgress(PairingProgress.creatingIdentity);
    final identity = await _identityRepository.loadOrCreate();
    final metadata = await _metadataProvider.load();

    onProgress(PairingProgress.claiming);
    final claim = await _pairingApi.claim(
      PairingClaimCommand(
        pairingToken: payload.rawToken,
        installationId: identity.installationId,
        publicKey: identity.publicKey,
        metadata: metadata,
      ),
    );
    _validateClaim(payload, identity, claim);

    await _transactionRepository.mark(
      pairingPublicId: payload.pairingPublicId,
      stage: PairingTransactionStage.signing,
    );
    onProgress(PairingProgress.signing);
    final signature = await _identityRepository.signUtf8(claim.message);

    await _transactionRepository.mark(
      pairingPublicId: payload.pairingPublicId,
      stage: PairingTransactionStage.completing,
    );
    onProgress(PairingProgress.completing);
    final session = await _pairingApi.complete(
      PairingCompleteCommand(
        pairingPublicId: claim.pairingPublicId,
        challenge: claim.challenge,
        signature: signature,
        displayName: 'Waflo Staff device',
      ),
    );

    await _transactionRepository.mark(
      pairingPublicId: payload.pairingPublicId,
      stage: PairingTransactionStage.persisting,
    );
    onProgress(PairingProgress.saving);
    await _sessionRepository.replaceAtomically(session);
    await _transactionRepository.clear();

    onProgress(PairingProgress.loadingContext);
    final context = await _sessionManager.loadContext(refreshIfExpired: false);
    return PairingFlowResult(context: context);
  }

  void _validateClaim(
    PairingQrPayload payload,
    DeviceIdentity identity,
    PairingClaimResult claim,
  ) {
    final expectedMessage = [
      'waflo-pair-challenge-v1',
      claim.pairingPublicId,
      claim.challenge,
      identity.installationId,
    ].join('\n');
    if (claim.pairingPublicId != payload.pairingPublicId ||
        claim.signatureAlgorithm != 'Ed25519' ||
        claim.challenge.length < 32 ||
        claim.challenge.length > 256 ||
        !claim.challengeExpiresAt.isAfter(_now().toUtc()) ||
        claim.message != expectedMessage) {
      throw const ApiFailure('DEVICE_PAIRING_INVALID', httpStatus: 422);
    }
  }
}
