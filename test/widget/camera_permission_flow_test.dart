import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/core/permissions/camera_permission.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';

void main() {
  testWidgets('pairing scan tap requests once and continues when granted', (
    tester,
  ) async {
    final gateway = _FakeCameraPermissionGateway(
      current: CameraPermissionAccess.denied,
      requestResult: CameraPermissionAccess.granted,
    );
    final scanner = _FakePairingScannerAdapter();

    await tester.pumpWidget(
      _harness(
        permissionGateway: gateway,
        scanner: scanner,
        state: const PairingViewState.welcome(),
      ),
    );
    await tester.tap(find.byKey(const Key('scan-pairing-code')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(gateway.requestCalls, 1);
    expect(scanner.startCalls, 1);
    expect(find.byKey(const Key('fake-pairing-scanner')), findsOneWidget);

    await tester.pump();
    expect(gateway.requestCalls, 1, reason: 'a rebuild must not re-prompt');
  });

  testWidgets('denied pairing access shows a localized explanation and retry', (
    tester,
  ) async {
    final gateway = _FakeCameraPermissionGateway(
      current: CameraPermissionAccess.denied,
      requestResult: CameraPermissionAccess.denied,
    );

    await tester.pumpWidget(
      _harness(
        permissionGateway: gateway,
        scanner: _FakePairingScannerAdapter(),
        state: const PairingViewState.welcome(),
      ),
    );
    await tester.tap(find.byKey(const Key('scan-pairing-code')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('pairing and customer QR codes'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('request-camera')), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets(
    'permanent denial opens Settings and resumes scanner after access changes',
    (tester) async {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.permanentlyDenied,
      );
      final scanner = _FakePairingScannerAdapter();

      await tester.pumpWidget(
        _harness(
          permissionGateway: gateway,
          scanner: scanner,
          state: const PairingViewState(
            stage: PairingViewStage.cameraRationale,
            cameraPermission: CameraPermissionAccess.permanentlyDenied,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('camera-permission-settings-dialog')),
        findsOneWidget,
      );
      expect(find.text('Camera access is blocked'), findsOneWidget);
      await tester.tap(find.byKey(const Key('open-camera-settings')));
      await tester.pumpAndSettle();
      expect(gateway.openSettingsCalls, 1);

      gateway.current = CameraPermissionAccess.granted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(scanner.startCalls, 1);
      expect(gateway.requestCalls, 0);
      expect(find.byKey(const Key('fake-pairing-scanner')), findsOneWidget);
    },
  );

  testWidgets('camera permission dialog follows LTR and RTL locales', (
    tester,
  ) async {
    for (final locale in WafloLocales.selectable) {
      final gateway = _FakeCameraPermissionGateway(
        current: CameraPermissionAccess.permanentlyDenied,
      );
      await tester.pumpWidget(
        _harness(
          permissionGateway: gateway,
          scanner: _FakePairingScannerAdapter(),
          locale: locale,
          state: const PairingViewState(
            stage: PairingViewStage.cameraRationale,
            cameraPermission: CameraPermissionAccess.permanentlyDenied,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dialog = find.byKey(const Key('camera-permission-settings-dialog'));
      expect(dialog, findsOneWidget);
      expect(
        Directionality.of(tester.element(dialog)),
        WafloLocales.usesArabicScript(locale)
            ? TextDirection.rtl
            : TextDirection.ltr,
        reason: locale.toLanguageTag(),
      );
      await tester.tap(find.text(_notNowLabel(locale)));
      await tester.pumpAndSettle();
    }
  });
}

Widget _harness({
  required CameraPermissionGateway permissionGateway,
  required PairingScannerAdapter scanner,
  required PairingViewState state,
  Locale locale = WafloLocales.english,
}) => ProviderScope(
  key: UniqueKey(),
  overrides: [
    cameraPermissionCoordinatorProvider.overrideWithValue(
      CameraPermissionCoordinator(permissionGateway),
    ),
    pairingControllerProvider.overrideWithBuild((ref, notifier) => state),
    pairingScannerAdapterProvider.overrideWithValue(scanner),
  ],
  child: MaterialApp(
    locale: locale,
    supportedLocales: WafloLocales.selectable,
    localizationsDelegates: wafloLocalizationDelegates,
    theme: WafloTheme.light(locale: locale),
    home: const PairingFlowScreen(),
  ),
);

String _notNowLabel(Locale locale) => switch (locale.languageCode) {
  'ar' => 'ليس الآن',
  'ckb' => 'ئێستا نا',
  'ku' => 'نە نوکە',
  _ => 'Not now',
};

final class _FakeCameraPermissionGateway implements CameraPermissionGateway {
  _FakeCameraPermissionGateway({
    required this.current,
    this.requestResult = CameraPermissionAccess.denied,
  });

  CameraPermissionAccess current;
  final CameraPermissionAccess requestResult;
  int requestCalls = 0;
  int openSettingsCalls = 0;

  @override
  Future<CameraPermissionAccess> status() async => current;

  @override
  Future<CameraPermissionAccess> request() async {
    requestCalls += 1;
    current = requestResult;
    return current;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCalls += 1;
    return true;
  }
}

final class _FakePairingScannerAdapter implements PairingScannerAdapter {
  final ValueNotifier<CustomerScannerState> _state = ValueNotifier(
    CustomerScannerState.idle,
  );
  final ValueNotifier<bool> _torch = ValueNotifier(false);
  int startCalls = 0;

  @override
  ValueListenable<CustomerScannerState> get state => _state;

  @override
  ValueListenable<bool> get torchEnabled => _torch;

  @override
  Widget buildPreview(
    BuildContext context, {
    required Future<void> Function(String value) onDetected,
  }) => const ColoredBox(key: Key('fake-pairing-scanner'), color: Colors.black);

  @override
  Future<void> start() async {
    startCalls += 1;
    _state.value = CustomerScannerState.ready;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> toggleTorch() async {
    _torch.value = !_torch.value;
  }

  @override
  Future<void> dispose() async {}
}
