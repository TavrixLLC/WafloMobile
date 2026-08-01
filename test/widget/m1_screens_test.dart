import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';

import '../support/fixtures.dart';

void main() {
  testWidgets('unpaired welcome is localized in English', (tester) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState.welcome(),
        locale: const Locale('en'),
      ),
    );
    expect(find.text('Pair this staff device'), findsOneWidget);
    expect(find.textContaining('password'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('Arabic welcome uses RTL direction', (tester) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState.welcome(),
        locale: const Locale('ar'),
      ),
    );
    final title = find.text('إقران جهاز الموظف');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
  });

  testWidgets('camera rationale offers continuation and a safe fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.cameraRationale),
      ),
    );
    expect(find.text('Camera access for pairing'), findsOneWidget);
    expect(find.byKey(const Key('request-camera')), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('invalid and expired pairing states are safe and actionable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(
          stage: PairingViewStage.error,
          problem: PairingQrProblem.invalid,
        ),
      ),
    );
    expect(
      find.text('This is not a valid Waflo staff pairing code.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('pairing-error-retry')), findsOneWidget);

    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(
          stage: PairingViewStage.error,
          failure: ApiFailure('DEVICE_PAIRING_EXPIRED'),
        ),
      ),
    );
    expect(find.textContaining('expired'), findsOneWidget);
  });

  testWidgets('pairing progress and success announce safe state', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(
          stage: PairingViewStage.progress,
          progress: PairingProgress.signing,
        ),
      ),
    );
    expect(find.text('Signing the secure challenge'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      _pairingHarness(
        PairingViewState(
          stage: PairingViewStage.success,
          context: fixtureContext(),
        ),
      ),
    );
    expect(find.text('Device paired'), findsOneWidget);
    expect(find.textContaining('Staff'), findsWidgets);
    expect(find.textContaining('assigned location'), findsOneWidget);
  });

  testWidgets('paired shell marks all M2 destinations unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(_homeHarness());
    await tester.pumpAndSettle();
    expect(find.text('Device ready'), findsOneWidget);
    expect(find.text('Scan customer'), findsOneWidget);
    expect(find.text('Recent operations'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Manager approvals'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Manager approvals'), findsOneWidget);
    expect(find.text('Not available in M1'), findsWidgets);
  });

  testWidgets('settings exposes only M1 preferences and safe controls', (
    tester,
  ) async {
    await tester.pumpWidget(_settingsHarness());
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Environment: development'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('sign-out')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('sign-out')), findsOneWidget);
  });

  testWidgets('blocked screens cover all required explicit states', (
    tester,
  ) async {
    final cases = <BootStage, String>{
      BootStage.sessionExpired: 'Session expired',
      BootStage.deviceRevoked: 'Device revoked',
      BootStage.deviceCompromised: 'Device blocked for security',
      BootStage.appUpdateRequired: 'Update required',
      BootStage.backendUnavailable: 'Waflo is unavailable',
    };
    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _localizedHarness(BlockedScreen(state: BootState(stage: entry.key))),
      );
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('large text scale remains renderable', (tester) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState.welcome(),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('scan-pairing-code')), findsOneWidget);
  });

  testWidgets('manual fallback never renders the pairing secret as text', (
    tester,
  ) async {
    const secret =
        'waflo-pair-v1.MDAwMDAwMDAtMDAwMC00MDAwLTgwMDAtMDAwMDAwMDAwMTAw.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA.dGVzdA';
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.manualEntry),
      ),
    );
    await tester.enterText(find.byType(TextField), secret);
    await tester.pump();
    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
    final semanticsHandle = tester.ensureSemantics();
    final semantics = tester.getSemantics(
      find.byKey(const Key('manual-pairing-code')),
    );
    expect(semantics.value, isNot(contains(secret)));
    semanticsHandle.dispose();
  });
}

Widget _pairingHarness(
  PairingViewState state, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    pairingControllerProvider.overrideWithBuild((ref, notifier) => state),
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
  ],
  child: _LocalizedApp(
    locale: locale,
    textScaler: textScaler,
    child: const PairingFlowScreen(),
  ),
);

Widget _homeHarness() => ProviderScope(
  overrides: [
    bootControllerProvider.overrideWithBuild(
      (ref, notifier) => BootState(
        stage: BootStage.pairedReady,
        context: fixtureContext(),
        session: fixtureSession(),
      ),
    ),
    connectivityProvider.overrideWith((ref) => Stream.value(true)),
  ],
  child: const _LocalizedApp(child: HomeScreen()),
);

Widget _settingsHarness() => ProviderScope(
  overrides: [
    localeControllerProvider.overrideWithBuild(
      (ref, notifier) => const Locale('en'),
    ),
    themeControllerProvider.overrideWithBuild(
      (ref, notifier) => ThemeMode.system,
    ),
    environmentProvider.overrideWithValue(
      AppEnvironment(
        flavor: AppFlavor.development,
        apiBaseUrl: Uri.parse('http://10.0.2.2:3000'),
        pairingEnvironment: 'development',
        logLevel: AppLogLevel.debug,
        allowTestAdapter: true,
        minimumVersionSource: 'backend',
        crashReportingEnabled: false,
        certificatePinningEnabled: false,
      ),
    ),
    packageInfoProvider.overrideWith(
      (ref) => PackageInfo(
        appName: 'Waflo Staff',
        packageName: 'app.waflo.staff.dev',
        version: '1.0.0',
        buildNumber: '1',
      ),
    ),
  ],
  child: const _LocalizedApp(child: SettingsScreen()),
);

Widget _localizedHarness(Widget child) =>
    ProviderScope(child: _LocalizedApp(child: child));

final class _LocalizedApp extends StatelessWidget {
  const _LocalizedApp({
    required this.child,
    this.locale = const Locale('en'),
    this.textScaler = TextScaler.noScaling,
  });

  final Widget child;
  final Locale locale;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: WafloTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: child,
    ),
  );
}
