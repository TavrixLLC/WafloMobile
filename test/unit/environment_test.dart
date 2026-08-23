import 'dart:convert';
import 'dart:io';

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

  test('development accepts ONLY development pairing environment', () {
    expect(
      environment(
        flavor: AppFlavor.development,
        pairing: 'development',
      ).validate(),
      isEmpty,
    );
    for (final invalid in ['test', 'staging', 'production', 'custom']) {
      expect(
        environment(flavor: AppFlavor.development, pairing: invalid).validate(),
        contains('PAIRING_ENVIRONMENT_MISMATCH'),
        reason: 'development should reject $invalid',
      );
    }
  });

  test('production accepts ONLY production pairing environment', () {
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
    for (final invalid in ['test', 'staging', 'development', 'custom']) {
      expect(
        environment(
          flavor: AppFlavor.production,
          pairing: invalid,
          url: 'https://api.waflo.app',
          level: AppLogLevel.minimal,
          testAdapter: false,
        ).validate(),
        contains('PAIRING_ENVIRONMENT_MISMATCH'),
        reason: 'production should reject $invalid',
      );
    }
  });

  test('staging accepts ONLY staging pairing environment', () {
    expect(
      environment(
        flavor: AppFlavor.staging,
        pairing: 'staging',
        url: 'https://api-staging.waflo.app',
        level: AppLogLevel.info,
        testAdapter: false,
      ).validate(),
      isEmpty,
    );
    for (final invalid in ['test', 'development', 'production', 'custom']) {
      expect(
        environment(
          flavor: AppFlavor.staging,
          pairing: invalid,
          url: 'https://api-staging.waflo.app',
          level: AppLogLevel.info,
          testAdapter: false,
        ).validate(),
        contains('PAIRING_ENVIRONMENT_MISMATCH'),
        reason: 'staging should reject $invalid',
      );
    }
  });

  test('staging and production reject every non-canonical API origin', () {
    for (final url in <String>[
      'https://api.staging.waflo.app',
      'https://staging-api.waflo.app',
      'https://api-staging.waflo.app/v1',
      'http://10.0.2.2:3000',
    ]) {
      expect(
        environment(
          flavor: AppFlavor.staging,
          pairing: 'staging',
          url: url,
          level: AppLogLevel.info,
          testAdapter: false,
        ).validate(),
        contains('NON_DEVELOPMENT_API_ORIGIN_MISMATCH'),
        reason: url,
      );
    }
    expect(
      environment(
        flavor: AppFlavor.production,
        pairing: 'production',
        url: 'https://api-staging.waflo.app',
        level: AppLogLevel.minimal,
        testAdapter: false,
      ).validate(),
      contains('NON_DEVELOPMENT_API_ORIGIN_MISMATCH'),
    );
  });

  test(
    'committed release configurations use only canonical HTTPS origins and pairing environments',
    () {
      final staging =
          jsonDecode(File('config/staging.json').readAsStringSync())
              as Map<String, dynamic>;
      final production =
          jsonDecode(File('config/production.json').readAsStringSync())
              as Map<String, dynamic>;

      expect(staging['WAFLO_API_BASE_URL'], 'https://api-staging.waflo.app');
      expect(staging['WAFLO_PAIRING_ENVIRONMENT'], 'staging');
      expect(production['WAFLO_API_BASE_URL'], 'https://api.waflo.app');
      expect(production['WAFLO_PAIRING_ENVIRONMENT'], 'production');
    },
  );

  test('iOS staging scheme embeds the same secure Dart configuration', () {
    final staging =
        jsonDecode(File('config/staging.json').readAsStringSync())
            as Map<String, dynamic>;
    final environmentConfig = File(
      'ios/Flutter/Environment-staging.xcconfig',
    ).readAsStringSync();
    final encodedDefines = RegExp(
      r'^DART_DEFINES=(.+)$',
      multiLine: true,
    ).firstMatch(environmentConfig)?.group(1);

    expect(encodedDefines, isNotNull);
    final iosDefines = <String, String>{};
    for (final encoded in encodedDefines!.split(',')) {
      final definition = utf8.decode(base64Decode(encoded));
      final separator = definition.indexOf('=');
      expect(separator, greaterThan(0), reason: definition);
      iosDefines[definition.substring(0, separator)] = definition.substring(
        separator + 1,
      );
    }

    expect(iosDefines, staging.map((key, value) => MapEntry(key, '$value')));
    expect(
      AppEnvironment(
        flavor: AppFlavor.staging,
        expectedNativeFlavor: AppFlavor.staging,
        suppliedDartEnvironment: iosDefines['WAFLO_ENV']!,
        apiBaseUrl: Uri.parse(iosDefines['WAFLO_API_BASE_URL']!),
        pairingEnvironment: iosDefines['WAFLO_PAIRING_ENVIRONMENT']!,
        logLevel: AppLogLevel.values.byName(iosDefines['WAFLO_LOG_LEVEL']!),
        allowTestAdapter: bool.tryParse(
          iosDefines['WAFLO_ALLOW_TEST_ADAPTER']!,
        )!,
        localDemoRequested: bool.tryParse(
          iosDefines['WAFLO_LOCAL_DEMO_ENABLED']!,
        )!,
        minimumVersionSource: iosDefines['WAFLO_MIN_VERSION_SOURCE']!,
        crashReportingEnabled: bool.tryParse(
          iosDefines['WAFLO_CRASH_REPORTING']!,
        )!,
        certificatePinningEnabled: bool.tryParse(
          iosDefines['WAFLO_CERT_PINNING']!,
        )!,
      ).validate(),
      isEmpty,
    );

    for (final mode in ['Debug', 'Profile', 'Release']) {
      final xcconfig = File(
        'ios/Flutter/$mode-staging.xcconfig',
      ).readAsStringSync();
      expect(
        xcconfig.indexOf('#include "Environment-staging.xcconfig"'),
        lessThan(xcconfig.indexOf('#include "Generated.xcconfig"')),
        reason:
            '$mode must allow explicit Flutter CLI defines to override '
            'the Xcode-scheme fallback.',
      );
      expect(xcconfig, contains('FLUTTER_TARGET=lib/main_staging.dart'));
      expect(xcconfig, contains('FLAVOR=staging'));
    }

    final scheme = File(
      'ios/Runner.xcodeproj/xcshareddata/xcschemes/staging.xcscheme',
    ).readAsStringSync();
    for (final mapping in [
      'TestAction buildConfiguration="Debug"',
      'LaunchAction buildConfiguration="Debug-staging"',
      'ProfileAction buildConfiguration="Profile-staging"',
      'AnalyzeAction buildConfiguration="Debug-staging"',
      'ArchiveAction buildConfiguration="Release-staging"',
    ]) {
      expect(scheme, contains(mapping));
    }
  });

  test(
    'staging entrypoint without Dart defines fails the exact secure checks',
    () {
      expect(
        AppEnvironment.fromDefines(
          expectedNativeFlavor: AppFlavor.staging,
        ).validate(),
        const [
          'REQUIRED_DART_CONFIGURATION_MISSING',
          'DART_ENVIRONMENT_INVALID',
          'API_BASE_URL_INVALID',
          'NON_DEVELOPMENT_REQUIRES_HTTPS',
          'NON_DEVELOPMENT_API_ORIGIN_MISMATCH',
          'PAIRING_ENVIRONMENT_MISMATCH',
        ],
      );
    },
    skip: const String.fromEnvironment('WAFLO_ENV').isNotEmpty,
  );

  test(
    'supplied staging or production Dart configuration passes every guard',
    () {
      final expectedFlavor = AppFlavor.values.byName(
        const String.fromEnvironment('WAFLO_ENV'),
      );
      final environment = AppEnvironment.fromDefines(
        expectedNativeFlavor: expectedFlavor,
      );

      expect(environment.validate(), isEmpty);
    },
    skip:
        const String.fromEnvironment('WAFLO_ENV') != 'staging' &&
        const String.fromEnvironment('WAFLO_ENV') != 'production',
  );

  test('native and Dart flavors must match exactly', () {
    final mismatched = AppEnvironment(
      flavor: AppFlavor.production,
      expectedNativeFlavor: AppFlavor.staging,
      suppliedDartEnvironment: 'production',
      apiBaseUrl: Uri.parse('https://api.waflo.app'),
      pairingEnvironment: 'production',
      logLevel: AppLogLevel.minimal,
      allowTestAdapter: false,
      minimumVersionSource: 'backend',
      crashReportingEnabled: false,
      certificatePinningEnabled: false,
    );
    expect(mismatched.validate(), contains('NATIVE_DART_FLAVOR_MISMATCH'));
  });

  test('missing native flavor and Dart configuration fail closed', () {
    final missing = AppEnvironment(
      flavor: AppFlavor.production,
      nativeFlavorSupplied: false,
      requiredDefinesSupplied: false,
      dartEnvironmentRecognized: false,
      apiBaseUrl: Uri(),
      pairingEnvironment: '',
      logLevel: AppLogLevel.minimal,
      allowTestAdapter: false,
      minimumVersionSource: 'backend',
      crashReportingEnabled: false,
      certificatePinningEnabled: false,
    );
    expect(missing.validate(), contains('NATIVE_FLAVOR_MISSING'));
    expect(missing.validate(), contains('REQUIRED_DART_CONFIGURATION_MISSING'));
    expect(missing.validate(), contains('DART_ENVIRONMENT_INVALID'));
  });
}
