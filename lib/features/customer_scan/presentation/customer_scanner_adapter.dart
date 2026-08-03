import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_mode.dart';

abstract interface class CustomerScannerAdapter {
  ScannerMode get mode;

  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  });

  Future<void> start();
  Future<void> stop();
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
  bool _handled = false;
  bool _disposed = false;

  @override
  ScannerMode get mode => ScannerMode.customerMembershipQr;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => MobileScanner(
    key: const Key('customer-membership-scanner'),
    controller: _controller,
    onDetect: (capture) {
      if (_handled || _disposed) {
        return;
      }
      final candidate = capture.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .firstOrNull;
      if (candidate == null) {
        return;
      }
      _handled = true;
      unawaited(
        stop().then((_) {
          final bounded = candidate.length > maximumCandidateLength
              ? candidate.substring(0, maximumCandidateLength + 1)
              : candidate;
          return onDetected(bounded);
        }),
      );
    },
    placeholderBuilder: (context) =>
        const Center(child: CircularProgressIndicator()),
  );

  @override
  Future<void> start() async {
    if (!_disposed && !_handled) {
      await _controller.start();
    }
  }

  @override
  Future<void> stop() async {
    if (!_disposed) {
      await _controller.stop();
    }
  }

  @override
  Future<void> resetForExplicitRetry() async {
    _handled = false;
    await start();
  }

  @override
  Future<void> toggleTorch() async {
    if (!_disposed) {
      await _controller.toggleTorch();
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await _controller.dispose();
  }
}

final class FixtureCustomerScannerAdapter implements CustomerScannerAdapter {
  FixtureCustomerScannerAdapter(this.candidate);

  final String candidate;
  bool started = false;
  bool delivered = false;

  @override
  ScannerMode get mode => ScannerMode.customerMembershipQr;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) {
    if (started && !delivered) {
      delivered = true;
      scheduleMicrotask(() => onDetected(candidate));
    }
    return const ColoredBox(
      key: Key('fixture-customer-scanner'),
      color: Colors.black,
    );
  }

  @override
  Future<void> start() async => started = true;

  @override
  Future<void> stop() async => started = false;

  @override
  Future<void> resetForExplicitRetry() async {
    delivered = false;
    started = true;
  }

  @override
  Future<void> toggleTorch() async {}

  @override
  Future<void> dispose() async => started = false;
}
