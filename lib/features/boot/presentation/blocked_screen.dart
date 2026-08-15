import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/boot/presentation/boot_controller.dart';

final class BlockedScreen extends ConsumerWidget {
  const BlockedScreen({
    required this.state,
    this.presentationOnly = false,
    this.onClose,
    super.key,
  });

  final BootState state;
  final bool presentationOnly;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final content = _content(strings, state.stage);
    final repair =
        !presentationOnly &&
        (state.stage == BootStage.sessionExpired ||
            state.stage == BootStage.staffUserDeactivated ||
            state.stage == BootStage.staffMembershipInactive ||
            state.stage == BootStage.staffLocationAssignmentInvalid ||
            state.stage == BootStage.fatalLocalSecurityError);
    final retry =
        !presentationOnly &&
        (state.stage == BootStage.backendUnavailable ||
            state.stage == BootStage.devicePending);
    return WafloPage(
      scrollable: false,
      child: Semantics(
        liveRegion: true,
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: '${content.title}. ${content.body}',
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: content.foreground,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: WafloSpacing.sm),
                        WafloOperationalLabel(
                          strings.customerOperationsPaused,
                          color: context.waflo.subtleText,
                        ),
                      ],
                    ),
                    const SizedBox(height: WafloSpacing.sm),
                    Text(
                      content.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: WafloSpacing.sm),
                    Text(
                      content.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: WafloSpacing.lg),
                    WafloSurfaceCard(
                      color: content.background,
                      padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            content.icon,
                            size: 22,
                            color: content.foreground,
                          ),
                          const SizedBox(width: WafloSpacing.sm),
                          Expanded(
                            child: Text(
                              strings.customerOperationsPaused,
                              style: TextStyle(color: content.foreground),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    if (repair)
                      FilledButton.icon(
                        key: const Key('reset-for-repair'),
                        onPressed: () => unawaited(
                          ref
                              .read(bootControllerProvider.notifier)
                              .resetForRepair(),
                        ),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: Text(strings.resetForRepair),
                      )
                    else if (retry)
                      FilledButton.icon(
                        key: const Key('retry-boot'),
                        onPressed: () => unawaited(
                          ref
                              .read(bootControllerProvider.notifier)
                              .initialize(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(strings.retry),
                      ),
                    if (repair || retry)
                      const SizedBox(height: WafloSpacing.md),
                    if (presentationOnly && onClose != null) ...[
                      FilledButton.icon(
                        key: const Key('back-to-demo-scenarios'),
                        onPressed: onClose,
                        icon: const Icon(Icons.view_list_outlined),
                        label: Text(strings.backToDemoScenarios),
                      ),
                      const SizedBox(height: WafloSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static _BlockedContent _content(AppLocalizations strings, BootStage stage) =>
      switch (stage) {
        BootStage.devicePending => _BlockedContent(
          title: strings.devicePendingTitle,
          body: strings.devicePendingBody,
          icon: Icons.hourglass_top_rounded,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
        BootStage.sessionExpired => _BlockedContent(
          title: strings.sessionExpiredTitle,
          body: strings.sessionExpiredBody,
          icon: Icons.schedule_rounded,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
        BootStage.staffUserDeactivated => _BlockedContent(
          title: strings.staffUserDeactivatedTitle,
          body: strings.staffUserDeactivatedBody,
          icon: Icons.person_off_rounded,
          foreground: WafloColors.danger,
          background: const Color(0xFFFFDAD6),
        ),
        BootStage.staffMembershipInactive => _BlockedContent(
          title: strings.staffMembershipInactiveTitle,
          body: strings.staffMembershipInactiveBody,
          icon: Icons.badge_outlined,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
        BootStage.staffLocationAssignmentInvalid => _BlockedContent(
          title: strings.staffLocationInvalidTitle,
          body: strings.staffLocationInvalidBody,
          icon: Icons.location_off_rounded,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
        BootStage.deviceRevoked => _BlockedContent(
          title: strings.deviceRevokedTitle,
          body: strings.deviceRevokedBody,
          icon: Icons.block_rounded,
          foreground: WafloColors.danger,
          background: const Color(0xFFFFDAD6),
        ),
        BootStage.deviceCompromised => _BlockedContent(
          title: strings.deviceCompromisedTitle,
          body: strings.deviceCompromisedBody,
          icon: Icons.gpp_bad_rounded,
          foreground: WafloColors.danger,
          background: const Color(0xFFFFDAD6),
        ),
        BootStage.appUpdateRequired => _BlockedContent(
          title: strings.updateRequiredTitle,
          body: strings.updateRequiredBody,
          icon: Icons.system_update_rounded,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
        BootStage.configurationError => _BlockedContent(
          title: strings.configurationErrorTitle,
          body: strings.configurationErrorBody,
          icon: Icons.settings_suggest_outlined,
          foreground: WafloColors.danger,
          background: const Color(0xFFFFDAD6),
        ),
        BootStage.fatalLocalSecurityError => _BlockedContent(
          title: strings.localSecurityErrorTitle,
          body: strings.localSecurityErrorBody,
          icon: Icons.key_off_rounded,
          foreground: WafloColors.danger,
          background: const Color(0xFFFFDAD6),
        ),
        _ => _BlockedContent(
          title: strings.backendUnavailableTitle,
          body: '${strings.backendUnavailableBody} ${strings.noOfflineQueue}',
          icon: Icons.cloud_off_rounded,
          foreground: WafloColors.warning,
          background: const Color(0xFFFFEBCB),
        ),
      };
}

final class _BlockedContent {
  const _BlockedContent({
    required this.title,
    required this.body,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color foreground;
  final Color background;
}
