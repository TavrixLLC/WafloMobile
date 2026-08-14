import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';

abstract interface class PairingScannerAdapter {
  ValueListenable<CustomerScannerState> get state;
  ValueListenable<bool> get torchEnabled;

  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  });

  Future<void> start();
  Future<void> stop();
  Future<void> toggleTorch();
  Future<void> dispose();
}

final class MobilePairingScannerAdapter implements PairingScannerAdapter {
  MobilePairingScannerAdapter()
    : _controller = MobileScannerController(
        autoStart: false,
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );

  final MobileScannerController _controller;
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.idle,
  );
  final ValueNotifier<bool> _torchEnabled = ValueNotifier(false);
  bool _handled = false;
  bool _disposed = false;

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torchEnabled;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => MobileScanner(
    key: const Key('pairing-scanner'),
    controller: _controller,
    onDetect: (capture) {
      final candidate = capture.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .firstOrNull;
      if (candidate != null) {
        if (_handled || _disposed) return;
        _handled = true;
        _state.value = CustomerScannerState.candidateCaptured;
        unawaited(onDetected(candidate));
      }
    },
    placeholderBuilder: (context) => const ColoredBox(color: Colors.black),
    errorBuilder: (context, error) => const ColoredBox(color: Colors.black),
  );

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _controller.dispose();
    _state.dispose();
    _torchEnabled.dispose();
  }

  @override
  Future<void> start() async {
    if (_disposed || _handled) return;
    _state.value = CustomerScannerState.initializingCamera;
    try {
      await _controller.start();
      if (!_disposed) _state.value = CustomerScannerState.ready;
    } on MobileScannerException {
      if (!_disposed) _state.value = CustomerScannerState.cameraUnavailable;
    }
  }

  @override
  Future<void> stop() async {
    if (!_disposed) await _controller.stop();
  }

  @override
  Future<void> toggleTorch() async {
    if (_disposed) return;
    await _controller.toggleTorch();
    _torchEnabled.value = _controller.value.torchState == TorchState.on;
  }
}
