import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/boot/presentation/boot_gate.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_routes_debug.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';

/// Local Review routes are registered in every Store build, but redirect back
/// to the pairing gate unless a locally authorized Review mode is active.
final localDemoRoutesProvider = Provider<List<RouteBase>>(
  (ref) => buildLocalDemoRoutes(),
);

final routerProvider = Provider<GoRouter>((ref) {
  final ready = ref.watch(
    bootControllerProvider.select(
      (state) => state.stage == BootStage.pairedReady,
    ),
  );
  final localDemoActive = ref.watch(
    localDemoControllerProvider.select((state) => state.active),
  );
  final localDemoAvailable = ref.watch(localDemoAccessAvailableProvider);
  final operationalReady = ready || localDemoActive;
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const BootGate()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/loyalty',
        builder: (context, state) => const LoyaltyOperationScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/device-security',
        builder: (context, state) => const DeviceSecurityScreen(),
      ),
      GoRoute(
        path: '/app-lock',
        builder: (context, state) => const AppLockSettingsScreen(),
      ),
      GoRoute(
        path: '/app-lock/pin',
        builder: (context, state) => const PinSetupScreen(),
      ),
      if (localDemoAvailable) ...ref.watch(localDemoRoutesProvider),
    ],
    redirect: (context, state) {
      final protected = state.matchedLocation != '/';
      if (protected && !operationalReady) {
        return '/';
      }
      if (state.matchedLocation.startsWith('/demo-') && !localDemoActive) {
        return operationalReady ? '/home' : '/';
      }
      if (operationalReady && state.matchedLocation == '/') {
        return '/home';
      }
      return null;
    },
  );
});
