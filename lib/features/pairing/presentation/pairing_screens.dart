import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/app_locales.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/core/permissions/camera_permission.dart';
import 'package:waflo_staff/core/permissions/camera_permission_dialog.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';
import 'package:waflo_staff/features/customer_scan/presentation/professional_scanner_overlay.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_scanner_adapter.dart';
import 'package:waflo_staff/features/review_access/domain/local_review_access.dart';

final class PairingFlowScreen extends ConsumerWidget {
  const PairingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pairingControllerProvider);
    return switch (state.stage) {
      PairingViewStage.welcome => const _WelcomeScreen(),
      PairingViewStage.cameraRationale => _CameraRationaleScreen(
        initialAccess: state.cameraPermission,
      ),
      PairingViewStage.scanner => const PairingScannerScreen(),
      PairingViewStage.manualEntry => const _ManualPairingScreen(),
      PairingViewStage.progress => _PairingProgressScreen(
        progress: state.progress ?? PairingProgress.validating,
      ),
      PairingViewStage.success => _PairingSuccessScreen(state: state),
      PairingViewStage.error => _PairingErrorScreen(state: state),
    };
  }
}

final class _WelcomeScreen extends ConsumerWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final actions = _PairingWelcomeActions(
      selectedLocale: locale,
      onScan: () => unawaited(_requestPairingCamera(ref)),
      onLanguage: () => unawaited(
        _showPairingLanguageSheet(
          context,
          selectedLocale: locale,
          onSelected: (selected) => unawaited(
            ref.read(localeControllerProvider.notifier).setLocale(selected),
          ),
        ),
      ),
    );
    return WafloPage(
      maxWidth: WafloLayout.maximumWideContentWidth,
      scrollable: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PairingWelcomeIntroduction(
                      strings: strings,
                      compact: true,
                    ),
                    const Spacer(),
                    actions,
                  ],
                ),
              ),
            ),
          );
          final medium = SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Align(
                alignment: const AlignmentDirectional(0, -.12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SizedBox(
                    key: const Key('pairing-medium-workspace'),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PairingWelcomeIntroduction(strings: strings),
                        const SizedBox(height: WafloSpacing.xl),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: actions,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          final wide = SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Align(
                alignment: AlignmentDirectional.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Container(
                    key: const Key('pairing-wide-workspace'),
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.all(WafloSpacing.xl),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(
                        WafloRadius.extraLarge,
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: .72),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _PairingWelcomeIntroduction(
                              strings: strings,
                            ),
                          ),
                          const SizedBox(width: WafloSpacing.lg),
                          VerticalDivider(
                            key: const Key('pairing-workspace-divider'),
                            width: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          const SizedBox(width: WafloSpacing.lg),
                          Expanded(
                            flex: 5,
                            child: Container(
                              key: const Key('pairing-action-pane'),
                              alignment: AlignmentDirectional.center,
                              child: actions,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          return WafloAdaptiveLayout(
            compact: compact,
            medium: medium,
            wide: wide,
          );
        },
      ),
    );
  }
}

final class _PairingWelcomeIntroduction extends StatelessWidget {
  const _PairingWelcomeIntroduction({
    required this.strings,
    this.compact = false,
  });

  final AppLocalizations strings;
  final bool compact;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('pairing-introduction-pane'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Align(
        alignment: AlignmentDirectional.centerStart,
        child: WafloBrandMark(size: 42),
      ),
      SizedBox(height: compact ? 40 : WafloSpacing.lg),
      Text(
        strings.welcomeTitle,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: WafloSpacing.sm),
      Text(
        strings.welcomeBody,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: context.waflo.subtleText),
      ),
      const SizedBox(height: WafloSpacing.lg),
      if (compact)
        Text(
          strings.securitySummary,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.waflo.subtleText),
        )
      else
        Container(
          key: const Key('pairing-security-rail'),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(WafloRadius.medium),
            border: BorderDirectional(
              start: BorderSide(color: context.waflo.brandAction, width: 4),
            ),
          ),
          child: Text(
            strings.securitySummary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.waflo.subtleText),
          ),
        ),
    ],
  );
}

