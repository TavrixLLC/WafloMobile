import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/local_secure_state.dart';
import 'package:waflo_staff/features/device_session/domain/session_manager.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_api.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

enum PairingProgress {
  validating,
  creatingIdentity,
  claiming,
  recoveringChallenge,
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
    this._lifecycleRepository,
    this._sessionManager, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final PairingQrParser _parser;
  final DeviceIdentityRepository _identityRepository;
  final PairingApi _pairingApi;
  final DeviceMetadataProvider _metadataProvider;
  final StaffDeviceSessionRepository _sessionRepository;
  final PairingTransactionRepository _transactionRepository;
  final LocalLifecycleRepository _lifecycleRepository;
  final SessionManager _sessionManager;
  final DateTime Function() _now;

  Future<PairingFlowResult> pair(
    String rawQr, {
    required void Function(PairingProgress progress) onProgress,
  }) async {
    onProgress(PairingProgress.validating);
    final payload = _parser.parse(rawQr);
    await _lifecycleRepository.mark(LocalLifecycleState.pairing);
    await _transactionRepository.mark(
      pairingPublicId: payload.pairingPublicId,
      stage: PairingTransactionStage.claimPending,
    );

    onProgress(PairingProgress.creatingIdentity);
    final identity = await _identityRepository.loadOrCreate();
    final metadata = await _metadataProvider.load();

    onProgress(PairingProgress.claiming);
    try {
      final claim = await _pairingApi.claim(
        PairingClaimCommand(
          pairingToken: payload.rawToken,
          installationId: identity.installationId,
          publicKey: identity.publicKey,
          metadata: metadata,
        ),
      );
      _validateChallenge(
        expectedPairingPublicId: payload.pairingPublicId,
        identity: identity,
        pairingPublicId: claim.pairingPublicId,
        challenge: claim.challenge,
        challengeExpiresAt: claim.challengeExpiresAt,
        signatureAlgorithm: claim.signatureAlgorithm,
        message: claim.message,
      );
      return _completeClaim(
        identity: identity,
        pairingPublicId: claim.pairingPublicId,
        challenge: claim.challenge,
        challengeExpiresAt: claim.challengeExpiresAt,
        message: claim.message,
        onProgress: onProgress,
      );
    } on AppFailure catch (failure) {
      if (failure is NetworkFailure ||
          failure.safeCode == 'DEVICE_PAIRING_ALREADY_USED') {
        return _recoverClaim(
          transaction: (await _transactionRepository.read())!,
          identity: identity,
          onProgress: onProgress,
        );
      }
      if (failure.safeCode == 'DEVICE_PAIRING_EXPIRED') {
        await _clearExpiredPairing(failure);
      }
      rethrow;
    }
  }

  Future<PairingFlowResult> resume({
    required void Function(PairingProgress progress) onProgress,
  }) async {
    final transaction = await _transactionRepository.read();
    if (transaction == null || !transaction.isRecoverable) {
      throw const LocalSecurityFailure('PAIRING_RECOVERY_UNAVAILABLE');
    }
    final identity = await _identityRepository.load();
    if (identity == null) {
      throw const LocalSecurityFailure('LOCAL_KEY_MISSING');
    }
    await _lifecycleRepository.mark(LocalLifecycleState.pairing);
    return _recoverClaim(
      transaction: transaction,
      identity: identity,
      onProgress: onProgress,
    );
  }

  Future<PairingFlowResult> _recoverClaim({
    required PairingTransaction transaction,
    required DeviceIdentity identity,
    required void Function(PairingProgress progress) onProgress,
  }) async {
    onProgress(PairingProgress.recoveringChallenge);
    try {
      final recovered = await _pairingApi.challenge(
        transaction.pairingPublicId,
      );
      _validateChallenge(
        expectedPairingPublicId: transaction.pairingPublicId,
        identity: identity,
        pairingPublicId: recovered.pairingPublicId,
        challenge: recovered.challenge,
        challengeExpiresAt: recovered.challengeExpiresAt,
        signatureAlgorithm: recovered.signatureAlgorithm,
        message: recovered.message,
      );
      return _completeClaim(
        identity: identity,
        pairingPublicId: recovered.pairingPublicId,
        challenge: recovered.challenge,
        challengeExpiresAt: recovered.challengeExpiresAt,
        message: recovered.message,
        onProgress: onProgress,
        priorTransaction: transaction,
      );
    } on AppFailure catch (failure) {
      if (failure.safeCode == 'DEVICE_PAIRING_EXPIRED') {
        await _clearExpiredPairing(failure);
      }
      rethrow;
    }
  }

