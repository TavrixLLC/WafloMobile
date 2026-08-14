import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/customer_scan/presentation/professional_scanner_overlay.dart';
import 'package:waflo_staff/features/device_session/domain/staff_device_session.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('manual code entry is hidden behind the normal scanner path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _LocalizedApp(child: PairingFlowScreen())),
    );

    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Review'), findsNothing);

    await tester.tap(find.byKey(const Key('scan-pairing-code')));
    await tester.pump();
    await tester.tap(find.text('Not now'));
    await tester.pump();
    expect(find.byKey(const Key('manual-code-input')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('manual-code-input')),
      'abcd 2345',
    );
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('manual-code-input')))
          .controller
          ?.text,
      'ABCD-2345',
    );
  });

  testWidgets('manual code preserves RTL shell and LTR credential entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizedApp(locale: Locale('ar'), child: PairingFlowScreen()),
      ),
    );
    await tester.tap(find.byKey(const Key('scan-pairing-code')));
    await tester.pump();
    await tester.tap(find.text('ليس الآن'));
    await tester.pump();

    expect(
      Directionality.of(tester.element(find.byType(WafloPage))),
      TextDirection.rtl,
    );
    final field = find.byKey(const Key('manual-code-input'));
    final localDirectionality = find.ancestor(
      of: field,
      matching: find.byType(Directionality),
    );
    expect(
      tester.widget<Directionality>(localDirectionality.first).textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('demo indicator appears only for a typed review session', (
    tester,
  ) async {
    await tester.pumpWidget(_home(StaffSessionMode.normal));
    expect(find.text('Demo mode'), findsNothing);

    await tester.pumpWidget(_home(StaffSessionMode.review));
    await tester.pump();
    expect(find.text('Demo mode'), findsOneWidget);
  });

  testWidgets('scanner beam runs only while camera is actively scanning', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _LocalizedApp(
        child: SizedBox.expand(
          child: ProfessionalScannerOverlay(
            state: CustomerScannerState.scanning,
            semanticLabel: 'Customer QR target',
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('scanner-beam-animated')), findsOneWidget);

    await tester.pumpWidget(
      const _LocalizedApp(
        child: SizedBox.expand(
          child: ProfessionalScannerOverlay(
            state: CustomerScannerState.resolving,
            semanticLabel: 'Customer QR target',
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('scanner-beam-static')), findsOneWidget);
  });

  testWidgets('Reduce Motion keeps a static, semantic scan target', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _LocalizedApp(
        media: MediaQueryData(
          disableAnimations: true,
          textScaler: TextScaler.linear(2),
        ),
        child: SizedBox.expand(
          child: ProfessionalScannerOverlay(
            state: CustomerScannerState.scanning,
            semanticLabel: '5 of 8 customer QR target',
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('scanner-beam-static')), findsOneWidget);
    expect(find.bySemanticsLabel('5 of 8 customer QR target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'network failure after detection keeps the scanner and explicit retry',
    (tester) async {
      final scanner = FixtureCustomerScannerAdapter(
        'not-a-real-qr',
        autoDeliver: false,
      );
      addTearDown(scanner.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bootControllerProvider.overrideWithBuild(
              (ref, notifier) => BootState(
                stage: BootStage.pairedReady,
                context: fixtureContext(),
                session: fixtureSession(),
              ),
            ),
            m2OperationControllerProvider.overrideWithBuild(
              (ref, notifier) => const M2OperationState(
                stage: M2OperationStage.networkUnavailable,
                failure: NetworkFailure(),
              ),
            ),
            customerScannerAdapterProvider.overrideWithValue(scanner),
            connectivityProvider.overrideWithValue(const AsyncData(true)),
          ],
          child: const _LocalizedApp(child: LoyaltyOperationScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(ProfessionalScannerOverlay), findsOneWidget);
      expect(find.byKey(const Key('scanner-resolve-retry')), findsOneWidget);
      expect(scanner.state.value, CustomerScannerState.networkFailure);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'fixture scanner blocks foreground replay and tracks torch state',
    () async {
      final scanner = FixtureCustomerScannerAdapter('not-a-real-qr');
      await scanner.start();
      expect(scanner.state.value, CustomerScannerState.ready);
      await scanner.toggleTorch();
      expect(scanner.torchEnabled.value, isTrue);
      scanner.reportResolveFailure(CustomerScannerState.invalidQr);
      expect(scanner.state.value, CustomerScannerState.invalidQr);
      await scanner.resetForExplicitRetry();
      expect(scanner.state.value, CustomerScannerState.ready);
      await scanner.background();
      expect(scanner.state.value, CustomerScannerState.backgrounded);
      scanner.delivered = true;
      await scanner.foreground();
      expect(scanner.state.value, CustomerScannerState.backgrounded);
      await scanner.dispose();
    },
  );
}

Widget _home(StaffSessionMode mode) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => BootState(
        stage: BootStage.pairedReady,
        context: fixtureContext(),
        session: fixtureSession(sessionMode: mode),
      ),
    ),
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
    connectivityProvider.overrideWithValue(const AsyncData(true)),
  ],
  child: const _LocalizedApp(child: HomeScreen()),
);

final class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({
    required this.child,
    this.locale = const Locale('en'),
    this.media,
  });

  final Widget child;
  final Locale locale;
  final MediaQueryData? media;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
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
      builder: media == null
          ? null
          : (context, child) => MediaQuery(data: media!, child: child!),
      home: Scaffold(body: child),
    );
    return app;
  }
}
