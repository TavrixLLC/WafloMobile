import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/api/api_error_decoder.dart';
import 'package:waflo_staff/core/crypto/device_identity.dart';
import 'package:waflo_staff/core/crypto/request_signing.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/membership_resolution/data/loyalty_operations_api.dart';
import 'package:waflo_staff/features/reward_redemption/domain/redemption_models.dart';
import 'package:waflo_staff/features/stamp_operation/domain/stamp_models.dart';

void main() {
  test('signed M2 request bodies omit the UI locale', () async {
    final store = MemorySecureKeyValueStore();
    final sessions = StaffDeviceSessionRepository(store);
    await sessions.replaceAtomically(_session);
    final identity = DeviceIdentityRepository(store);
    await identity.loadOrCreate();
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.invalid'))
      ..httpClientAdapter = adapter;
    final api = SignedLoyaltyOperationsApi(
      dio: dio,
      signer: DeviceRequestSigner(identity),
      errorDecoder: const ApiErrorDecoder(),
      sessionRepository: sessions,
      refreshSession: () => throw StateError('Session must not refresh.'),
      allowInsecureAssets: false,
    );

    await expectLater(
      api.resolveMembership(qrPayload: _credential, locale: 'ar'),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      api.issueStamps(
        qrPayload: _credential,
        locale: 'en',
        commandId: '10000000-0000-4000-8000-000000000001',
        input: const StampOperationInput(
          amount: 1,
          purchaseAmountMinor: 10000,
          purchaseCurrency: 'iqd',
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );
    await expectLater(
      api.redeemReward(
        qrPayload: _credential,
        locale: 'ar',
        commandId: '10000000-0000-4000-8000-000000000002',
        input: const RedemptionOperationInput(
          entitlementPublicId: '20000000-0000-4000-8000-000000000001',
          finalReward: true,
        ),
      ),
      throwsA(isA<ApiFailure>()),
    );

    expect(adapter.requests, hasLength(3));
    final bodies = adapter.requests
        .map((request) => jsonDecode(request.data! as String))
        .cast<Map<String, Object?>>()
        .toList(growable: false);
    for (final body in bodies) {
      expect(body, isNot(contains('locale')));
    }
    expect(bodies[0].keys, {'qrPayload'});
    expect(bodies[1]['purchaseCurrency'], 'IQD');
    expect(bodies[2].keys, {'qrPayload', 'rewardEntitlementPublicId'});
  });
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'error': {
          'code': 'MEMBERSHIP_NOT_OPERATIONAL',
          'message': 'Synthetic safe rejection.',
          'requestId': 'synthetic-request',
        },
      }),
      422,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final _credential = 'x' * 40;

final _session = StaffDeviceSession(
  devicePublicId: '30000000-0000-4000-8000-000000000001',
  deviceDisplayName: 'Synthetic device',
  devicePlatform: 'ANDROID',
  deviceStatus: 'ACTIVE',
  sessionId: '40000000-0000-4000-8000-000000000001',
  accessToken: 'a' * 40,
  refreshToken: 'b' * 40,
  accessExpiresAt: DateTime.utc(2099),
  organizationId: '50000000-0000-4000-8000-000000000001',
  role: 'STAFF',
  locationId: '60000000-0000-4000-8000-000000000001',
  issuedAt: DateTime.utc(2026, 8, 10),
);
