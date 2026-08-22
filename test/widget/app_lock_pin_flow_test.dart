import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/app_lock/data/app_lock_repository.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryAppLockStore repository;

  setUp(() {
    repository = _MemoryAppLockStore();
  });

  testWidgets('PIN creation confirms and retries on the same custom keypad', (
    tester,
  ) async {
    _configureMobileView(tester);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                key: const Key('open-pin-setup'),
                onPressed: () => context.push('/app-lock/pin'),
                child: const Text('Open PIN setup'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/app-lock/pin',
          builder: (context, state) => const PinSetupScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_routerHarness(router, repository));
    await tester.tap(find.byKey(const Key('open-pin-setup')));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(find.text('New PIN'), findsOneWidget);
    expect(find.byKey(const Key('pin-setup-keypad')), findsOneWidget);

    await _enterPin(tester, '4826');
    await tester.tap(find.byKey(const Key('pin-setup-continue')));
    await tester.pumpAndSettle();

    expect(find.byType(PinSetupScreen), findsOneWidget);
    expect(find.text('Confirm PIN'), findsOneWidget);
    expect(find.byKey(const Key('pin-setup-keypad')), findsOneWidget);

    await _enterPin(tester, '4827');
    await tester.tap(find.byKey(const Key('pin-setup-save')));
    await tester.pumpAndSettle();

    expect(find.text('The PIN entries do not match.'), findsOneWidget);
    expect(find.text('Confirm PIN'), findsOneWidget);
    expect(await repository.hasPin(), isFalse);

    await _enterPin(tester, '4826');
    await tester.tap(find.byKey(const Key('pin-setup-save')));
    for (
      var attempt = 0;
      attempt < 40 && !await repository.hasPin();
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('open-pin-setup')), findsOneWidget);
    expect(await repository.verifyPin('4826'), isTrue);
    expect(find.byType(EditableText), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('PIN unlock uses only the in-app keypad', (tester) async {
    _configureMobileView(tester);
    await repository.setPin('4826');
    await repository.setConfiguration(
      const AppLockConfiguration(mode: AppLockMode.pin),
    );
    final container = ProviderContainer(
      overrides: [
        appLockRepositoryProvider.overrideWithValue(repository),
        localDemoControllerProvider.overrideWithBuild(
          (ref, notifier) =>
              const LocalDemoState(status: LocalDemoStatus.active),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _app(const AppLockOverlay()),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    await _enterPin(tester, '4826');
    await tester.tap(find.byKey(const Key('unlock-with-pin')));
    for (
      var attempt = 0;
      attempt < 40 &&
          container.read(appLockControllerProvider).status !=
              AppLockStatus.unlocked;
      attempt++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      container.read(appLockControllerProvider).status,
      AppLockStatus.unlocked,
    );
    expect(find.byType(EditableText), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
  });
}

void _configureMobileView(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.characters) {
    await tester.tap(find.byKey(Key('pin-key-$digit')));
    await tester.pump();
  }
}

Widget _routerHarness(GoRouter router, AppLockStore repository) =>
    ProviderScope(
      overrides: [appLockRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: WafloTheme.light(),
      ),
    );

Widget _app(Widget child) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: const Locale('en'),
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

final class _MemoryAppLockStore implements AppLockStore {
  AppLockConfiguration configuration = const AppLockConfiguration();
  String? pin;
  PinRateLimit rateLimit = const PinRateLimit(failures: 0);

  @override
  Future<void> clearPin() async => pin = null;

  @override
  Future<void> clearRateLimit() async {
    rateLimit = const PinRateLimit(failures: 0);
  }

  @override
  Future<bool> hasPin() async => pin != null;

  @override
  AppLockConfiguration readConfiguration() => configuration;

  @override
  Future<PinRateLimit> readRateLimit() async => rateLimit;

  @override
  Future<PinRateLimit> registerFailure(DateTime now) async {
    rateLimit = PinRateLimit(failures: rateLimit.failures + 1);
    return rateLimit;
  }

  @override
  Future<void> setConfiguration(AppLockConfiguration configuration) async {
    this.configuration = configuration;
  }

  @override
  Future<void> setPin(String pin) async => this.pin = pin;

  @override
  Future<bool> verifyPin(String pin) async => this.pin == pin;
}
