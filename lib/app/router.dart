import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/boot/presentation/boot_gate.dart';
import 'package:waflo_staff/features/device_security/presentation/device_security_screen.dart';
import 'package:waflo_staff/features/membership_resolution/presentation/loyalty_operation_screen.dart';
import 'package:waflo_staff/features/review_access/presentation/review_tools_screen.dart';
import 'package:waflo_staff/features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final ready = ref.watch(
    bootControllerProvider.select(
      (state) => state.stage == BootStage.pairedReady,
    ),
  );
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
      GoRoute(
        path: '/review-tools',
        builder: (context, state) => const ReviewToolsScreen(),
      ),
    ],
    redirect: (context, state) {
      final protected = state.matchedLocation != '/';
      if (protected && !ready) {
        return '/';
      }
      if (state.matchedLocation == '/review-tools' &&
          !(ref.read(bootControllerProvider).session?.isReview ?? false)) {
        return ready ? '/home' : '/';
      }
      if (ready && state.matchedLocation == '/') {
        return '/home';
      }
      return null;
    },
  );
});
