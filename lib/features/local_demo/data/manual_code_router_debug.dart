import 'package:waflo_staff/features/pairing/domain/manual_code_router.dart';

/// Compatibility wrapper for older debug composition roots. Debug builds now
/// use the same hashed local Review code and rate limiter as Store builds.
final class DebugManualCodeIntentResolver implements ManualCodeIntentResolver {
  const DebugManualCodeIntentResolver({String? configuredCode});

  static bool get hasConfiguredCode => false;

  @override
  ManualCodeIntent resolve(String rawCode) =>
      const ProductManualCodeIntentResolver().resolve(rawCode);
}
