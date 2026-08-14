import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/app.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/app/router.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_navigation.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls.dart';

final class LocalDemoBootstrapOverrides {
  const LocalDemoBootstrapOverrides({
    required this.runtime,
    required this.routes,
    required this.scenarioRoute,
    required this.scannerControlsBuilder,
    required this.approvalControlBuilder,
  });

  final LocalDemoRuntime runtime;
  final List<RouteBase> routes;
  final String scenarioRoute;
  final LocalDemoScannerControlsBuilder scannerControlsBuilder;
  final LocalDemoApprovalControlBuilder approvalControlBuilder;
}

Future<void> bootstrap({
  AppFlavor? expectedNativeFlavor,
  AppEnvironment? environment,
  SharedPreferences? preferences,
  SecureKeyValueStore? secureStore,
  LocalDemoBootstrapOverrides? localDemo,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final resolvedPreferences =
      preferences ?? await SharedPreferences.getInstance();
  final resolvedEnvironment =
      environment ??
      AppEnvironment.fromDefines(expectedNativeFlavor: expectedNativeFlavor);
  runApp(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(resolvedEnvironment),
        sharedPreferencesProvider.overrideWithValue(resolvedPreferences),
        if (secureStore != null)
          secureStoreProvider.overrideWithValue(secureStore),
        if (localDemo != null) ...[
          localDemoRuntimeProvider.overrideWithValue(localDemo.runtime),
          localDemoRoutesProvider.overrideWithValue(localDemo.routes),
          localDemoScenarioRouteProvider.overrideWithValue(
            localDemo.scenarioRoute,
          ),
          localDemoScannerControlsBuilderProvider.overrideWithValue(
            localDemo.scannerControlsBuilder,
          ),
          localDemoApprovalControlBuilderProvider.overrideWithValue(
            localDemo.approvalControlBuilder,
          ),
        ],
      ],
      child: const WafloApp(),
    ),
  );
}
