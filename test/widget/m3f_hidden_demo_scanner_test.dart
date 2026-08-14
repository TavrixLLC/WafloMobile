import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/customer_scanner_adapter.dart';
import 'package:waflo_staff/features/customer_scan/presentation/professional_scanner_overlay.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('public pairing surface has no visible Demo or Review entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: _LocalizedApp(child: PairingFlowScreen())),
    );

    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
    expect(find.textContaining('Review'), findsNothing);
    expect(find.byKey(const Key('review-access-entry')), findsNothing);
  });

  testWidgets('normal pairing scanner uses the canonical animated scanner', (
    tester,
  ) async {
    final adapter = _PairingFixtureAdapter();
    addTearDown(adapter.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pairingControllerProvider.overrideWithBuild(
            (ref, notifier) =>
                const PairingViewState(stage: PairingViewStage.scanner),
          ),
          pairingScannerAdapterProvider.overrideWithValue(adapter),
        ],
        child: const _LocalizedApp(child: PairingFlowScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(ProfessionalScannerOverlay), findsOneWidget);
    expect(find.byKey(const Key('scanner-beam-animated')), findsOneWidget);
    expect(find.byType(WafloScannerStatusPill), findsOneWidget);
    expect(find.byKey(const Key('manual-code-entry')), findsOneWidget);
    expect(find.textContaining('Demo'), findsNothing);
  });

  testWidgets('normal and local Demo customer scanners share presentation', (
    tester,
  ) async {
    Future<List<Type>> render({required bool demo}) async {
      final scanner = FixtureCustomerScannerAdapter(
        'opaque-fixture',
        autoDeliver: false,
        initialState: CustomerScannerState.ready,
      );
      addTearDown(scanner.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerScannerAdapterProvider.overrideWithValue(scanner),
            activeDeviceContextProvider.overrideWithValue(fixtureContext()),
            operationalOnlineProvider.overrideWithValue(true),
            localDemoControllerProvider.overrideWithBuild(
              (ref, notifier) => demo
                  ? const LocalDemoState(status: LocalDemoStatus.active)
                  : const LocalDemoState(),
            ),
            m2OperationControllerProvider.overrideWithBuild(
              (ref, notifier) =>
                  const M2OperationState(stage: M2OperationStage.scanning),
            ),
          ],
          child: const _LocalizedApp(child: LoyaltyOperationScreen()),
        ),
      );
      await tester.pump();
      return [
        tester.widget(find.byType(ProfessionalScannerOverlay)).runtimeType,
        tester.widget(find.byType(WafloScannerStatusPill)).runtimeType,
        tester
            .widget(find.byKey(const Key('scanner-beam-animated')))
            .runtimeType,
      ];
    }

    final normal = await render(demo: false);
    final demo = await render(demo: true);
    expect(demo, normal);
  });

  testWidgets('canonical scanner honors Reduce Motion', (tester) async {
    await tester.pumpWidget(
      const _LocalizedApp(
        media: MediaQueryData(disableAnimations: true),
        child: SizedBox.expand(
          child: ProfessionalScannerOverlay(
            state: CustomerScannerState.ready,
            semanticLabel: 'Scan target',
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('scanner-beam-static')), findsOneWidget);
  });
}

final class _PairingFixtureAdapter implements PairingScannerAdapter {
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.ready,
  );
  final ValueNotifier<bool> _torch = ValueNotifier(false);

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torch;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => const ColoredBox(color: Color(0xFF10231B));

  @override
  Future<void> start() async => _state.value = CustomerScannerState.ready;

  @override
  Future<void> stop() async {}

  @override
  Future<void> toggleTorch() async => _torch.value = !_torch.value;

  @override
  Future<void> dispose() async {
    _state.dispose();
    _torch.dispose();
  }
}

final class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({required this.child, this.media});

  final Widget child;
  final MediaQueryData? media;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: WafloTheme.light(locale: const Locale('en')),
    builder: media == null
        ? null
        : (context, child) => MediaQuery(data: media!, child: child!),
    home: child,
  );
}
