import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';

/// The intent behind a value entered in the scanner's neutral manual-code
/// surface. This classifies routing only; authorization remains server-side.
enum ManualCodeIntent { normalPairing, serverReview, localDemo }

abstract interface class ManualCodeIntentResolver {
  ManualCodeIntent resolve(String rawCode);
}

/// Product resolver. It deliberately has no local Demo credential or fixture
/// dependency. Review-looking credentials are still validated by the server.
final class ProductManualCodeIntentResolver
    implements ManualCodeIntentResolver {
  const ProductManualCodeIntentResolver();

  @override
  ManualCodeIntent resolve(String rawCode) {
    final candidate = rawCode.trim();
    final reviewShaped =
        candidate.length <= 12 &&
        RegExp(r'^[A-Za-z0-9 -]+$').hasMatch(candidate);
    final normalized = reviewShaped
        ? PairingFlowService.normalizeReviewAccessCode(candidate)
        : candidate;
    if (reviewShaped &&
        PairingFlowService.isValidReviewAccessCode(normalized)) {
      return ManualCodeIntent.serverReview;
    }
    return ManualCodeIntent.normalPairing;
  }
}
