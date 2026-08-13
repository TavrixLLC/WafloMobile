import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/professional_scanner_overlay.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M3E review entry and scanner lifecycle remain explicit', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: _App()));

    // Normal merchant pairing remains the dominant path. Review Access is a
    // deliberate secondary route and never receives a built-in credential.
    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
    expect(find.byKey(const Key('review-access-entry')), findsOneWidget);
    expect(find.byKey(const Key('review-access-code')), findsNothing);
    await tester.tap(find.byKey(const Key('review-access-entry')));
    await tester.pump();
    expect(find.byKey(const Key('review-access-code')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('review-access-continue')))
          .onPressed,
      isNull,
    );

    await tester.enterText(
      find.byKey(const Key('review-access-code')),
      'abcd 2345',
    );
    await tester.pump();
    expect(find.text('ABCD-2345'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('review-access-continue')))
          .onPressed,
      isNotNull,
    );

    // Motion follows real scanner authority: active only while scanning,
    // immediately static after optical detection and during server resolve.
    await tester.pumpWidget(
      const _App(
        child: ProfessionalScannerOverlay(
          state: CustomerScannerState.scanning,
          semanticLabel: 'Customer QR target',
        ),
      ),
    );
    expect(find.byKey(const Key('scanner-beam-animated')), findsOneWidget);
    await tester.pumpWidget(
      const _App(
        child: ProfessionalScannerOverlay(
          state: CustomerScannerState.candidateCaptured,
          semanticLabel: 'Customer QR target',
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('scanner-beam-static')), findsOneWidget);
    await tester.pumpWidget(
      const _App(
        child: ProfessionalScannerOverlay(
          state: CustomerScannerState.resolving,
          semanticLabel: 'Customer QR target',
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('scanner-beam-static')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _App extends StatelessWidget {
  const _App({this.child = const PairingFlowScreen()});

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
    home: Scaffold(body: child),
  );
}
