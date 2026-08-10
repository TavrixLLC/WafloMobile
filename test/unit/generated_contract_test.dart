import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_claim_request.dart';
import 'package:waflo_staff/core/api/generated/models/device_pairing_claim_request_platform.dart';

void main() {
  test('pairing claim omits unknown optional device metadata', () {
    const request = DevicePairingClaimRequest(
      pairingToken: 'synthetic-token',
      installationId: 'synthetic-installation',
      publicKey: 'synthetic-public-key',
      platform: DevicePairingClaimRequestPlatform.ios,
      appVersion: '0.9.9',
    );

    final json = request.toJson();

    expect(json, isNot(contains('osVersion')));
    expect(json, isNot(contains('model')));
    expect(json['appVersion'], '0.9.9');
  });
}
