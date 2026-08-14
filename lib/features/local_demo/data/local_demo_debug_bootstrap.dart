import 'package:waflo_staff/app/bootstrap.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls_debug.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_routes_debug.dart';

/// Debug-only composition root for LOCAL_DEMO. Product main never imports this
/// library, and release-mode staging/development calls are compile-time dead.
LocalDemoBootstrapOverrides buildLocalDemoDebugOverrides() =>
    LocalDemoBootstrapOverrides(
      runtime: LocalDemoRuntimeDebug(),
      routes: buildLocalDemoRoutes(),
      scenarioRoute: '/demo-scenarios',
      scannerControlsBuilder: () => const DebugLocalDemoScannerControls(),
      approvalControlBuilder: (locale) =>
          DebugLocalDemoManagerApprovalAction(locale: locale),
    );
