import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_flow_service.dart';
import 'package:waflo_staff/features/pairing/domain/pairing_qr.dart';
import 'package:waflo_staff/features/pairing/presentation/pairing_controller.dart';

final class PairingFlowScreen extends ConsumerWidget {
  const PairingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pairingControllerProvider);
    return switch (state.stage) {
      PairingViewStage.welcome => const _WelcomeScreen(),
      PairingViewStage.cameraRationale => const _CameraRationaleScreen(),
      PairingViewStage.scanner => const PairingScannerScreen(),
      PairingViewStage.manualEntry => const _ManualPairingScreen(),
      PairingViewStage.localDemoIntro => const _LocalDemoAccessScreen(),
      PairingViewStage.reviewAccess => const _ReviewAccessScreen(),
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
    return WafloPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: WafloBrandMark()),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            strings.welcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WafloSpacing.md),
          Text(strings.welcomeBody, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.lg),
          WafloStatusBanner(
            icon: Icons.shield_outlined,
            message: strings.securitySummary,
          ),
          const SizedBox(height: WafloSpacing.lg),
          FilledButton.icon(
            key: const Key('scan-pairing-code'),
            onPressed: () => ref
                .read(pairingControllerProvider.notifier)
                .showCameraRationale(),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(strings.scanPairingCode),
          ),
          const SizedBox(height: WafloSpacing.lg),
          Container(
            padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(WafloRadius.large),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.reviewAccessPrompt,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: WafloSpacing.sm),
                TextButton(
                  key: const Key('review-access-entry'),
                  onPressed: () => ref
                      .read(pairingControllerProvider.notifier)
                      .showDemoAccess(),
                  child: Text(strings.reviewAccess),
                ),
              ],
            ),
          ),
          const SizedBox(height: WafloSpacing.md),
          Text(strings.chooseLanguage, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.sm),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text(strings.english)),
              ButtonSegment(value: 'ar', label: Text(strings.arabic)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (selection) => unawaited(
              ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(Locale(selection.first)),
            ),
          ),
        ],
      ),
    );
  }
}

final class _LocalDemoAccessScreen extends ConsumerWidget {
  const _LocalDemoAccessScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => ref.read(pairingControllerProvider.notifier).reset(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: WafloBrandMark()),
          const SizedBox(height: WafloSpacing.lg),
          Text(
            strings.demoAccess,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WafloSpacing.sm),
          Text(strings.localDemoAccessBody, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.lg),
          WafloStatusBanner(
            icon: Icons.visibility_outlined,
            message: strings.localDemoSafetyBody,
            color: context.waflo.brandAction,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          const SizedBox(height: WafloSpacing.xxl),
          FilledButton.icon(
            key: const Key('enter-local-demo'),
            onPressed: () => unawaited(
              ref.read(pairingControllerProvider.notifier).enterLocalDemo(),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(strings.enterDemo),
          ),
          const SizedBox(height: WafloSpacing.sm),
          TextButton(
            onPressed: () =>
                ref.read(pairingControllerProvider.notifier).reset(),
            child: Text(strings.backToPairing),
          ),
        ],
      ),
    );
  }
}

final class _ReviewAccessScreen extends ConsumerStatefulWidget {
  const _ReviewAccessScreen();

  @override
  ConsumerState<_ReviewAccessScreen> createState() =>
      _ReviewAccessScreenState();
}

