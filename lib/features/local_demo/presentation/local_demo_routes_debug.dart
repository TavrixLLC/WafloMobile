import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_scenarios_screen.dart';

List<RouteBase> buildLocalDemoRoutes() => [
  GoRoute(
    path: '/demo-scenarios',
    builder: (context, state) => const LocalDemoScenariosScreen(),
  ),
  GoRoute(path: '/demo-blocked', builder: _blocked),
];

Widget _blocked(BuildContext context, GoRouterState routeState) {
  return Consumer(
    builder: (context, ref, child) {
      final scenario = ref.watch(localDemoControllerProvider).scenario;
      final revoked = scenario == LocalDemoScenario.deviceRevoked;
      return BlockedScreen(
        state: BootState(
          stage: revoked ? BootStage.deviceRevoked : BootStage.sessionExpired,
          failure: ApiFailure(
            revoked ? 'STAFF_DEVICE_REVOKED' : 'STAFF_DEVICE_SESSION_EXPIRED',
            httpStatus: 401,
          ),
        ),
        presentationOnly: true,
        onClose: () => context.go('/demo-scenarios'),
      );
    },
  );
}
