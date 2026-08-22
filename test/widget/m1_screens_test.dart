import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:waflo_staff/app/environment.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

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

  testWidgets(
    'pairing keeps language choice compact and groups sheet options',
    (tester) async {
      await tester.pumpWidget(
        _pairingHarness(
          const PairingViewState.welcome(),
          locale: WafloLocales.english,
        ),
      );
      await tester.pumpAndSettle();

      const controlKey = Key('pairing-language-control');
      expect(find.byKey(controlKey), findsOneWidget);
      expect(find.byKey(const Key('pairing-language-en')), findsNothing);
      expect(find.byKey(const Key('language-en')), findsNothing);
      expect(
        tester.getTopLeft(find.byKey(const Key('scan-pairing-code'))).dy,
        lessThan(tester.getTopLeft(find.byKey(controlKey)).dy),
      );

      await tester.tap(find.byKey(controlKey));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pairing-language-en')), findsOneWidget);
      expect(find.byKey(const Key('pairing-language-ar')), findsOneWidget);
      expect(
        find.byKey(const Key('pairing-language-ku-Arab-IQ')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('pairing-language-ckb')), findsOneWidget);
      expect(
        find.byKey(const Key('pairing-language-kurdish-label')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Badini and Sorani render in RTL with grouped language options', (
    tester,
  ) async {
    final cases = <Locale, String>{
      WafloLocales.badini: 'ڤی ئامێرێ ستافی جوت بکە',
      WafloLocales.sorani: 'ئەم ئامێری ستافە جوت بکەوە',
    };
    for (final entry in cases.entries) {
      await tester.pumpWidget(
        _pairingHarness(
          const PairingViewState.welcome(),
          locale: entry.key,
          textScaler: const TextScaler.linear(1.3),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Directionality.of(
          tester.element(find.byKey(const Key('pairing-language-control'))),
        ),
        TextDirection.rtl,
      );
      expect(find.byKey(const Key('pairing-language-en')), findsNothing);
      await tester.tap(find.byKey(const Key('pairing-language-control')));
      await tester.pumpAndSettle();
      final title = find.text(entry.value);
      expect(title, findsOneWidget);
      expect(Directionality.of(tester.element(title)), TextDirection.rtl);
      expect(find.text('کوردی'), findsOneWidget);
      expect(find.text('بادینی'), findsOneWidget);
      expect(find.text('سۆرانی'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
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

  testWidgets('pairing INTERNAL_ERROR is a safe failure, never success', (
    tester,
  ) async {
    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(
          stage: PairingViewStage.error,
          failure: ApiFailure('INTERNAL_ERROR', httpStatus: 500),
        ),
      ),
    );
    expect(
      find.textContaining('could not be completed safely'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('pairing-error-retry')), findsOneWidget);
    expect(find.text('Device paired'), findsNothing);
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
    expect(find.text('Fixture Coffee'), findsOneWidget);
    expect(find.text('Main branch'), findsOneWidget);
    expect(find.textContaining('00000000-'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('pairing-confirmation-card'))).height,
      lessThan(110),
    );
  });

  testWidgets('directional icons rely on native RTL mirroring', (tester) async {
    expect(Icons.arrow_back_rounded.matchTextDirection, isTrue);
    expect(Icons.chevron_right_rounded.matchTextDirection, isTrue);

    await tester.pumpWidget(
      _pairingHarness(
        const PairingViewState(stage: PairingViewStage.manualEntry),
        locale: WafloLocales.sorani,
      ),
    );
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    final back = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
    expect(back.icon, Icons.arrow_back_rounded);
    expect(
      Directionality.of(tester.element(find.byIcon(Icons.arrow_back_rounded))),
      TextDirection.rtl,
    );

    await tester.pumpWidget(_settingsHarness(locale: const Locale('ar')));
    await tester.pumpAndSettle();
    final forward = find.byType(WafloForwardChevron).first;
    final icon = tester.widget<Icon>(
      find.descendant(of: forward, matching: find.byType(Icon)),
    );
    expect(icon.icon, Icons.chevron_right_rounded);
    expect(Directionality.of(tester.element(forward)), TextDirection.rtl);
  });

  testWidgets('paired M1 shell remains intact while M2 scan is activated', (
    tester,
  ) async {
    await tester.pumpWidget(_homeHarness());
    await tester.pumpAndSettle();
    expect(find.text('Device ready'), findsOneWidget);
    expect(find.text('Fixture Coffee'), findsOneWidget);
    expect(find.textContaining('Main branch'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Scan customer'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Scan customer'), findsOneWidget);
    expect(find.text('Device & Security'), findsOneWidget);
    expect(find.text('Recent operations'), findsNothing);
    expect(find.text('Manager approvals'), findsNothing);
  });

  testWidgets('settings remains minimal and exposes safe preferences', (
    tester,
  ) async {
    await tester.pumpWidget(_settingsHarness());
    await tester.pumpAndSettle();
    expect(find.text('APPEARANCE & LANGUAGE'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.byKey(const Key('language-select-en')), findsOneWidget);
    expect(find.byKey(const Key('theme-select-system')), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-select-en')));
    await tester.pumpAndSettle();
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('کوردی'), findsOneWidget);
    expect(find.text('بادینی'), findsOneWidget);
    expect(find.text('سۆرانی'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('theme-select-system')));
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Device & Security'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rapid scan mode'), findsOneWidget);
    expect(find.text('Device & Security'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('APP INFORMATION'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('development'), findsOneWidget);
    expect(find.byKey(const Key('sign-out')), findsNothing);
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
      find.byKey(const Key('manual-code-input')),
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
    m2OperationControllerProvider.overrideWithBuild(
      (ref, notifier) => const M2OperationState.idle(),
    ),
  ],
  child: const _LocalizedApp(child: HomeScreen()),
);

Widget _settingsHarness({Locale locale = const Locale('en')}) => ProviderScope(
  overrides: [
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
    themeControllerProvider.overrideWithBuild(
      (ref, notifier) => ThemeMode.system,
    ),
    rapidScanControllerProvider.overrideWithBuild((ref, notifier) => true),
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
  child: _LocalizedApp(locale: locale, child: const SettingsScreen()),
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
    supportedLocales: WafloLocales.selectable,
    localizationsDelegates: wafloLocalizationDelegates,
    theme: WafloTheme.light(locale: locale),
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: child,
    ),
  );
}
