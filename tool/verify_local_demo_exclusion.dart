import 'dart:convert';
import 'dart:io';

void main() {
  final failures = <String>[];
  final providers = _read('lib/app/providers.dart');
  final operationControls = _read(
    'lib/features/local_demo/presentation/local_demo_operation_controls.dart',
  );
  final releaseRuntime = _read(
    'lib/features/local_demo/data/local_demo_runtime_release.dart',
  );
  final debugBootstrap = _read(
    'lib/features/local_demo/data/local_demo_debug_bootstrap.dart',
  );
  final debugCodeResolver = _read(
    'lib/features/local_demo/data/manual_code_router_debug.dart',
  );
  final productCodeResolver = _read(
    'lib/features/pairing/domain/manual_code_router.dart',
  );
  final sharedController = _read(
    'lib/features/local_demo/presentation/local_demo_controller.dart',
  );
  final environment = _read('lib/app/environment.dart');
  final router = _read('lib/app/router.dart');
  final developmentMain = _read('lib/main_development.dart');
  final stagingMain = _read('lib/main_staging.dart');
  final productionMain = _read('lib/main_production.dart');
  final production = _json('config/production.json');
  final staging = _json('config/staging.json');

  _expectContains(
    providers,
    'local_demo_runtime_release.dart',
    'Shared providers must default to the deny-all release runtime.',
    failures,
  );
  _expectContains(
    operationControls,
    'const SizedBox.shrink()',
    'Shared operational simulation-control slots must default to empty.',
    failures,
  );
  _expectContains(
    debugBootstrap,
    'LocalDemoRuntimeDebug()',
    'The local fixture runtime must be rooted only in the debug bootstrap.',
    failures,
  );
  _expectContains(
    debugBootstrap,
    'DebugManualCodeIntentResolver()',
    'The injected owner-code matcher must remain rooted in debug bootstrap.',
    failures,
  );
  _expectContains(
    debugCodeResolver,
    "String.fromEnvironment(\n    'WAFLO_LOCAL_DEMO_CODE'",
    'Local owner code must come from an untracked compile-time define.',
    failures,
  );
  final productResolverBody = productCodeResolver
      .split('final class ProductManualCodeIntentResolver')
      .last;
  if (productResolverBody.contains('ManualCodeIntent.localDemo') ||
      productResolverBody.contains('WAFLO_LOCAL_DEMO_CODE')) {
    failures.add(
      'Product manual-code resolver must not contain local Demo capability.',
    );
  }
  _expectContains(
    releaseRuntime,
    'bool availableFor(AppEnvironment environment) => false',
    'Product runtime must deny LOCAL_DEMO availability.',
    failures,
  );
  _expectContains(
    router,
    '(ref) => const <RouteBase>[]',
    'The shared router must default to an empty local-demo route table.',
    failures,
  );
  _expectContains(
    environment,
    'PRODUCTION_LOCAL_DEMO_FORBIDDEN',
    'Production environment validation must reject a local-demo request.',
    failures,
  );
  _expectContains(
    router,
    'if (localDemoAvailable) ...ref.watch(localDemoRoutesProvider)',
    'Router must obtain local-demo routes through an injected provider.',
    failures,
  );
  for (final entrypoint in [developmentMain, stagingMain]) {
    _expectContains(
      entrypoint,
      'kDebugMode ? buildLocalDemoDebugOverrides() : null',
      'Development/staging must attach local Demo only in debug mode.',
      failures,
    );
  }
  if (productionMain.contains('local_demo') ||
      productionMain.contains('buildLocalDemoDebugOverrides') ||
      productionMain.contains('WAFLO_LOCAL_DEMO_CODE')) {
    failures.add(
      'Production entrypoint must not import or reference local Demo code.',
    );
  }

  if (production['WAFLO_LOCAL_DEMO_ENABLED'] != 'false') {
    failures.add('Production config must set WAFLO_LOCAL_DEMO_ENABLED=false.');
  }
  if (production['WAFLO_API_BASE_URL'] != 'https://api.waflo.app') {
    failures.add('Production API authority changed unexpectedly.');
  }
  if (staging['WAFLO_API_BASE_URL'] != 'https://api-staging.waflo.app') {
    failures.add('Staging API authority changed unexpectedly.');
  }
  if (sharedController.contains("setPin('2468')")) {
    failures.add(
      'The local fixture PIN must remain behind the debug-only runtime import.',
    );
  }

  if (failures.isNotEmpty) {
    stderr.writeln('LOCAL_DEMO production-exclusion verification failed:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'LOCAL_DEMO production exclusion verified: product-root deny-all runtime, '
    'injected debug-only routes/controls/code resolver, strict production config, and '
    'unchanged API authorities.',
  );
}

String _read(String path) =>
    File(path).readAsStringSync().replaceAll('\r\n', '\n');

Map<String, Object?> _json(String path) =>
    jsonDecode(_read(path)) as Map<String, Object?>;

void _expectContains(
  String source,
  String expected,
  String failure,
  List<String> failures,
) {
  if (!source.contains(expected)) failures.add(failure);
}
