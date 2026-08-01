import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/environment.dart';

void main() {
  AppEnvironment environment({
    AppFlavor flavor = AppFlavor.development,
    String url = 'http://10.0.2.2:3000',
    String pairing = 'development',
    AppLogLevel level = AppLogLevel.debug,
    bool testAdapter = true,
  }) => AppEnvironment(
    flavor: flavor,
    apiBaseUrl: Uri.parse(url),
    pairingEnvironment: pairing,
    logLevel: level,
    allowTestAdapter: testAdapter,
    minimumVersionSource: 'backend',
    crashReportingEnabled: false,
    certificatePinningEnabled: false,
  );

  test('development accepts only an explicitly local HTTP endpoint', () {
    expect(environment().validate(), isEmpty);
    expect(
      environment(url: 'http://example.com').validate(),
      contains('DEVELOPMENT_HTTP_MUST_BE_LOCAL'),
    );
  });

  test(
    'production rejects HTTP, local hosts, debug logs, and test adapter',
    () {
      final issues = environment(
        flavor: AppFlavor.production,
        pairing: 'production',
        url: 'http://127.0.0.1:3000',
      ).validate();
      expect(issues, contains('NON_DEVELOPMENT_REQUIRES_HTTPS'));
      expect(issues, contains('NON_DEVELOPMENT_REJECTS_LOCAL_HOST'));
      expect(issues, contains('PRODUCTION_TEST_ADAPTER_FORBIDDEN'));
      expect(issues, contains('PRODUCTION_LOG_LEVEL_UNSAFE'));
    },
  );

  test('production configuration passes with isolated safe values', () {
    expect(
      environment(
        flavor: AppFlavor.production,
        pairing: 'production',
        url: 'https://api.waflo.app',
        level: AppLogLevel.minimal,
        testAdapter: false,
      ).validate(),
      isEmpty,
    );
  });

  test('reserved deployment placeholder fails closed', () {
    expect(
      environment(
        flavor: AppFlavor.production,
        pairing: 'production',
        url: 'https://api.example.invalid',
        level: AppLogLevel.minimal,
        testAdapter: false,
      ).validate(),
      contains('API_BASE_URL_PLACEHOLDER'),
    );
  });

  test('staging maps to the approved W4 test pairing environment', () {
    expect(
      environment(
        flavor: AppFlavor.staging,
        pairing: 'staging',
        url: 'https://staging-api.waflo.app',
        level: AppLogLevel.info,
        testAdapter: false,
      ).validate(),
      contains('PAIRING_ENVIRONMENT_MISMATCH'),
    );
  });
}
