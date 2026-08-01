import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/app_shell/presentation/home_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/boot/presentation/boot_gate.dart';
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
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final protected =
          state.matchedLocation == '/home' ||
          state.matchedLocation == '/settings';
      if (protected && !ready) {
        return '/';
      }
      if (ready && state.matchedLocation == '/') {
        return '/home';
      }
      return null;
    },
  );
});
