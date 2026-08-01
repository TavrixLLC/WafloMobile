final class OrganizationContext {
  const OrganizationContext({
    required this.publicId,
    required this.displayName,
  });

  final String publicId;
  final String displayName;
}

final class StaffContext {
  const StaffContext({
    required this.publicId,
    required this.displayName,
    required this.role,
  });

  final String publicId;
  final String displayName;
  final String role;
}

final class DeviceContextSummary {
  const DeviceContextSummary({
    required this.publicId,
    required this.displayName,
    required this.status,
    required this.platform,
    required this.appVersion,
  });

  final String publicId;
  final String displayName;
  final String status;
  final String platform;
  final String appVersion;
}

final class LocationContext {
  const LocationContext({
    required this.publicId,
    required this.displayName,
    required this.earningAllowed,
    required this.redemptionAllowed,
  });

  final String publicId;
  final String displayName;
  final bool earningAllowed;
  final bool redemptionAllowed;
}

final class AppUpdatePolicy {
  const AppUpdatePolicy({
    required this.minimumSupportedVersion,
    required this.updateRequired,
  });

  final String minimumSupportedVersion;
  final bool updateRequired;
}

final class AuthoritativeDeviceContext {
  const AuthoritativeDeviceContext({
    required this.organization,
    required this.staff,
    required this.device,
    required this.currentLocation,
    required this.assignedLocations,
    required this.appPolicy,
    required this.requestId,
    required this.synchronizedAt,
  });

  final OrganizationContext organization;
  final StaffContext staff;
  final DeviceContextSummary device;
  final LocationContext currentLocation;
  final List<LocationContext> assignedLocations;
  final AppUpdatePolicy appPolicy;
  final String requestId;
  final DateTime synchronizedAt;

  String get role => staff.role;
  String get platform => device.platform;
  String get devicePublicId => device.publicId;
  int get assignedLocationCount => assignedLocations.length;

  @override
  String toString() =>
      'AuthoritativeDeviceContext(role: $role, platform: $platform, ids: [REDACTED])';
}
