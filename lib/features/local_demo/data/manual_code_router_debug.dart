import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:waflo_staff/features/pairing/domain/manual_code_router.dart';

/// Debug-only resolver injected by development/staging debug entrypoints.
/// The owner code comes exclusively from `--dart-define` and is never stored.
final class DebugManualCodeIntentResolver implements ManualCodeIntentResolver {
  const DebugManualCodeIntentResolver({String? configuredCode})
    : _productResolver = const ProductManualCodeIntentResolver(),
      _configured = configuredCode ?? _buildConfiguredCode;

  static const _buildConfiguredCode = String.fromEnvironment(
    'WAFLO_LOCAL_DEMO_CODE',
  );

  final ManualCodeIntentResolver _productResolver;
  final String _configured;

  static bool get hasConfiguredCode => _buildConfiguredCode.trim().length >= 8;

  @override
  ManualCodeIntent resolve(String rawCode) {
    if (_configured.trim().length >= 8 &&
        _constantTimeEquals(rawCode.trim(), _configured)) {
      return ManualCodeIntent.localDemo;
    }
    return _productResolver.resolve(rawCode);
  }

  static bool _constantTimeEquals(String candidate, String expected) {
    final candidateDigest = sha256.convert(utf8.encode(candidate));
    final expectedDigest = sha256.convert(utf8.encode(expected));
    var difference = 0;
    for (var index = 0; index < candidateDigest.bytes.length; index++) {
      difference |= candidateDigest.bytes[index] ^ expectedDigest.bytes[index];
    }
    return difference == 0;
  }
}
