import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';

final class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({required this.state, super.key});

  final BootState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final content = switch (state.stage) {
      BootStage.sessionExpired => (
        strings.sessionExpiredTitle,
        strings.sessionExpiredBody,
        Icons.schedule_outlined,
        WafloColors.warning,
      ),
      BootStage.deviceRevoked => (
        strings.deviceRevokedTitle,
        strings.deviceRevokedBody,
        Icons.block_outlined,
        WafloColors.danger,
      ),
      BootStage.deviceCompromised => (
        strings.deviceCompromisedTitle,
        strings.deviceCompromisedBody,
        Icons.gpp_bad_outlined,
        WafloColors.danger,
      ),
      BootStage.appUpdateRequired => (
        strings.updateRequiredTitle,
        strings.updateRequiredBody,
        Icons.system_update_outlined,
        WafloColors.warning,
      ),
      BootStage.configurationError => (
        strings.configurationErrorTitle,
        strings.configurationErrorBody,
        Icons.settings_suggest_outlined,
        WafloColors.danger,
      ),
      BootStage.fatalLocalSecurityError => (
        strings.localSecurityErrorTitle,
        strings.localSecurityErrorBody,
        Icons.key_off_outlined,
        WafloColors.danger,
      ),
      _ => (
        strings.backendUnavailableTitle,
        strings.backendUnavailableBody,
        Icons.cloud_off_outlined,
        WafloColors.warning,
      ),
    };
    final repair =
        state.stage == BootStage.sessionExpired ||
        state.stage == BootStage.deviceRevoked ||
        state.stage == BootStage.deviceCompromised ||
        state.stage == BootStage.fatalLocalSecurityError;
    return WafloPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(content.$3, size: 72, color: content.$4),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            content.$1,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WafloSpacing.md),
          Text(content.$2, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.lg),
          if (repair)
            FilledButton.icon(
              key: const Key('reset-for-repair'),
              onPressed: () => unawaited(
                ref.read(bootControllerProvider.notifier).resetForRepair(),
              ),
              icon: const Icon(Icons.restart_alt),
              label: Text(strings.resetForRepair),
            )
          else
            FilledButton.icon(
              key: const Key('retry-boot'),
              onPressed: () => unawaited(
                ref.read(bootControllerProvider.notifier).initialize(),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(strings.retry),
            ),
          if (state.failure?.requestId case final requestId?) ...[
            const SizedBox(height: WafloSpacing.md),
            Text(
              strings.requestReference(requestId),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
