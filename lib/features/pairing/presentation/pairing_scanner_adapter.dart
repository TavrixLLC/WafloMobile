import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract interface class PairingScannerAdapter {
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
        autoStart: true,
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      );

  final MobileScannerController _controller;

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
        unawaited(onDetected(candidate));
      }
    },
    placeholderBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
  );

  @override
  Future<void> dispose() => _controller.dispose();

  @override
  Future<void> start() => _controller.start();

  @override
  Future<void> stop() => _controller.stop();

  @override
  Future<void> toggleTorch() => _controller.toggleTorch();
}
