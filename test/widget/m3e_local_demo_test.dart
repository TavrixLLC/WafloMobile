import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/haptics/haptic_service.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/local_demo/data/manual_code_router_debug.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls_debug.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_scenarios_screen.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';

void main() {
  testWidgets(
    'staging debug keeps Demo hidden and accepts the injected manual code',
    (tester) async {
      final container = _container(LocalDemoRuntimeDebug(forceAvailable: true));
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _LocalizedApp(child: PairingFlowScreen()),
        ),
      );

      expect(find.textContaining('Demo'), findsNothing);
      expect(find.textContaining('Review'), findsNothing);
      container.read(pairingControllerProvider.notifier).showManualEntry();
      await tester.pump();
      expect(find.byKey(const Key('manual-code-input')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('manual-code-input')),
        'M3FE-2468',
      );
      await tester.tap(find.byKey(const Key('manual-code-continue')));
      await tester.pump();
      expect(container.read(localDemoControllerProvider).active, isTrue);
      expect(container.read(bootControllerProvider).session, isNull);
    },
  );

  testWidgets('production manual entry exposes no local Demo capability', (
    tester,
  ) async {
    final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
    final container = ProviderContainer(
      overrides: [
        environmentProvider.overrideWithValue(
          _environment(AppFlavor.production),
        ),
        localDemoRuntimeProvider.overrideWithValue(runtime),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _LocalizedApp(child: PairingFlowScreen()),
      ),
    );

    container.read(pairingControllerProvider.notifier).showManualEntry();
    await tester.pump();
    expect(find.byKey(const Key('manual-code-input')), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Review'), findsNothing);
    expect(
      await container.read(localDemoControllerProvider.notifier).enter(),
      isFalse,
    );
  });

  testWidgets('product-mode local scenario controls render no actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedApp(
          child: Column(
            children: [
              LocalDemoScannerControlsSlot(),
              LocalDemoManagerApprovalAction(locale: 'en'),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('local-demo-scanner-controls')), findsNothing);
    expect(find.byKey(const Key('simulate-valid-qr')), findsNothing);
    expect(find.byKey(const Key('simulate-manager-approved')), findsNothing);
  });

  testWidgets('scenario hub remains usable in Arabic dark mode at 200% text', (
    tester,
  ) async {
    final container = _container(LocalDemoRuntimeDebug(forceAvailable: true));
    addTearDown(container.dispose);
    await container.read(localDemoControllerProvider.notifier).enter();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _LocalizedApp(
          locale: Locale('ar'),
          dark: true,
          media: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: LocalDemoScenariosScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('local-demo-scenario-hub')), findsOneWidget);
    expect(find.text('سيناريوهات العرض'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('exit-local-demo')),
      320,
    );
    await tester.pump();
    expect(find.byKey(const Key('exit-local-demo')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local scanner controls drive the real scanner and customer UI', (
    tester,
  ) async {
    final camera = FixtureCustomerScannerAdapter(
      'waflo-local-demo-customer-credential-v1-opaque-sample',
      autoDeliver: false,
    );
    final runtime = LocalDemoRuntimeDebug(
      forceAvailable: true,
      scannerFactory: () => camera,
    );
    final container = _container(runtime);
    addTearDown(container.dispose);
    await container.read(localDemoControllerProvider.notifier).enter();
    await container
        .read(localDemoControllerProvider.notifier)
        .prepareScenario(LocalDemoScenario.scannerReady, locale: 'en');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _LocalizedApp(child: LoyaltyOperationScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.byKey(const Key('local-demo-scanner-controls')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('simulate-valid-qr')), findsNothing);

    await tester.tap(find.byKey(const Key('local-demo-scanner-controls')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('simulate-valid-qr')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('simulate-valid-qr')),
      240,
    );
    await tester.tap(find.byKey(const Key('simulate-valid-qr')));
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Code detected'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump();
    expect(
      container
          .read(m2OperationControllerProvider)
          .membership
          ?.progress
          .progress,
      5,
    );
    expect(find.text('5 of 8 stamps'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

ProviderContainer _container(LocalDemoRuntime runtime) => ProviderContainer(
  overrides: [
    environmentProvider.overrideWithValue(_environment(AppFlavor.staging)),
    localDemoRuntimeProvider.overrideWithValue(runtime),
    manualCodeIntentResolverProvider.overrideWithValue(
      const DebugManualCodeIntentResolver(configuredCode: 'M3FE-2468'),
    ),
    localDemoScannerControlsBuilderProvider.overrideWithValue(
      () => const DebugLocalDemoScannerControls(),
    ),
    localDemoApprovalControlBuilderProvider.overrideWithValue(
      (locale) => DebugLocalDemoManagerApprovalAction(locale: locale),
    ),
    hapticServiceProvider.overrideWithValue(FakeHapticService()),
  ],
);

AppEnvironment _environment(AppFlavor flavor) => AppEnvironment(
  flavor: flavor,
  apiBaseUrl: Uri.parse(
    flavor == AppFlavor.production
        ? 'https://api.waflo.app'
        : 'https://api-staging.waflo.app',
  ),
  pairingEnvironment: flavor == AppFlavor.production ? 'production' : 'test',
  logLevel: flavor == AppFlavor.production
      ? AppLogLevel.minimal
      : AppLogLevel.info,
  allowTestAdapter: false,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
  localDemoRequested: flavor != AppFlavor.production,
  expectedNativeFlavor: flavor,
  suppliedDartEnvironment: flavor.name,
);

final class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({
    required this.child,
    this.locale = const Locale('en'),
    this.dark = false,
    this.media,
  });

  final Widget child;
  final Locale locale;
  final bool dark;
  final MediaQueryData? media;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: WafloTheme.light(locale: locale),
    darkTheme: WafloTheme.dark(locale: locale),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    builder: media == null
        ? null
        : (context, child) => MediaQuery(data: media!, child: child!),
    home: child,
  );
}
