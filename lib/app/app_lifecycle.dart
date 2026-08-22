import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/features/app_lock/presentation/app_lock_screens.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';

final class AppLifecycleBoundary extends ConsumerStatefulWidget {
  const AppLifecycleBoundary({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLifecycleBoundary> createState() =>
      _AppLifecycleBoundaryState();
}

final class _AppLifecycleBoundaryState
    extends ConsumerState<AppLifecycleBoundary>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appLockControllerProvider.notifier).onResume(DateTime.now());
      unawaited(ref.read(bootControllerProvider.notifier).onResume());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockControllerProvider.notifier).onBackground(DateTime.now());
      ref.read(m2OperationControllerProvider.notifier).onBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(appLockControllerProvider);
    final paired = ref.watch(
      bootControllerProvider.select(
        (state) => state.stage == BootStage.pairedReady,
      ),
    );
    final locked = paired && lock.isLocked;
    return Stack(
      alignment: Alignment.topLeft,
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(excluding: locked, child: widget.child),
        if (locked) const AppLockOverlay(),
      ],
    );
  }
}
