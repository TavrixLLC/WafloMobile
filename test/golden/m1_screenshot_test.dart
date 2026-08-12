import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';
import 'package:waflo_staff/features/stamp_operation/presentation/m2_operation_controller.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('WafloSans')
          ..addFont(rootBundle.load('assets/brand/fonts/Manrope-Regular.ttf')))
        .load();
    await (FontLoader('WafloArabic')..addFont(
          rootBundle.load('assets/brand/fonts/NotoSansArabic-Regular.ttf'),
        ))
        .load();
  });

  Future<void> capture(
    WidgetTester tester,
    String name,
    Widget widget, {
    bool compareOnLinux = true,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    if (Platform.isLinux && !compareOnLinux) {
      expect(tester.takeException(), isNull);
    } else {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          Platform.isLinux ? 'goldens/linux/$name.png' : 'goldens/$name.png',
        ),
      );
    }
  }

  testWidgets('English unpaired welcome evidence', (tester) async {
    await capture(
      tester,
      '01-welcome-en',
      _pairing(PairingViewState.welcome()),
    );
  });

  testWidgets('Arabic unpaired welcome evidence', (tester) async {
    await capture(
      tester,
      '02-welcome-ar-rtl',
      _pairing(const PairingViewState.welcome(), locale: const Locale('ar')),
    );
  });

  testWidgets('camera rationale evidence', (tester) async {
    await capture(
      tester,
      '03-camera-rationale',
      _pairing(const PairingViewState(stage: PairingViewStage.cameraRationale)),
    );
  });

  testWidgets('pairing scanner evidence', (tester) async {
    await capture(
      tester,
      '04-pairing-scanner',
      ProviderScope(
        overrides: [
          pairingScannerAdapterProvider.overrideWithValue(
            const _GoldenScannerAdapter(),
          ),
        ],
        child: _app(child: const PairingScannerScreen()),
      ),
    );
  });

  testWidgets('invalid pairing QR evidence', (tester) async {
    await capture(
      tester,
      '05-invalid-pairing',
      _pairing(
        const PairingViewState(
          stage: PairingViewStage.error,
          problem: PairingQrProblem.invalid,
        ),
      ),
    );
  });

  testWidgets('expired pairing QR evidence', (tester) async {
    await capture(
      tester,
      '06-expired-pairing',
      _pairing(
        const PairingViewState(
          stage: PairingViewStage.error,
          failure: ApiFailure('DEVICE_PAIRING_EXPIRED'),
        ),
      ),
    );
  });

  testWidgets('pairing progress evidence', (tester) async {
    await capture(
      tester,
      '07-pairing-progress',
      _pairing(
        const PairingViewState(
          stage: PairingViewStage.progress,
          progress: PairingProgress.completing,
        ),
      ),
    );
  });

  testWidgets('pairing success evidence', (tester) async {
    await capture(
      tester,
      '08-pairing-success',
      _pairing(
        PairingViewState(
          stage: PairingViewStage.success,
          context: fixtureContext(),
        ),
      ),
    );
  });

  testWidgets('paired home evidence', (tester) async {
    await capture(tester, '09-paired-home', _home(), compareOnLinux: false);
  });

  testWidgets('assigned locations evidence', (tester) async {
    await capture(
      tester,
      '10-assigned-locations',
      _home(locale: const Locale('ar')),
      compareOnLinux: false,
    );
  });

  testWidgets('settings English evidence', (tester) async {
    await capture(tester, '11-settings-en', _settings());
  });

  testWidgets('settings Arabic evidence', (tester) async {
    await capture(
      tester,
      '12-settings-ar-rtl',
      _settings(locale: const Locale('ar')),
    );
  });

  testWidgets('offline state evidence', (tester) async {
    await capture(
      tester,
      '13-offline',
      _home(online: false),
      compareOnLinux: false,
    );
  });

  testWidgets('session expired evidence', (tester) async {
    await capture(
      tester,
      '14-session-expired',
      _blocked(BootStage.sessionExpired),
    );
  });

  testWidgets('device revoked evidence', (tester) async {
    await capture(
      tester,
      '15-device-revoked',
      _blocked(BootStage.deviceRevoked),
    );
  });

  testWidgets('device compromised evidence', (tester) async {
    await capture(
      tester,
      '16-device-compromised',
      _blocked(BootStage.deviceCompromised),
    );
  });

  testWidgets('update required evidence', (tester) async {
    await capture(
      tester,
      '17-update-required',
      _blocked(BootStage.appUpdateRequired),
    );
  });

  testWidgets('dynamic text scaling evidence', (tester) async {
    await capture(
      tester,
      '18-dynamic-text',
      _pairing(
        const PairingViewState.welcome(),
        textScaler: const TextScaler.linear(1.8),
      ),
    );
  });

  testWidgets('dark theme evidence', (tester) async {
    await capture(
      tester,
      '19-dark-theme',
      _pairing(const PairingViewState.welcome(), brightness: Brightness.dark),
    );
  });

  testWidgets('semantics evidence', (tester) async {
    await capture(
      tester,
      '20-accessibility-semantics',
      _pairing(const PairingViewState.welcome(), showSemanticsDebugger: true),
    );
  });
}

Widget _pairing(
  PairingViewState state, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
  Brightness brightness = Brightness.light,
  bool showSemanticsDebugger = false,
}) => ProviderScope(
  overrides: [
    pairingControllerProvider.overrideWithBuild((ref, notifier) => state),
    localeControllerProvider.overrideWithBuild((ref, notifier) => locale),
  ],
  child: _app(
    locale: locale,
    textScaler: textScaler,
    brightness: brightness,
    showSemanticsDebugger: showSemanticsDebugger,
    child: const PairingFlowScreen(),
  ),
);

Widget _home({bool online = true, Locale locale = const Locale('en')}) =>
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
          (ref, notifier) => const M2OperationState.idle(),
        ),
        connectivityProvider.overrideWith((ref) => Stream.value(online)),
      ],
      child: _app(locale: locale, child: const HomeScreen()),
    );

Widget _settings({Locale locale = const Locale('en')}) => ProviderScope(
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
  child: _app(locale: locale, child: const SettingsScreen()),
);

Widget _blocked(BootStage stage) => ProviderScope(
  child: _app(
    child: BlockedScreen(state: BootState(stage: stage)),
  ),
);

Widget _app({
  required Widget child,
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
  Brightness brightness = Brightness.light,
  bool showSemanticsDebugger = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  theme: WafloTheme.light(),
  darkTheme: WafloTheme.dark(),
  themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  showSemanticsDebugger: showSemanticsDebugger,
  home: MediaQuery(
    data: MediaQueryData(textScaler: textScaler),
    child: child,
  ),
);

final class _SafeScannerPreview extends StatelessWidget {
  const _SafeScannerPreview();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF10231B),
    child: Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.qr_code_scanner, size: 64, color: Colors.white),
      ),
    ),
  );
}

final class _GoldenScannerAdapter implements PairingScannerAdapter {
  const _GoldenScannerAdapter();

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => const _SafeScannerPreview();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> toggleTorch() async {}
}