  Future<PairingFlowResult> _completeClaim({
    required DeviceIdentity identity,
    required String pairingPublicId,
    required String challenge,
    required DateTime challengeExpiresAt,
    required String message,
    required void Function(PairingProgress progress) onProgress,
    PairingTransaction? priorTransaction,
  }) async {
    await _transactionRepository.mark(
      pairingPublicId: pairingPublicId,
      stage: PairingTransactionStage.claimed,
      challenge: challenge,
      challengeExpiresAt: challengeExpiresAt,
      message: message,
    );

    onProgress(PairingProgress.signing);
    final reusableSignature =
        priorTransaction?.stage == PairingTransactionStage.signing &&
            priorTransaction?.challenge == challenge
        ? priorTransaction?.signature
        : null;
    final signature =
        reusableSignature ?? await _identityRepository.signUtf8(message);
    await _transactionRepository.mark(
      pairingPublicId: pairingPublicId,
      stage: PairingTransactionStage.signing,
      challenge: challenge,
      challengeExpiresAt: challengeExpiresAt,
      message: message,
      signature: signature,
    );

    await _transactionRepository.mark(
      pairingPublicId: pairingPublicId,
      stage: PairingTransactionStage.completing,
    );
    onProgress(PairingProgress.completing);
    final session = await _pairingApi.complete(
      PairingCompleteCommand(
        pairingPublicId: pairingPublicId,
        challenge: challenge,
        signature: signature,
        displayName: 'Waflo Staff device',
      ),
    );

    await _transactionRepository.mark(
      pairingPublicId: pairingPublicId,
      stage: PairingTransactionStage.persisting,
    );
    onProgress(PairingProgress.saving);
    try {
      await _sessionRepository.replaceAtomically(session);
      await _lifecycleRepository.mark(LocalLifecycleState.paired);
    } on Object {
      await _sessionRepository.clear();
      await _lifecycleRepository.mark(
        LocalLifecycleState.recoveryRequired,
        reason: 'PAIRING_COMPLETED_PERSISTENCE_AMBIGUOUS',
      );
      rethrow;
    }
    await _transactionRepository.clear();

    onProgress(PairingProgress.loadingContext);
    final context = await _sessionManager.loadContext(refreshIfExpired: false);
    return PairingFlowResult(context: context);
  }

  void _validateChallenge({
    required String expectedPairingPublicId,
    required DeviceIdentity identity,
    required String pairingPublicId,
    required String challenge,
    required DateTime challengeExpiresAt,
    required String signatureAlgorithm,
    required String message,
  }) {
    final expectedMessage = [
      'waflo-pair-challenge-v1',
      pairingPublicId,
      challenge,
      identity.installationId,
    ].join('\n');
    if (!challengeExpiresAt.isAfter(_now().toUtc())) {
      throw const ApiFailure('DEVICE_PAIRING_EXPIRED', httpStatus: 410);
    }
    if (pairingPublicId != expectedPairingPublicId ||
        signatureAlgorithm != 'Ed25519' ||
        challenge.length < 32 ||
        challenge.length > 256 ||
        message != expectedMessage) {
      throw const ApiFailure('DEVICE_PAIRING_INVALID', httpStatus: 422);
    }
  }

  Future<void> _clearExpiredPairing(AppFailure failure) async {
    await _transactionRepository.clear();
    await _identityRepository.delete();
    await _lifecycleRepository.mark(
      LocalLifecycleState.neverPaired,
      reason: failure.safeCode,
      requestId: failure.requestId,
    );
  }
}
