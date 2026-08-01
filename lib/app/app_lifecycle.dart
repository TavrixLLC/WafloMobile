import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';

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
  bool _privacyCover = false;

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
      setState(() => _privacyCover = false);
      unawaited(ref.read(bootControllerProvider.notifier).onResume());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      setState(() => _privacyCover = true);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.topLeft,
    fit: StackFit.expand,
    children: [
      widget.child,
      if (_privacyCover)
        const ColoredBox(
          color: Color(0xFF10231B),
          child: Center(
            child: Icon(Icons.shield_outlined, size: 64, color: Colors.white),
          ),
        ),
    ],
  );
}
