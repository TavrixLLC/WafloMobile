import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/local_demo/domain/local_demo.dart';
import 'package:waflo_staff/features/local_demo/presentation/local_demo_controller.dart';

final class DebugLocalDemoScannerControls extends ConsumerWidget {
  const DebugLocalDemoScannerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(localDemoControllerProvider).active) {
      return const SizedBox.shrink();
    }
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: WafloSpacing.sm),
      child: Tooltip(
        message: strings.demoControls,
        child: Material(
          key: const Key('local-demo-scanner-controls'),
          color: const Color(0xB3091713),
          borderRadius: BorderRadius.circular(WafloRadius.pill),
          child: InkWell(
            onTap: () => unawaited(_showControls(context, ref)),
            borderRadius: BorderRadius.circular(WafloRadius.pill),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune_rounded, color: Colors.white),
                    const SizedBox(width: WafloSpacing.xs),
                    Text(
                      strings.demoControls,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _showControls(
    BuildContext context,
    WidgetRef ref,
  ) => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final strings = AppLocalizations.of(sheetContext);
      final controller = ref.read(localDemoControllerProvider.notifier);
      return SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          WafloSpacing.lg,
          WafloSpacing.xs,
          WafloSpacing.lg,
          WafloSpacing.xl + MediaQuery.viewPaddingOf(sheetContext).bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.demoControls,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: WafloSpacing.xs),
              Text(
                strings.sampleData,
                style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: WafloSpacing.lg),
              Wrap(
                spacing: WafloSpacing.sm,
                runSpacing: WafloSpacing.sm,
                children: [
                  _DemoScannerAction(
                    key: const Key('simulate-valid-qr'),
                    label: strings.simulateValidQr,
                    onPressed: () => _simulate(
                      sheetContext,
                      controller,
                      LocalDemoScannerSimulation.validQr,
                    ),
                  ),
                  _DemoScannerAction(
                    key: const Key('simulate-invalid-qr'),
                    label: strings.simulateInvalidQr,
                    onPressed: () => _simulate(
                      sheetContext,
                      controller,
                      LocalDemoScannerSimulation.invalidQr,
                    ),
                  ),
                  _DemoScannerAction(
                    key: const Key('simulate-expired-qr'),
                    label: strings.simulateExpiredQr,
                    onPressed: () => _simulate(
                      sheetContext,
                      controller,
                      LocalDemoScannerSimulation.expiredQr,
                    ),
                  ),
                  _DemoScannerAction(
                    key: const Key('simulate-network-failure'),
                    label: strings.simulateNetworkFailure,
                    onPressed: () => _simulate(
                      sheetContext,
                      controller,
                      LocalDemoScannerSimulation.networkFailure,
                    ),
                  ),
                  _DemoScannerAction(
                    key: const Key('reset-demo-scanner'),
                    label: strings.resetScanner,
                    onPressed: () => _simulate(
                      sheetContext,
                      controller,
                      LocalDemoScannerSimulation.reset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  static void _simulate(
    BuildContext context,
    LocalDemoController controller,
    LocalDemoScannerSimulation simulation,
  ) {
    Navigator.of(context).pop();
    unawaited(controller.simulateScanner(simulation));
  }
}

final class DebugLocalDemoManagerApprovalAction extends ConsumerWidget {
  const DebugLocalDemoManagerApprovalAction({required this.locale, super.key});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(localDemoControllerProvider).active) {
      return const SizedBox.shrink();
    }
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: WafloSpacing.sm),
      child: OutlinedButton.icon(
        key: const Key('simulate-manager-approved'),
        onPressed: () => unawaited(
          ref
              .read(localDemoControllerProvider.notifier)
              .simulateManagerApproved(locale: locale),
        ),
        icon: const Icon(Icons.check_circle_outline_rounded),
        label: Text(strings.simulateManagerApproved),
      ),
    );
  }
}

final class _DemoScannerAction extends StatelessWidget {
  const _DemoScannerAction({
    required super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      minimumSize: const Size(48, 44),
    ),
    onPressed: onPressed,
    child: Text(label),
  );
}
