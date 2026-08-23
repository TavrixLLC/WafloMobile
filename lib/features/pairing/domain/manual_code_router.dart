import 'package:waflo_staff/features/review_access/domain/local_review_access.dart';

/// The intent behind a value entered in the scanner's neutral manual-code
/// surface. This classifies routing only; authorization remains in the local
/// Review access authority.
enum ManualCodeIntent { normalPairing, localReview }

abstract interface class ManualCodeIntentResolver {
  ManualCodeIntent resolve(String rawCode);
}

/// Product resolver. It recognizes only the dedicated Review-code shape; the
/// resolver never verifies, persists, logs, or transmits the entered value.
final class ProductManualCodeIntentResolver
    implements ManualCodeIntentResolver {
  const ProductManualCodeIntentResolver();

  @override
  ManualCodeIntent resolve(String rawCode) {
    final candidate = rawCode.trim();
    final reviewShaped =
        candidate.length <= 16 &&
        RegExp(r'^[A-Za-z0-9 -]+$').hasMatch(candidate);
    final normalized = reviewShaped
        ? LocalReviewCodeFormat.normalize(candidate)
        : candidate;
    if (reviewShaped && LocalReviewCodeFormat.isValid(normalized)) {
      return ManualCodeIntent.localReview;
    }
    return ManualCodeIntent.normalPairing;
  }
}
