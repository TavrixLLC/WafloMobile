import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_mode.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';

abstract interface class CustomerScannerAdapter {
  ScannerMode get mode;
  ValueListenable<CustomerScannerState> get state;
  ValueListenable<bool> get torchEnabled;

  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  });

  Future<void> start();
  Future<void> stop();
  Future<void> background();
  Future<void> foreground();
  void reportResolveFailure(CustomerScannerState failure);
  Future<void> resetForExplicitRetry();
  Future<void> toggleTorch();
  Future<void> dispose();
}

final class MobileCustomerScannerAdapter implements CustomerScannerAdapter {
  MobileCustomerScannerAdapter()
    : _controller = MobileScannerController(
        autoStart: false,
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );

  static const maximumCandidateLength = 220;
  final MobileScannerController _controller;
  final CustomerScannerStateMachine _machine = CustomerScannerStateMachine();
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.idle,
  );
  final ValueNotifier<bool> _torchEnabled = ValueNotifier(false);
  bool _handled = false;
  bool _disposed = false;
  Future<void>? _starting;

  @override
  ScannerMode get mode => ScannerMode.customerMembershipQr;

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torchEnabled;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => MobileScanner(
    key: const Key('customer-membership-scanner'),
    controller: _controller,
    onDetect: (capture) {
      _machine.scanning();
      _publish();
      if (_handled || _disposed) return;
      final candidate = capture.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .firstOrNull;
      if (candidate == null || !_machine.capture(DateTime.now())) return;
      _handled = true;
      _publish();
      unawaited(
        stop().then((_) {
          _machine.resolving();
          _publish();
          final bounded = candidate.length > maximumCandidateLength
              ? candidate.substring(0, maximumCandidateLength + 1)
              : candidate;
          return onDetected(bounded);
        }),
      );
    },
    placeholderBuilder: (context) => const ColoredBox(color: Colors.black),
    errorBuilder: (context, error) => const ColoredBox(color: Colors.black),
  );

  @override
  Future<void> start() {
    final running = _starting;
    if (running != null) return running;
    final operation = _start();
    _starting = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_starting, operation)) _starting = null;
      }),
    );
    return operation;
  }

  Future<void> _start() async {
    if (_disposed || _handled) return;
    _machine.initializeCamera();
    _publish();
    _machine.requestPermission();
    _publish();
    try {
      await _controller.start();
      _machine.ready();
      _publish();
    } on MobileScannerException catch (error) {
      if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
        final permission = await Permission.camera.status;
        if (permission.isPermanentlyDenied) {
          _machine.permissionPermanentlyDenied();
        } else {
          _machine.permissionDenied();
        }
      } else if (error.errorCode == MobileScannerErrorCode.unsupported) {
        _machine.fail(CustomerScannerState.cameraUnavailable);
      } else {
        _machine.fail(CustomerScannerState.cameraUnavailable);
      }
      _publish();
    }
  }

  @override
  Future<void> stop() async {
    if (!_disposed) await _controller.stop();
  }

  @override
  Future<void> background() async {
    _machine.background();
    _publish();
    await stop();
  }

  @override
  Future<void> foreground() async {
    if (_disposed || _handled) return;
    _machine.reset();
    _publish();
    await start();
  }

  @override
  void reportResolveFailure(CustomerScannerState failure) {
    if (_disposed) return;
    _machine.fail(failure);
    _publish();
  }

  @override
  Future<void> resetForExplicitRetry() async {
    _handled = false;
    _machine.reset();
    _publish();
    await start();
  }

  @override
  Future<void> toggleTorch() async {
    if (_disposed) return;
    await _controller.toggleTorch();
    _torchEnabled.value = _controller.value.torchState == TorchState.on;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _machine.background();
    _publish();
    await _controller.dispose();
    _state.dispose();
    _torchEnabled.dispose();
  }

  void _publish() {
    if (!_disposed) _state.value = _machine.state;
  }
}

final class FixtureCustomerScannerAdapter implements CustomerScannerAdapter {
  FixtureCustomerScannerAdapter(
    this.candidate, {
    this.autoDeliver = true,
    CustomerScannerState initialState = CustomerScannerState.idle,
    bool initialTorchEnabled = false,
  }) : _state = ValueNotifier(initialState),
       _torchEnabled = ValueNotifier(initialTorchEnabled);

  final String candidate;
  final bool autoDeliver;
  final ValueNotifier<CustomerScannerState> _state;
  final ValueNotifier<bool> _torchEnabled;
  bool started = false;
  bool delivered = false;

  @override
  ScannerMode get mode => ScannerMode.customerMembershipQr;

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torchEnabled;

  void showState(CustomerScannerState value) => _state.value = value;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) {
    if (autoDeliver && started && !delivered) {
      delivered = true;
      _state.value = CustomerScannerState.candidateCaptured;
      scheduleMicrotask(() => onDetected(candidate));
    }
    return const ColoredBox(
      key: Key('fixture-customer-scanner'),
      color: Color(0xFF111714),
    );
  }

  @override
  Future<void> start() async {
    started = true;
    if (_state.value == CustomerScannerState.idle) {
      _state.value = CustomerScannerState.ready;
    }
  }

  @override
  Future<void> stop() async => started = false;

  @override
  Future<void> background() async {
    started = false;
    _state.value = CustomerScannerState.backgrounded;
  }

  @override
  Future<void> foreground() async {
    if (delivered) return;
    await start();
  }

  @override
  void reportResolveFailure(CustomerScannerState failure) {
    _state.value = failure;
  }

  @override
  Future<void> resetForExplicitRetry() async {
    delivered = false;
    started = true;
    _state.value = CustomerScannerState.ready;
  }

  @override
  Future<void> toggleTorch() async {
    _torchEnabled.value = !_torchEnabled.value;
  }

  @override
  Future<void> dispose() async {
    started = false;
    _state.dispose();
    _torchEnabled.dispose();
  }
}