final class _ReviewAccessScreenState
    extends ConsumerState<_ReviewAccessScreen> {
  final _controller = TextEditingController();
  bool _valid = false;

  @override
  void dispose() {
    _controller.clear();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    final normalized = PairingFlowService.normalizeReviewAccessCode(value);
    if (normalized != value) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    final valid = PairingFlowService.isValidReviewAccessCode(normalized);
    if (valid != _valid) setState(() => _valid = valid);
  }

  Future<void> _continue() async {
    if (!_valid) return;
    final code = _controller.text;
    _controller.clear();
    await ref.read(pairingControllerProvider.notifier).submitReviewAccess(code);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => ref.read(pairingControllerProvider.notifier).reset(),
        ),
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: WafloBrandMark()),
            const SizedBox(height: WafloSpacing.lg),
            Text(
              strings.reviewAccess,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WafloSpacing.sm),
            Text(strings.reviewAccessBody, textAlign: TextAlign.center),
            const SizedBox(height: WafloSpacing.xl),
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                key: const Key('review-access-code'),
                controller: _controller,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.oneTimeCode],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                maxLength: 9,
                onChanged: _changed,
                onSubmitted: (_) => unawaited(_continue()),
                decoration: InputDecoration(
                  labelText: strings.reviewAccessCode,
                  hintText: strings.reviewAccessCodeHint,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: WafloSpacing.lg),
            FilledButton(
              key: const Key('review-access-continue'),
              onPressed: _valid ? () => unawaited(_continue()) : null,
              child: Text(strings.continueAction),
            ),
            const SizedBox(height: WafloSpacing.sm),
            TextButton(
              onPressed: () =>
                  ref.read(pairingControllerProvider.notifier).reset(),
              child: Text(strings.backToPairing),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CameraRationaleScreen extends ConsumerStatefulWidget {
  const _CameraRationaleScreen();

  @override
  ConsumerState<_CameraRationaleScreen> createState() =>
      _CameraRationaleScreenState();
}

final class _CameraRationaleScreenState
    extends ConsumerState<_CameraRationaleScreen> {
  bool _denied = false;
  bool _permanentlyDenied = false;

  Future<void> _request() async {
    final status = await Permission.camera.request();
    if (!mounted) {
      return;
    }
    if (status.isGranted) {
      ref.read(pairingControllerProvider.notifier).showScanner();
      return;
    }
    setState(() {
      _denied = true;
      _permanentlyDenied = status.isPermanentlyDenied;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
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
              message: strings.cameraDenied,
              color: WafloColors.warning,
            ),
          ],
          const SizedBox(height: WafloSpacing.lg),
          if (_permanentlyDenied)
            FilledButton(
              onPressed: () => unawaited(openAppSettings()),
              child: Text(strings.openSettings),
            )
          else
            FilledButton(
              key: const Key('request-camera'),
              onPressed: _request,
              child: Text(strings.continueAction),
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
    if (state == AppLifecycleState.resumed && !_handled) {
      unawaited(ref.read(pairingScannerAdapterProvider).start());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(ref.read(pairingScannerAdapterProvider).stop());
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
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.scannerTitle),
        leading: IconButton(
          tooltip: strings.close,
          onPressed: () => ref.read(pairingControllerProvider.notifier).reset(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            tooltip: strings.toggleFlash,
            onPressed: () => unawaited(
              ref.read(pairingScannerAdapterProvider).toggleTorch(),
            ),
            icon: const Icon(Icons.flash_on_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
              child: Text(
                strings.scannerInstructions,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Semantics(
                label: strings.scannerInstructions,
                container: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(WafloRadius.large),
                  child: ref
                      .watch(pairingScannerAdapterProvider)
                      .buildPreview(context, onDetected: _detected),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
              child: OutlinedButton(
                onPressed: () => ref
                    .read(pairingControllerProvider.notifier)
                    .showManualEntry(),
                child: Text(strings.enterCodeInstead),
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
      appBar: AppBar(
        title: Text(strings.manualCodeTitle),
        leading: BackButton(
          onPressed: () => ref.read(pairingControllerProvider.notifier).reset(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('manual-pairing-code'),
            controller: _controller,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            maxLength: 512,
            decoration: InputDecoration(
              labelText: strings.manualCodeHint,
              prefixIcon: const Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton(
            onPressed: () => unawaited(
              ref
                  .read(pairingControllerProvider.notifier)
                  .submit(_controller.text),
            ),
            child: Text(strings.submitCode),
          ),
        ],
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.verified_outlined,
            size: 80,
            color: WafloColors.success,
          ),
          const SizedBox(height: WafloSpacing.lg),
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
              padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
              decoration: BoxDecoration(
                color: context.waflo.successSurface,
                borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WafloOperationalLabel(strings.verifiedByWaflo),
                  const SizedBox(height: WafloSpacing.sm),
                  Text(
                    deviceContext.organization.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.waflo.onSuccessSurface,
                    ),
                  ),
                  Text(
                    deviceContext.currentLocation.displayName,
                    style: TextStyle(color: context.waflo.onSuccessSurface),
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
                controller.showReviewAccess();
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
    'REVIEW_ACCESS_REVOKED' => strings.reviewAccessInvalid,
    'REVIEW_ACCESS_EXPIRED' => strings.reviewAccessExpired,
    'REVIEW_ACCESS_RATE_LIMITED' => strings.reviewAccessRateLimited,
    'REVIEW_TENANT_UNAVAILABLE' => strings.reviewEnvironmentUnavailable,
    _ => strings.genericError,
  };
}
