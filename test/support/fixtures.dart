import 'package:waflo_staff/features/device_context/domain/device_context.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';

StaffDeviceSession fixtureSession({
  String sessionId = '00000000-0000-4000-8000-000000000201',
  String deviceStatus = 'ACTIVE',
  DateTime? expiresAt,
}) => StaffDeviceSession(
  devicePublicId: '00000000-0000-4000-8000-000000000202',
  deviceDisplayName: 'Test staff device',
  devicePlatform: 'ANDROID',
  deviceStatus: deviceStatus,
  sessionId: sessionId,
  accessToken: 'fixture-access-token-not-a-real-credential-000000000000',
  refreshToken: 'fixture-refresh-token-not-a-real-credential-00000000000',
  accessExpiresAt: expiresAt ?? DateTime.utc(2030, DateTime.january, 1, 12),
  organizationId: '00000000-0000-4000-8000-000000000203',
  role: 'STAFF',
  locationId: '00000000-0000-4000-8000-000000000204',
  issuedAt: DateTime.utc(2026, DateTime.july, 30, 12),
);

AuthoritativeDeviceContext fixtureContext({
  List<LocationContext>? assignedLocations,
}) => AuthoritativeDeviceContext(
  organization: const OrganizationContext(
    publicId: 'fixture-merchant',
    displayName: 'Fixture Coffee',
  ),
  staff: const StaffContext(
    publicId: '00000000-0000-4000-8000-000000000205',
    displayName: 'Fixture Staff',
    role: 'STAFF',
  ),
  device: const DeviceContextSummary(
    publicId: '00000000-0000-4000-8000-000000000202',
    displayName: 'Test staff device',
    status: 'ACTIVE',
    platform: 'ANDROID',
    appVersion: '1.0.0',
  ),
  currentLocation: const LocationContext(
    publicId: '00000000-0000-4000-8000-000000000204',
    displayName: 'Main branch',
    earningAllowed: true,
    redemptionAllowed: true,
  ),
  assignedLocations:
      assignedLocations ??
      const [
        LocationContext(
          publicId: '00000000-0000-4000-8000-000000000204',
          displayName: 'Main branch',
          earningAllowed: true,
          redemptionAllowed: true,
        ),
      ],
  appPolicy: const AppUpdatePolicy(
    minimumSupportedVersion: '1.0.0',
    updateRequired: false,
  ),
  requestId: '00000000-0000-4000-8000-000000000207',
  synchronizedAt: DateTime.utc(2026, DateTime.july, 30, 12),
);
