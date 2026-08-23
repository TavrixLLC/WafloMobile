import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/haptics/haptic_service.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/storage/secure_store.dart';
import 'package:waflo_staff/features/local_demo/data/local_demo_runtime_debug.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_operation_controls_debug.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/reward_redemption/domain/manager_approval.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LOCAL_DEMO completes the physical owner loyalty path offline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final runtime = LocalDemoRuntimeDebug(forceAvailable: true);
    final container = ProviderContainer(
      overrides: [
        environmentProvider.overrideWithValue(_environment),
        sharedPreferencesProvider.overrideWithValue(preferences),
        localDemoRuntimeProvider.overrideWithValue(runtime),
        localDemoScannerControlsBuilderProvider.overrideWithValue(
          () => const DebugLocalDemoScannerControls(),
        ),
        localDemoApprovalControlBuilderProvider.overrideWithValue(
          (locale) => DebugLocalDemoManagerApprovalAction(locale: locale),
        ),
        secureStoreProvider.overrideWithValue(MemorySecureKeyValueStore()),
        hapticServiceProvider.overrideWithValue(FakeHapticService()),
      ],
    );
    addTearDown(container.dispose);
    final demo = container.read(localDemoControllerProvider.notifier);

    final grant = await container
        .read(localReviewAccessProvider)
        .authorize(_reviewCode());
    expect(await demo.enterAuthorized(grant), isTrue);
    expect(await container.read(sessionRepositoryProvider).read(), isNull);

    await demo.prepareScenario(
      LocalDemoScenario.customerFiveOfEight,
      locale: 'en',
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _App(child: LoyaltyOperationScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('5 of 8 stamps'), findsWidgets);

    await demo.prepareScenario(LocalDemoScenario.stampSuccess, locale: 'en');
    await tester.pump();
    expect(find.byKey(const Key('scan-next-customer')), findsOneWidget);
    expect(
      container
          .read(m2OperationControllerProvider)
          .stampResult
          ?.progress
          .progress,
      6,
    );

    await demo.prepareScenario(
      LocalDemoScenario.managerApprovalPending,
      locale: 'en',
    );
    await tester.pump();
    expect(
      container.read(m2OperationControllerProvider).managerApprovalState,
      ManagerApprovalState.pending,
    );
    expect(find.byKey(const Key('simulate-manager-approved')), findsOneWidget);

    await demo.simulateManagerApproved(locale: 'en');
    await tester.pump();
    final result = container
        .read(m2OperationControllerProvider)
        .redemptionResult;
    expect(result?.progress.progress, 0);
    expect(result?.rewardReady, isFalse);
    expect(result?.progress.slots, everyElement(StampSlotState.empty));

    await demo.exit();
    expect(container.read(localDemoControllerProvider).active, isFalse);
    expect(await container.read(sessionRepositoryProvider).read(), isNull);
  });
}

final class _App extends StatelessWidget {
  const _App({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: WafloTheme.light(),
    home: child,
  );
}

final _environment = AppEnvironment(
  flavor: AppFlavor.staging,
  apiBaseUrl: Uri.parse('https://api-staging.waflo.app'),
  pairingEnvironment: 'test',
  logLevel: AppLogLevel.info,
  allowTestAdapter: false,
  minimumVersionSource: 'backend',
  crashReportingEnabled: false,
  certificatePinningEnabled: false,
  localDemoRequested: true,
  expectedNativeFlavor: AppFlavor.staging,
  suppliedDartEnvironment: 'staging',
);

String _reviewCode() => String.fromCharCodes(const [
  87,
  52,
  70,
  76,
  45,
  55,
  82,
  86,
  87,
  45,
  57,
  75,
  81,
  80,
]);
