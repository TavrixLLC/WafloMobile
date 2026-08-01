final class AuthoritativeDeviceContext {
  const AuthoritativeDeviceContext({
    required this.organizationId,
    required this.organizationMemberId,
    required this.role,
    required this.locationId,
    required this.deviceId,
    required this.devicePublicId,
    required this.deviceSessionId,
    required this.platform,
    required this.requestId,
    required this.synchronizedAt,
  });

  final String organizationId;
  final String organizationMemberId;
  final String role;
  final String locationId;
  final String deviceId;
  final String devicePublicId;
  final String deviceSessionId;
  final String platform;
  final String requestId;
  final DateTime synchronizedAt;

  int get assignedLocationCount => 1;

  @override
  String toString() =>
      'AuthoritativeDeviceContext(role: $role, platform: $platform, ids: [REDACTED])';
}
