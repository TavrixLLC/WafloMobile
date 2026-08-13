import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';

enum PairingViewStage {
  welcome,
  cameraRationale,
  scanner,
  manualEntry,
  reviewAccess,
  progress,
  success,
  error,
}

final class PairingViewState {
  const PairingViewState({
    required this.stage,
    this.progress,
    this.problem,
    this.failure,
    this.context,
    this.reviewFlow = false,
  });

  const PairingViewState.welcome() : this(stage: PairingViewStage.welcome);

  final PairingViewStage stage;
  final PairingProgress? progress;
  final PairingQrProblem? problem;
  final AppFailure? failure;
  final AuthoritativeDeviceContext? context;
  final bool reviewFlow;
}

final class PairingController extends Notifier<PairingViewState> {
  Future<void>? _pairingOperation;

  @override
  PairingViewState build() => const PairingViewState.welcome();

  void showCameraRationale() {
    if (_pairingOperation == null) {
      state = const PairingViewState(stage: PairingViewStage.cameraRationale);
    }
  }

  void showScanner() {
    if (_pairingOperation == null) {
      state = const PairingViewState(stage: PairingViewStage.scanner);
    }
  }

  void showManualEntry() {
    if (_pairingOperation == null) {
      state = const PairingViewState(stage: PairingViewStage.manualEntry);
    }
  }

  void showReviewAccess() {
    if (_pairingOperation == null) {
      state = const PairingViewState(stage: PairingViewStage.reviewAccess);
    }
  }

  void reset() {
    if (_pairingOperation == null) {
      state = const PairingViewState.welcome();
    }
  }

  void showExternalFailure(AppFailure failure) {
    if (_pairingOperation == null) {
      state = PairingViewState(stage: PairingViewStage.error, failure: failure);
    }
  }

  Future<void> submit(String rawQr) {
    final running = _pairingOperation;
    if (running != null) {
      return running;
    }
    final operation = _submit(rawQr);
    _pairingOperation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_pairingOperation, operation)) {
          _pairingOperation = null;
        }
      }),
    );
    return operation;
  }

  Future<void> submitReviewAccess(String code) {
    final running = _pairingOperation;
    if (running != null) return running;
    final operation = _submitReviewAccess(code);
    _pairingOperation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_pairingOperation, operation)) {
          _pairingOperation = null;
        }
      }),
    );
    return operation;
  }

  Future<void> _submitReviewAccess(String code) async {
    try {
      final result = await ref
          .read(pairingFlowServiceProvider)
          .enterReviewAccess(
            code,
            onProgress: (progress) {
              state = PairingViewState(
                stage: PairingViewStage.progress,
                progress: progress,
                reviewFlow: true,
              );
            },
          );
      state = PairingViewState(
        stage: PairingViewStage.success,
        context: result.context,
        reviewFlow: true,
      );
    } on AppFailure catch (failure) {
      state = PairingViewState(
        stage: PairingViewStage.error,
        failure: failure,
        reviewFlow: true,
      );
    } on Object {
      state = const PairingViewState(
        stage: PairingViewStage.error,
        failure: ApiFailure('INTERNAL_ERROR', responseReceived: false),
        reviewFlow: true,
      );
    }
  }

  Future<void> _submit(String rawQr) async {
    try {
      final result = await ref
          .read(pairingFlowServiceProvider)
          .pair(
            rawQr,
            onProgress: (progress) {
              state = PairingViewState(
                stage: PairingViewStage.progress,
                progress: progress,
              );
            },
          );
      state = PairingViewState(
        stage: PairingViewStage.success,
        context: result.context,
      );
    } on PairingQrException catch (error) {
      state = PairingViewState(
        stage: PairingViewStage.error,
        problem: error.problem,
      );
    } on AppFailure catch (failure) {
      state = PairingViewState(stage: PairingViewStage.error, failure: failure);
    } on Object {
      state = const PairingViewState(
        stage: PairingViewStage.error,
        failure: ApiFailure('INTERNAL_ERROR', responseReceived: false),
      );
    }
  }

  Future<void> continueAfterSuccess() async {
    await ref.read(bootControllerProvider.notifier).initialize();
    reset();
  }
}
