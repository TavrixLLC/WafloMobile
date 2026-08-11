import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/boot/presentation/blocked_screen.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_screens.dart';

final class BootGate extends ConsumerStatefulWidget {
  const BootGate({super.key});

  @override
  ConsumerState<BootGate> createState() => _BootGateState();
}

final class _BootGateState extends ConsumerState<BootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(bootControllerProvider.notifier).initialize());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bootControllerProvider);
    return switch (state.stage) {
      BootStage.unpaired ||
      BootStage.pairingInProgress => const PairingFlowScreen(),
      BootStage.sessionExpired ||
      BootStage.devicePending ||
      BootStage.deviceRevoked ||
      BootStage.deviceCompromised ||
      BootStage.appUpdateRequired ||
      BootStage.backendUnavailable ||
      BootStage.configurationError ||
      BootStage.fatalLocalSecurityError => BlockedScreen(state: state),
      _ => const BootLoadingScreen(),
    };
  }
}

final class BootLoadingScreen extends StatelessWidget {
  const BootLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      child: Semantics(
        liveRegion: true,
        label: strings.bootProgress,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WafloBrandMark(),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(strings.bootProgress, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
