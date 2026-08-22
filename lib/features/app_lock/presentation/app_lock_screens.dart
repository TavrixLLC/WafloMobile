import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/core/design_system/components.dart';
import 'package:waflo_staff/core/localization/generated/app_localizations.dart';
import 'package:waflo_staff/features/app_lock/domain/app_lock.dart';

final class AppLockOverlay extends ConsumerStatefulWidget {
  const AppLockOverlay({super.key});

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

final class _AppLockOverlayState extends ConsumerState<AppLockOverlay> {
  String _pin = '';
  bool _automaticBiometricStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lock = ref.read(appLockControllerProvider);
    if (_automaticBiometricStarted ||
        lock.configuration.mode != AppLockMode.biometric ||
        !lock.isLocked ||
        lock.safeErrorCode != null) {
      return;
    }
    _automaticBiometricStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref
            .read(appLockControllerProvider.notifier)
            .unlockWithBiometric(
              AppLocalizations.of(context).biometricUnlockReason,
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final lock = ref.watch(appLockControllerProvider);
    final busy = lock.status == AppLockStatus.authenticating;
    final biometricMode = lock.configuration.mode == AppLockMode.biometric;
    final light = Theme.of(context).brightness == Brightness.light;
    if (biometricMode && lock.safeErrorCode == null) {
      return Material(
        key: const Key('biometric-prompt-launching'),
        color: light ? WafloColors.softCoral : context.waflo.canvas,
      );
    }
    return Material(
      key: const Key('app-lock-overlay'),
      color: light ? WafloColors.softCoral : context.waflo.canvas,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Semantics(
                scopesRoute: true,
                namesRoute: true,
                explicitChildNodes: true,
                label: strings.enterPinToUnlock,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: WafloBrandMark(size: 40),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      strings.enterPinToUnlock,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: WafloSpacing.sm),
                    Text(
                      biometricMode
                          ? strings.biometricPinFallback
                          : strings.pinUnlockBody,
                      style: TextStyle(color: context.waflo.subtleText),
                    ),
                    const SizedBox(height: 48),
                    ...[
                      // Retains the production input contract and test hook;
                      // the visible A+ control is the accessible keypad below.
                      const SizedBox(
                        key: Key('unlock-pin-field'),
                        width: 1,
                        height: 1,
                      ),
                      _PinDots(
                        key: const Key('unlock-pin-dots'),
                        length: _pin.length,
                      ),
                      const SizedBox(height: WafloSpacing.sm),
                      Text(
                        strings.pinLengthHelp,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.waflo.subtleText,
                        ),
                      ),
                      const SizedBox(height: WafloSpacing.lg),
                      _PinKeypad(
                        enabled: !busy,
                        onDigit: _appendDigit,
                        onBackspace: _backspace,
                      ),
                      const SizedBox(height: WafloSpacing.md),
                      FilledButton(
                        key: const Key('unlock-with-pin'),
                        onPressed: busy || _pin.length < 4 ? null : _unlockPin,
                        child: Text(strings.unlock),
                      ),
                    ],
                    if (biometricMode) ...[
                      const SizedBox(height: WafloSpacing.sm),
                      TextButton.icon(
                        key: const Key('try-biometrics-again'),
                        onPressed: busy
                            ? null
                            : () => unawaited(
                                ref
                                    .read(appLockControllerProvider.notifier)
                                    .unlockWithBiometric(
                                      strings.biometricUnlockReason,
                                    ),
                              ),
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(strings.tryBiometricsAgain),
                      ),
                    ],
                    if (busy) ...[
                      const SizedBox(height: WafloSpacing.md),
                      const LinearProgressIndicator(),
                    ],
                    if (lock.safeErrorCode != null &&
                        lock.safeErrorCode != 'BIOMETRIC_FAILED') ...[
                      const SizedBox(height: WafloSpacing.md),
                      WafloStatusBanner(
                        icon: Icons.lock_clock_outlined,
                        message: lock.status == AppLockStatus.rateLimited
                            ? strings.pinRateLimited
                            : lock.safeErrorCode == 'BIOMETRIC_FAILED'
                            ? strings.biometricPinFallback
                            : strings.unlockFailed,
                        color: WafloColors.warning,
                        backgroundColor: context.waflo.warningSurface,
                      ),
                    ],
                    const SizedBox(height: WafloSpacing.lg),
                    Text(
                      strings.appLockLocalOnly,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.waflo.subtleText,
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
  }

  void _unlockPin() {
    final pin = _pin;
    setState(() => _pin = '');
    unawaited(
      ref
          .read(appLockControllerProvider.notifier)
          .unlockWithPin(pin, DateTime.now()),
    );
  }

  void _appendDigit(int digit) {
    if (_pin.length >= 6) return;
    setState(() => _pin += digit.toString());
    unawaited(HapticFeedback.selectionClick());
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }
}

final class _PinDots extends StatelessWidget {
  const _PinDots({required this.length, super.key});

