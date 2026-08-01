import 'dart:io';

enum AppFlavor { development, staging, production }

enum AppLogLevel { debug, info, minimal }

final class AppEnvironment {
  const AppEnvironment({
    required this.flavor,
    required this.apiBaseUrl,
    required this.pairingEnvironment,
    required this.logLevel,
    required this.allowTestAdapter,
    required this.minimumVersionSource,
    required this.crashReportingEnabled,
    required this.certificatePinningEnabled,
  });

  factory AppEnvironment.fromDefines() {
    const flavorValue = String.fromEnvironment(
      'WAFLO_ENV',
      defaultValue: 'development',
    );
    const apiBaseUrl = String.fromEnvironment(
      'WAFLO_API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );
    const pairingEnvironment = String.fromEnvironment(
      'WAFLO_PAIRING_ENVIRONMENT',
      defaultValue: 'development',
    );
    const logLevel = String.fromEnvironment(
      'WAFLO_LOG_LEVEL',
      defaultValue: 'debug',
    );
    return AppEnvironment(
      flavor: AppFlavor.values.firstWhere(
        (value) => value.name == flavorValue,
        orElse: () => AppFlavor.development,
      ),
      apiBaseUrl: Uri.tryParse(apiBaseUrl) ?? Uri(),
      pairingEnvironment: pairingEnvironment,
      logLevel: AppLogLevel.values.firstWhere(
        (value) => value.name == logLevel,
        orElse: () => AppLogLevel.debug,
      ),
      allowTestAdapter: const bool.fromEnvironment('WAFLO_ALLOW_TEST_ADAPTER'),
      minimumVersionSource: const String.fromEnvironment(
        'WAFLO_MIN_VERSION_SOURCE',
        defaultValue: 'backend',
      ),
      crashReportingEnabled: const bool.fromEnvironment(
        'WAFLO_CRASH_REPORTING',
      ),
      certificatePinningEnabled: const bool.fromEnvironment(
        'WAFLO_CERT_PINNING',
      ),
    );
  }

  final AppFlavor flavor;
  final Uri apiBaseUrl;
  final String pairingEnvironment;
  final AppLogLevel logLevel;
  final bool allowTestAdapter;
  final String minimumVersionSource;
  final bool crashReportingEnabled;
  final bool certificatePinningEnabled;

  bool get isProduction => flavor == AppFlavor.production;

  String get displaySuffix => switch (flavor) {
    AppFlavor.development => ' Dev',
    AppFlavor.staging => ' Staging',
    AppFlavor.production => '',
  };

  List<String> validate() {
    final issues = <String>[];
    if (!apiBaseUrl.hasScheme || apiBaseUrl.host.isEmpty) {
      issues.add('API_BASE_URL_INVALID');
    }
    if (apiBaseUrl.userInfo.isNotEmpty || apiBaseUrl.fragment.isNotEmpty) {
      issues.add('API_BASE_URL_UNSAFE_COMPONENT');
    }
    final host = apiBaseUrl.host.toLowerCase();
    if (host.endsWith('.invalid')) {
      issues.add('API_BASE_URL_PLACEHOLDER');
    }
    final local = _isLocalHost(host);
    if (flavor != AppFlavor.development && apiBaseUrl.scheme != 'https') {
      issues.add('NON_DEVELOPMENT_REQUIRES_HTTPS');
    }
    if (flavor != AppFlavor.development && local) {
      issues.add('NON_DEVELOPMENT_REJECTS_LOCAL_HOST');
    }
    if (flavor == AppFlavor.development &&
        apiBaseUrl.scheme == 'http' &&
        !local) {
      issues.add('DEVELOPMENT_HTTP_MUST_BE_LOCAL');
    }
    if (isProduction && allowTestAdapter) {
      issues.add('PRODUCTION_TEST_ADAPTER_FORBIDDEN');
    }
    if (isProduction && logLevel != AppLogLevel.minimal) {
      issues.add('PRODUCTION_LOG_LEVEL_UNSAFE');
    }
    if (minimumVersionSource != 'backend') {
      issues.add('MINIMUM_VERSION_SOURCE_UNSUPPORTED');
    }
    if (certificatePinningEnabled) {
      issues.add('CERTIFICATE_PINS_NOT_SUPPLIED');
    }
    final allowedPairingEnvironments = switch (flavor) {
      AppFlavor.development => const {'development'},
      // W4 round-1 NODE_ENV calls the staging-equivalent environment "test".
      AppFlavor.staging => const {'test'},
      AppFlavor.production => const {'production'},
    };
    if (!allowedPairingEnvironments.contains(pairingEnvironment)) {
      issues.add('PAIRING_ENVIRONMENT_MISMATCH');
    }
    return List.unmodifiable(issues);
  }

  static bool _isLocalHost(String host) {
    if (host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host == '10.0.2.2' ||
        host == 'lvh.me' ||
        host.endsWith('.localhost') ||
        host.endsWith('.lvh.me')) {
      return true;
    }
    final address = InternetAddress.tryParse(host);
    if (address == null || address.type != InternetAddressType.IPv4) {
      return false;
    }
    final octets = address.address.split('.').map(int.parse).toList();
    return octets[0] == 10 ||
        (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) ||
        (octets[0] == 192 && octets[1] == 168);
  }
}