final class _PairingWelcomeActions extends StatelessWidget {
  const _PairingWelcomeActions({
    required this.selectedLocale,
    required this.onScan,
    required this.onLanguage,
  });

  final Locale selectedLocale;
  final VoidCallback onScan;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('pairing-actions-group'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      FilledButton(
        key: const Key('scan-pairing-code'),
        onPressed: onScan,
        child: Text(AppLocalizations.of(context).scanPairingCode),
      ),
      const SizedBox(height: WafloSpacing.sm),
      Align(
        alignment: AlignmentDirectional.center,
        child: _PairingLanguageControl(
          selectedLocale: selectedLocale,
          onPressed: onLanguage,
        ),
      ),
    ],
  );
}

final class _PairingLanguageControl extends StatelessWidget {
  const _PairingLanguageControl({
    required this.selectedLocale,
    required this.onPressed,
  });

  final Locale selectedLocale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TextButton(
      key: const Key('pairing-language-control'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.waflo.subtleText,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: WafloSpacing.sm,
        ),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language_rounded, size: 18),
          const SizedBox(width: WafloSpacing.sm),
          Flexible(
            child: Text(
              '${strings.chooseLanguage} · '
              '${_localizedLocaleName(strings, selectedLocale)}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: WafloSpacing.xs),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    );
  }
}

Future<void> _showPairingLanguageSheet(
  BuildContext context, {
  required Locale selectedLocale,
  required ValueChanged<Locale> onSelected,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (sheetContext) => _PairingLanguageSheet(
    selectedLocale: selectedLocale,
    onSelected: (locale) {
      Navigator.of(sheetContext).pop();
      onSelected(locale);
    },
  ),
);

final class _PairingLanguageSheet extends StatelessWidget {
  const _PairingLanguageSheet({
    required this.selectedLocale,
    required this.onSelected,
  });

  final Locale selectedLocale;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        WafloLayout.pageGutter,
        0,
        WafloLayout.pageGutter,
        WafloSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: WafloLayout.maximumContentWidth,
          ),
          child: Column(
            key: const Key('pairing-language-sheet-content'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.chooseLanguage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: WafloSpacing.md),
              _PairingLocaleRow(
                key: const Key('pairing-language-en'),
                label: strings.english,
                selected: WafloLocales.same(
                  selectedLocale,
                  WafloLocales.english,
                ),
                onTap: () => onSelected(WafloLocales.english),
              ),
              const SizedBox(height: WafloSpacing.xs),
              _PairingLocaleRow(
                key: const Key('pairing-language-ar'),
                label: strings.arabic,
                selected: WafloLocales.same(
                  selectedLocale,
                  WafloLocales.arabic,
                ),
                onTap: () => onSelected(WafloLocales.arabic),
              ),
              const SizedBox(height: WafloSpacing.lg),
              Text(
                key: const Key('pairing-language-kurdish-label'),
                strings.kurdishGroup,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.waflo.subtleText,
                ),
              ),
              const SizedBox(height: WafloSpacing.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: WafloSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _PairingLocaleRow(
                        key: const Key('pairing-language-ku-Arab-IQ'),
                        label: strings.kurdishBadini,
                        selected: WafloLocales.same(
                          selectedLocale,
                          WafloLocales.badini,
                        ),
                        onTap: () => onSelected(WafloLocales.badini),
                      ),
                      const SizedBox(height: WafloSpacing.xs),
                      _PairingLocaleRow(
                        key: const Key('pairing-language-ckb'),
                        label: strings.kurdishSorani,
                        selected: WafloLocales.same(
                          selectedLocale,
                          WafloLocales.sorani,
                        ),
                        onTap: () => onSelected(WafloLocales.sorani),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _PairingLocaleRow extends StatelessWidget {
  const _PairingLocaleRow({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(WafloRadius.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: WafloLayout.minimumTouchTarget + 8,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 12,
              vertical: WafloSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? context.waflo.brandAction : null,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.waflo.brandAction,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: context.waflo.onBrandAction,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

String _localizedLocaleName(AppLocalizations strings, Locale locale) {
  if (WafloLocales.same(locale, WafloLocales.arabic)) return strings.arabic;
  if (WafloLocales.same(locale, WafloLocales.badini)) {
    return strings.kurdishBadini;
  }
  if (WafloLocales.same(locale, WafloLocales.sorani)) {
    return strings.kurdishSorani;
  }
  return strings.english;
}

Future<void> _requestPairingCamera(WidgetRef ref) async {
  final controller = ref.read(pairingControllerProvider.notifier);
  final permissions = ref.read(cameraPermissionCoordinatorProvider);
  final access = await permissions.requestAccess();
  if (access == CameraPermissionAccess.granted) {
    controller.showScanner();
  } else {
    controller.showCameraRationale(permission: access);
  }
}

final class _CameraRationaleScreen extends ConsumerStatefulWidget {
  const _CameraRationaleScreen({required this.initialAccess});

  final CameraPermissionAccess? initialAccess;

  @override
  ConsumerState<_CameraRationaleScreen> createState() =>
      _CameraRationaleScreenState();
}

final class _CameraRationaleScreenState
    extends ConsumerState<_CameraRationaleScreen>
    with WidgetsBindingObserver {
  late CameraPermissionAccess? _access = widget.initialAccess;
  bool _requesting = false;
  bool _returningFromSettings = false;

  bool get _denied =>
      _access != null && _access != CameraPermissionAccess.granted;
  bool get _settingsRequired =>
      _access == CameraPermissionAccess.permanentlyDenied ||
      _access == CameraPermissionAccess.restricted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_settingsRequired) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showSettingsDialog(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _returningFromSettings) {
      _returningFromSettings = false;
      unawaited(_checkAfterSettings());
    }
  }

  Future<void> _request() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    final access = await ref
        .read(cameraPermissionCoordinatorProvider)
        .requestAccess();
    if (!mounted) return;
    setState(() {
      _requesting = false;
      _access = access;
    });
    if (access == CameraPermissionAccess.granted) {
      ref.read(pairingControllerProvider.notifier).showScanner();
      return;
    }
    if (_settingsRequired) await _showSettingsDialog();
  }

  Future<void> _showSettingsDialog() async {
    if (!mounted || !_settingsRequired) return;
    await showCameraPermissionSettingsDialog(
      context,
      onOpenSettings: _openSettings,
    );
  }

  Future<void> _openSettings() async {
    _returningFromSettings = true;
    final opened = await ref
        .read(cameraPermissionCoordinatorProvider)
        .openSettings();
    if (!opened) _returningFromSettings = false;
  }

  Future<void> _checkAfterSettings() async {
    final access = await ref
        .read(cameraPermissionCoordinatorProvider)
        .checkAccess();
    if (!mounted) return;
    if (access == CameraPermissionAccess.granted) {
      ref.read(pairingControllerProvider.notifier).showScanner();
    } else {
      setState(() => _access = access);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      maxWidth: WafloLayout.maximumFormWidth,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => ref.read(pairingControllerProvider.notifier).reset(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 72),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            strings.cameraTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WafloSpacing.md),
          Text(strings.cameraBody, textAlign: TextAlign.center),
          if (_denied) ...[
            const SizedBox(height: WafloSpacing.md),
            WafloStatusBanner(
              icon: Icons.no_photography_outlined,
              message: strings.cameraPermissionDeniedBody,
              color: WafloColors.warning,
            ),
          ],
          const SizedBox(height: WafloSpacing.lg),
          if (_settingsRequired)
            FilledButton(
              onPressed: () => unawaited(_showSettingsDialog()),
              child: Text(strings.openSettings),
            )
          else
            FilledButton(
              key: const Key('request-camera'),
              onPressed: _requesting ? null : _request,
              child: Text(_denied ? strings.retry : strings.continueAction),
            ),
          const SizedBox(height: WafloSpacing.sm),
          OutlinedButton(
            onPressed: () =>
                ref.read(pairingControllerProvider.notifier).showManualEntry(),
            child: Text(_denied ? strings.enterCodeInstead : strings.notNow),
          ),
        ],
      ),
    );
  }
}

final class PairingScannerScreen extends ConsumerStatefulWidget {
  const PairingScannerScreen({super.key});

  @override
  ConsumerState<PairingScannerScreen> createState() =>
      _PairingScannerScreenState();
}

final class _PairingScannerScreenState
    extends ConsumerState<PairingScannerScreen>
    with WidgetsBindingObserver {
  bool _handled = false;
  bool _settingsDialogScheduled = false;
  PairingScannerAdapter? _adapter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final adapter = ref.read(pairingScannerAdapterProvider);
      _bindAdapter(adapter);
      unawaited(adapter.start());
    });
  }

  void _bindAdapter(PairingScannerAdapter adapter) {
    if (identical(_adapter, adapter)) return;
    _adapter?.state.removeListener(_onScannerStateChanged);
    _adapter = adapter;
    adapter.state.addListener(_onScannerStateChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adapter?.state.removeListener(_onScannerStateChanged);
    super.dispose();
  }

  void _onScannerStateChanged() {
    final state = _adapter?.state.value;
    if (state != CustomerScannerState.cameraPermissionPermanentlyDenied) {
      _settingsDialogScheduled = false;
      return;
    }
    if (_settingsDialogScheduled || !mounted) return;
    _settingsDialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
          showCameraPermissionSettingsDialog(
            context,
            onOpenSettings: ref
                .read(cameraPermissionCoordinatorProvider)
                .openSettings,
          ),
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_handled) {
      unawaited(_resumeScanner());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(ref.read(pairingScannerAdapterProvider).stop());
    }
  }

  Future<void> _resumeScanner() async {
    final access = await ref
        .read(cameraPermissionCoordinatorProvider)
        .checkAccess();
    if (!mounted || _handled) return;
    if (access == CameraPermissionAccess.granted) {
      await ref.read(pairingScannerAdapterProvider).start();
    } else {
      ref
          .read(pairingControllerProvider.notifier)
          .showCameraRationale(permission: access);
    }
  }

  Future<void> _detected(String candidate) async {
    if (_handled) {
      return;
    }
    _handled = true;
    await ref.read(pairingScannerAdapterProvider).stop();
    await ref.read(pairingControllerProvider.notifier).submit(candidate);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final adapter = ref.watch(pairingScannerAdapterProvider);
    _bindAdapter(adapter);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<CustomerScannerState>(
        valueListenable: adapter.state,
        builder: (context, scannerState, child) => Stack(
          fit: StackFit.expand,
          children: [
            adapter.buildPreview(context, onDetected: _detected),
            ProfessionalScannerOverlay(
              state: scannerState,
              semanticLabel: strings.scannerInstructions,
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: WafloConstrainedContent(
                contentKey: const Key('scanner-controls-content'),
                maxWidth: WafloLayout.maximumWideContentWidth,
                child: Column(
                  children: [
                    Row(
                      children: [
                        WafloScannerRoundAction(
                          tooltip: strings.close,
                          icon: Icons.close_rounded,
                          onPressed: () => ref
                              .read(pairingControllerProvider.notifier)
                              .reset(),
                        ),
                        const SizedBox(width: WafloSpacing.sm),
                        Expanded(
                          child: Text(
                            strings.scannerTitle,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style:
                                (largeText
                                        ? Theme.of(
                                            context,
                                          ).textTheme.titleMedium
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleLarge)
                                    ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    WafloScannerControlDeck(
                      instruction: strings.scannerInstructions,
                      status: WafloScannerStatusPill(
                        label: switch (scannerState) {
                          CustomerScannerState.requestingPermission =>
                            strings.requestingCamera,
                          CustomerScannerState.initializingCamera =>
                            strings.initializingCamera,
                          CustomerScannerState.candidateCaptured =>
                            strings.codeDetected,
                          CustomerScannerState.cameraUnavailable =>
                            strings.cameraUnavailable,
                          CustomerScannerState.cameraPermissionDenied ||
                          CustomerScannerState
                              .cameraPermissionPermanentlyDenied =>
                            strings.cameraPermissionDeniedTitle,
                          _ => strings.scannerReady,
                        },
                        busy:
                            scannerState ==
                                CustomerScannerState.initializingCamera ||
                            scannerState ==
                                CustomerScannerState.candidateCaptured,
                      ),
                      actions: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: WafloSpacing.sm,
                        runSpacing: WafloSpacing.sm,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: adapter.torchEnabled,
                            builder: (context, enabled, child) =>
                                WafloScannerRoundAction(
                                  tooltip: strings.toggleFlash,
                                  label: enabled
                                      ? strings.flashOff
                                      : strings.flashOn,
                                  icon: enabled
                                      ? Icons.flashlight_off_rounded
                                      : Icons.flashlight_on_rounded,
                                  onPressed: () =>
                                      unawaited(adapter.toggleTorch()),
                                ),
                          ),
                          WafloScannerRoundAction(
                            key: const Key('manual-code-entry'),
                            tooltip: strings.enterCodeInstead,
                            label: strings.enterCodeInstead,
                            icon: Icons.keyboard_alt_outlined,
                            onPressed: () {
                              unawaited(adapter.stop());
                              ref
                                  .read(pairingControllerProvider.notifier)
                                  .showManualEntry();
                            },
                          ),
                        ],
                      ),
                    ),
                    if (scannerState ==
                            CustomerScannerState.cameraPermissionDenied ||
                        scannerState ==
                            CustomerScannerState
                                .cameraPermissionPermanentlyDenied) ...[
                      const SizedBox(height: WafloSpacing.sm),
                      FilledButton(
                        onPressed:
                            scannerState ==
                                CustomerScannerState
                                    .cameraPermissionPermanentlyDenied
                            ? () => unawaited(
                                showCameraPermissionSettingsDialog(
                                  context,
                                  onOpenSettings: ref
                                      .read(cameraPermissionCoordinatorProvider)
                                      .openSettings,
                                ),
                              )
                            : () => unawaited(adapter.start()),
                        child: Text(
                          scannerState ==
                                  CustomerScannerState
                                      .cameraPermissionPermanentlyDenied
                              ? strings.openSettings
                              : strings.retry,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ManualPairingScreen extends ConsumerStatefulWidget {
  const _ManualPairingScreen();

  @override
  ConsumerState<_ManualPairingScreen> createState() =>
      _ManualPairingScreenState();
}

final class _ManualPairingScreenState
    extends ConsumerState<_ManualPairingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      maxWidth: WafloLayout.maximumFormWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WafloTopBar(
            title: strings.scannerTitle,
            backTooltip: strings.close,
            onBack: () => unawaited(_requestPairingCamera(ref)),
          ),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            strings.manualCodeTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: WafloSpacing.lg),
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              key: const Key('manual-code-input'),
              controller: _controller,
              autofocus: true,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              maxLength: 512,
              textAlign: TextAlign.start,
              onChanged: _formatShortCode,
              onSubmitted: (_) => unawaited(_submit()),
              decoration: InputDecoration(labelText: strings.manualCodeHint),
            ),
          ),
          const SizedBox(height: WafloSpacing.sm),
          Text(
            strings.securitySummary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.waflo.subtleText),
          ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton(
            key: const Key('manual-code-continue'),
            onPressed: () => unawaited(_submit()),
            child: Text(strings.continueAction),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final code = _controller.text;
    _controller.clear();
    await ref.read(pairingControllerProvider.notifier).submitManualCode(code);
  }

  void _formatShortCode(String value) {
    if (value.toLowerCase().startsWith('waflo') ||
        value.length > 16 ||
        !RegExp(r'^[A-Za-z0-9 -]*$').hasMatch(value)) {
      return;
    }
    final normalized = LocalReviewCodeFormat.normalize(value);
    if (normalized == value) return;
    _controller.value = TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

final class _PairingProgressScreen extends StatelessWidget {
  const _PairingProgressScreen({required this.progress});

  final PairingProgress progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final message = switch (progress) {
      PairingProgress.validating => strings.pairingValidating,
      PairingProgress.creatingIdentity => strings.pairingCreatingIdentity,
      PairingProgress.claiming => strings.pairingClaiming,
      PairingProgress.recoveringChallenge => strings.pairingRecovering,
      PairingProgress.signing => strings.pairingSigning,
      PairingProgress.completing => strings.pairingCompleting,
      PairingProgress.saving => strings.pairingSaving,
      PairingProgress.loadingContext => strings.pairingLoadingContext,
    };
    return WafloPage(
      maxWidth: WafloLayout.maximumFormWidth,
      child: Semantics(
        liveRegion: true,
        label: message,
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: WafloSpacing.lg),
            Text(
              strings.pairingProgressTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WafloSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

final class _PairingSuccessScreen extends ConsumerWidget {
  const _PairingSuccessScreen({required this.state});

  final PairingViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final deviceContext = state.context;
    return WafloPage(
      maxWidth: WafloLayout.maximumFormWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.pairingSuccessTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WafloSpacing.sm),
          Text(strings.pairingSuccessBody, textAlign: TextAlign.center),
          if (deviceContext != null) ...[
            const SizedBox(height: WafloSpacing.lg),
            Container(
              key: const Key('pairing-confirmation-card'),
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: context.waflo.successSurface,
                borderRadius: BorderRadius.circular(WafloRadius.large),
                border: Border.all(
                  color: WafloColors.success.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: WafloColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 24,
                      color: WafloColors.white,
                    ),
                  ),
                  const SizedBox(width: WafloSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WafloOperationalLabel(
                          strings.verifiedByWaflo,
                          color: context.waflo.onSuccessSurface,
                        ),
                        if (deviceContext
                            .organization
                            .displayName
                            .isNotEmpty) ...[
                          const SizedBox(height: WafloSpacing.xs),
                          Text(
                            deviceContext.organization.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: context.waflo.onSuccessSurface,
                                ),
                          ),
                        ],
                        if (deviceContext
                            .currentLocation
                            .displayName
                            .isNotEmpty)
                          Text(
                            deviceContext.currentLocation.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.waflo.onSuccessSurface,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: WafloSpacing.lg),
          FilledButton(
            key: const Key('pairing-success-continue'),
            onPressed: () => unawaited(
              ref
                  .read(pairingControllerProvider.notifier)
                  .continueAfterSuccess(),
            ),
            child: Text(strings.goHome),
          ),
        ],
      ),
    );
  }
}

final class _PairingErrorScreen extends ConsumerWidget {
  const _PairingErrorScreen({required this.state});

  final PairingViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final message = _localizedPairingError(strings, state);
    return WafloPage(
      maxWidth: WafloLayout.maximumFormWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline, size: 72, color: WafloColors.danger),
          const SizedBox(height: WafloSpacing.lg),
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: WafloSpacing.lg),
          FilledButton(
            key: const Key('pairing-error-retry'),
            onPressed: () {
              final controller = ref.read(pairingControllerProvider.notifier);
              if (state.reviewFlow) {
                controller.showManualEntry();
              } else {
                controller.showCameraRationale();
              }
            },
            child: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}

String _localizedPairingError(
  AppLocalizations strings,
  PairingViewState state,
) {
  if (state.problem == PairingQrProblem.wrongEnvironment) {
    return strings.wrongEnvironmentPairing;
  }
  if (state.problem != null) {
    return strings.invalidPairing;
  }
  return switch (state.failure?.safeCode) {
    'DEVICE_PAIRING_EXPIRED' => strings.expiredPairing,
    'DEVICE_PAIRING_ALREADY_USED' => strings.usedPairing,
    'DEVICE_PAIRING_INVALID' => strings.invalidPairing,
    'VALIDATION_FAILED' => strings.validationError,
    'STAFF_DEVICE_SIGNATURE_INVALID' => strings.signatureError,
    'STAFF_DEVICE_CLOCK_SKEW' => strings.clockSkewError,
    'STAFF_ASSIGNMENT_REQUIRED' => strings.assignmentRequiredError,
    'LOCATION_NOT_AUTHORIZED' => strings.locationNotAuthorizedError,
    'RISK_HARD_BLOCK' => strings.riskBlockedError,
    'INTERNAL_ERROR' => strings.pairingInternalFailure,
    'REVIEW_ACCESS_INVALID' ||
    'REVIEW_ACCESS_REVOKED' => strings.validationError,
    'REVIEW_ACCESS_EXPIRED' => strings.validationError,
    'REVIEW_ACCESS_RATE_LIMITED' => strings.reviewAccessRateLimited,
    'REVIEW_TENANT_UNAVAILABLE' => strings.genericError,
    _ => strings.genericError,
  };
}