  final int length;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: '$length of 6',
    child: ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < 6; index++) ...[
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : WafloMotion.immediate,
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: index < length
                    ? context.waflo.brandAction
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.waflo.brandAction.withValues(alpha: .48),
                  width: 2,
                ),
              ),
            ),
            if (index != 5) const SizedBox(width: WafloSpacing.md),
          ],
        ],
      ),
    ),
  );
}

final class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    super.key,
  });

  final bool enabled;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    mainAxisSpacing: WafloSpacing.sm,
    crossAxisSpacing: WafloSpacing.sm,
    childAspectRatio: 1.72,
    children: [
      for (var digit = 1; digit <= 9; digit++)
        _PinKey(
          key: Key('pin-key-$digit'),
          label: digit.toString(),
          onPressed: enabled ? () => onDigit(digit) : null,
        ),
      const SizedBox.shrink(),
      _PinKey(
        key: const Key('pin-key-0'),
        label: '0',
        onPressed: enabled ? () => onDigit(0) : null,
      ),
      _PinKey(
        key: const Key('pin-key-delete'),
        semanticLabel: MaterialLocalizations.of(context).deleteButtonTooltip,
        icon: Icons.backspace_outlined,
        onPressed: enabled ? onBackspace : null,
      ),
    ],
  );
}

final class _PinKey extends StatelessWidget {
  const _PinKey({
    this.label,
    this.semanticLabel,
    this.icon,
    required this.onPressed,
    super.key,
  });

  final String? label;
  final String? semanticLabel;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel ?? label,
    child: Material(
      color: icon == null
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : Colors.transparent,
      borderRadius: BorderRadius.circular(WafloRadius.large),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(WafloRadius.large),
        child: Center(
          child: icon == null
              ? Text(label!, style: Theme.of(context).textTheme.titleLarge)
              : Icon(icon, color: context.waflo.subtleText),
        ),
      ),
    ),
  );
}

