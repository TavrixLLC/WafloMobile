import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/device_session/data/signed_device_api.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

void main() {
  test('successful M2 device context requires supported strict versions', () {
    final context = SignedDeviceApi.parseM2ContextResponse(
      _response(appVersionSupported: true),
      _session,
    );

    expect(context.device.appVersion, '1.2.3');
    expect(context.appPolicy.minimumSupportedVersion, '1.0.0');
    expect(context.appPolicy.updateRequired, isFalse);
    expect(context.currentLocation.capabilitiesKnown, isFalse);
  });

  test('successful response cannot report unsupported app version', () {
    expect(
      () => SignedDeviceApi.parseM2ContextResponse(
        _response(appVersionSupported: false),
        _session,
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.safeCode,
          'safeCode',
          'STAFF_APP_VERSION_UNSUPPORTED',
        ),
      ),
    );
  });

  test('M2 device context rejects identifier and request mismatches', () {
    final response = _response(appVersionSupported: true);
    final data = response['data']! as Map<String, Object?>;
    data['requestId'] = 'different-request';
    expect(
      () => SignedDeviceApi.parseM2ContextResponse(response, _session),
      throwsA(isA<ApiFailure>()),
    );
  });
}

Map<String, Object?> _response({required bool appVersionSupported}) => {
  'data': <String, Object?>{
    'organizationId': _session.organizationId,
    'role': _session.role,
    'locationId': _session.locationId,
    'devicePublicId': _session.devicePublicId,
    'deviceSessionId': _session.sessionId,
    'platform': _session.devicePlatform,
    'appVersion': '1.2.3',
    'minimumSupportedAppVersion': '1.0.0',
    'appVersionSupported': appVersionSupported,
    'requestId': 'request-1',
  },
  'requestId': 'request-1',
};

final _session = StaffDeviceSession(
  devicePublicId: '10000000-0000-4000-8000-000000000001',
  deviceDisplayName: 'Fixture device',
  devicePlatform: 'ANDROID',
  deviceStatus: 'ACTIVE',
  sessionId: '20000000-0000-4000-8000-000000000001',
  accessToken: 'a' * 40,
  refreshToken: 'b' * 40,
  accessExpiresAt: DateTime.utc(2026, 8, 7, 14),
  organizationId: '30000000-0000-4000-8000-000000000001',
  role: 'STAFF',
  locationId: '40000000-0000-4000-8000-000000000001',
  issuedAt: DateTime.utc(2026, 8, 7, 12),
);
