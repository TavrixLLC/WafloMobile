import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/features/local_demo/data/manual_code_router_debug.dart';
import 'package:waflo_staff/features/pairing/domain/manual_code_router.dart';

void main() {
  const product = ProductManualCodeIntentResolver();

  test('product resolver preserves normal pairing payloads', () {
    const pairingPayload =
        'waflo-pair-v1.MTIzZTQ1NjctZTg5Yi00MmQzLWE0NTYtNDI2NjE0MTc0MDAw.'
        'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVo1Njc4OTA.'
        'cHJvZHVjdGlvbg';
    expect(product.resolve(pairingPayload), ManualCodeIntent.normalPairing);
  });

  test('product resolver routes review-shaped values to server authority', () {
    expect(product.resolve('abcd 2345'), ManualCodeIntent.serverReview);
  });

  test('debug resolver recognizes only its injected owner code locally', () {
    const resolver = DebugManualCodeIntentResolver(configuredCode: 'M3FE-2468');
    expect(resolver.resolve('M3FE-2468'), ManualCodeIntent.localDemo);
    expect(resolver.resolve('M3FE-2469'), ManualCodeIntent.serverReview);
  });

  test('debug resolver without an injected code has no local entry', () {
    const resolver = DebugManualCodeIntentResolver(configuredCode: '');
    expect(resolver.resolve('M3FE-2468'), ManualCodeIntent.serverReview);
  });
}