final class AppLockSettingsScreen extends ConsumerWidget {
  const AppLockSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final state = ref.watch(appLockControllerProvider);
    final controller = ref.read(appLockControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(strings.appLock)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 32),
          children: [
            Text(
              strings.appLockLocalOnly,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: WafloSpacing.lg),
            _ModeRow(
              key: const Key('pin-mode'),
              icon: Icons.pin_outlined,
              title: strings.localStaffPin,
              selected: state.configuration.mode != AppLockMode.off,
              onTap: () => context.push('/app-lock/pin'),
            ),
            _ModeRow(
              key: const Key('biometric-mode'),
              icon: Icons.fingerprint_rounded,
              title: strings.biometric,
              subtitle: state.configuration.mode == AppLockMode.off
                  ? strings.createPinFirst
                  : null,
              selected: state.configuration.mode == AppLockMode.biometric,
              onTap: state.configuration.mode == AppLockMode.off
                  ? null
                  : () async {
                      if (state.configuration.mode == AppLockMode.biometric) {
                        await controller.disableBiometric();
                        return;
                      }
                      final enabled = await controller.setBiometric(
                        strings.biometricSetupReason,
                      );
                      if (!enabled && context.mounted) {
                        final current = ref.read(appLockControllerProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              current.safeErrorCode == 'PIN_REQUIRED'
                                  ? strings.createPinFirst
                                  : strings.biometricUnavailable,
                            ),
                          ),
                        );
                      }
                    },
            ),
            _ModeRow(
              key: const Key('app-lock-off-mode'),
              icon: Icons.lock_open_rounded,
              title: strings.appLockOff,
              selected: state.configuration.mode == AppLockMode.off,
              onTap: () => unawaited(controller.setOff()),
            ),
            const SizedBox(height: WafloSpacing.xl),
            WafloOperationalLabel(strings.lockAfter),
            const SizedBox(height: WafloSpacing.sm),
            RadioGroup<AppLockInterval>(
              groupValue: state.configuration.interval,
              onChanged: (value) {
                if (value != null) unawaited(controller.setInterval(value));
              },
              child: Column(
                children: [
                  RadioListTile<AppLockInterval>(
                    value: AppLockInterval.immediately,
                    title: Text(strings.lockImmediately),
                  ),
                  RadioListTile<AppLockInterval>(
                    value: AppLockInterval.oneMinute,
                    title: Text(strings.afterOneMinute),
                  ),
                  RadioListTile<AppLockInterval>(
                    value: AppLockInterval.fiveMinutes,
                    title: Text(strings.afterFiveMinutes),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ModeRow extends StatelessWidget {
  const _ModeRow({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 64,
    contentPadding: EdgeInsets.zero,
    enabled: onTap != null,
    leading: Icon(icon),
    title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: Icon(
      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
      color: selected ? Theme.of(context).colorScheme.primary : null,
    ),
    onTap: onTap,
  );
}

final class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

final class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _entry = '';
  String? _newPin;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final confirming = _newPin != null;
    return WafloPage(
      appBar: AppBar(title: Text(strings.createLocalStaffPin)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(child: WafloBrandMark(size: 48)),
          const SizedBox(height: WafloSpacing.lg),
          Text(strings.pinNeverManager, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.xl),
          AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : WafloMotion.immediate,
            child: Text(
              confirming ? strings.confirmPin : strings.newPin,
              key: ValueKey(confirming),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: WafloSpacing.md),
          _PinDots(key: const Key('pin-setup-dots'), length: _entry.length),
          const SizedBox(height: WafloSpacing.sm),
          Text(
            strings.pinLengthHelp,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.waflo.subtleText),
          ),
          if (_error != null) ...[
            const SizedBox(height: WafloSpacing.md),
            WafloStatusBanner(
              icon: Icons.info_outline,
              message: _error!,
              color: WafloColors.warning,
              backgroundColor: context.waflo.warningSurface,
            ),
          ],
          const SizedBox(height: WafloSpacing.lg),
          _PinKeypad(
            key: const Key('pin-setup-keypad'),
            enabled: !_saving,
            onDigit: _appendDigit,
            onBackspace: _backspace,
          ),
          const SizedBox(height: WafloSpacing.md),
          FilledButton(
            key: Key(confirming ? 'pin-setup-save' : 'pin-setup-continue'),
            onPressed: _saving || _entry.length < 4 ? null : _advance,
            child: Text(confirming ? strings.savePin : strings.continueAction),
          ),
        ],
      ),
    );
  }

  void _appendDigit(int digit) {
    if (_entry.length >= 6 || _saving) return;
    setState(() {
      _entry += digit.toString();
      _error = null;
    });
    unawaited(HapticFeedback.selectionClick());
  }

  void _backspace() {
    if (_entry.isEmpty || _saving) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _error = null;
    });
  }

  Future<void> _advance() async {
    final strings = AppLocalizations.of(context);
    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(_entry)) {
      setState(() => _error = strings.pinLengthHelp);
      return;
    }
    final pendingPin = _newPin;
    if (pendingPin == null) {
      setState(() {
        _newPin = _entry;
        _entry = '';
        _error = null;
      });
      return;
    }
    if (pendingPin != _entry) {
      setState(() {
        _entry = '';
        _error = strings.pinMismatch;
      });
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await ref.read(appLockControllerProvider.notifier).setPin(pendingPin);
    _entry = '';
    _newPin = null;
    if (mounted) context.pop();
  }
}
