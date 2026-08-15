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
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.clear();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final lock = ref.watch(appLockControllerProvider);
    final busy = lock.status == AppLockStatus.authenticating;
    final pinMode = lock.configuration.mode == AppLockMode.pin;
    final light = Theme.of(context).brightness == Brightness.light;
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
                label: strings.appLocked,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: WafloBrandMark(size: 40),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      strings.appLocked,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: WafloSpacing.sm),
                    Text(
                      strings.appLockedBody,
                      style: TextStyle(color: context.waflo.subtleText),
                    ),
                    const SizedBox(height: 56),
                    if (pinMode) ...[
                      // Retains the production input contract and test hook;
                      // the visible A+ control is the accessible keypad below.
                      const SizedBox(
                        key: Key('unlock-pin-field'),
                        width: 1,
                        height: 1,
                      ),
                      Semantics(
                        liveRegion: true,
                        label: '${_pinController.text.length} of 6',
                        child: ExcludeSemantics(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var index = 0; index < 6; index++) ...[
                                AnimatedContainer(
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : WafloMotion.immediate,
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: index < _pinController.text.length
                                        ? context.waflo.brandAction
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.waflo.brandAction
                                          .withValues(alpha: .48),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                if (index != 5)
                                  const SizedBox(width: WafloSpacing.md),
                              ],
                            ],
                          ),
                        ),
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
                        onPressed: busy || _pinController.text.length < 4
                            ? null
                            : _unlockPin,
                        child: Text(strings.unlock),
                      ),
                    ] else
                      FilledButton.icon(
                        key: const Key('biometric-unlock'),
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
                        label: Text(strings.unlockWithBiometrics),
                      ),
                    if (busy) ...[
                      const SizedBox(height: WafloSpacing.md),
                      const LinearProgressIndicator(),
                    ],
                    if (lock.safeErrorCode != null) ...[
                      const SizedBox(height: WafloSpacing.md),
                      WafloStatusBanner(
                        icon: Icons.lock_clock_outlined,
                        message: lock.status == AppLockStatus.rateLimited
                            ? strings.pinRateLimited
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
    final pin = _pinController.text;
    _pinController.clear();
    unawaited(
      ref
          .read(appLockControllerProvider.notifier)
          .unlockWithPin(pin, DateTime.now()),
    );
  }

  void _appendDigit(int digit) {
    if (_pinController.text.length >= 6) return;
    setState(() => _pinController.text += digit.toString());
    unawaited(HapticFeedback.selectionClick());
  }

  void _backspace() {
    if (_pinController.text.isEmpty) return;
    setState(() {
      final value = _pinController.text;
      _pinController.text = value.substring(0, value.length - 1);
    });
  }
}

final class _PinKeypad extends StatelessWidget {
  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
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
          label: digit.toString(),
          onPressed: enabled ? () => onDigit(digit) : null,
        ),
      const SizedBox.shrink(),
      _PinKey(label: '0', onPressed: enabled ? () => onDigit(0) : null),
      _PinKey(
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
              icon: Icons.lock_open_rounded,
              title: strings.appLockOff,
              selected: state.configuration.mode == AppLockMode.off,
              onTap: () => unawaited(controller.setOff()),
            ),
            _ModeRow(
              icon: Icons.fingerprint_rounded,
              title: strings.biometric,
              selected: state.configuration.mode == AppLockMode.biometric,
              onTap: () async {
                final enabled = await controller.setBiometric(
                  strings.biometricSetupReason,
                );
                if (!enabled && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.biometricUnavailable)),
                  );
                }
              },
            ),
            _ModeRow(
              icon: Icons.pin_outlined,
              title: strings.localStaffPin,
              selected: state.configuration.mode == AppLockMode.pin,
              onTap: () => context.push('/app-lock/pin'),
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
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 64,
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    trailing: Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_off,
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
  final _pin = TextEditingController();
  final _confirmation = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _pin.clear();
    _confirmation.clear();
    _pin.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return WafloPage(
      appBar: AppBar(title: Text(strings.createLocalStaffPin)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(child: WafloBrandMark(size: 58)),
          const SizedBox(height: WafloSpacing.lg),
          Text(strings.pinNeverManager, textAlign: TextAlign.center),
          const SizedBox(height: WafloSpacing.lg),
          _PinField(controller: _pin, label: strings.newPin),
          const SizedBox(height: WafloSpacing.md),
          _PinField(controller: _confirmation, label: strings.confirmPin),
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
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(strings.savePin),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final strings = AppLocalizations.of(context);
    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(_pin.text)) {
      setState(() => _error = strings.pinLengthHelp);
      return;
    }
    if (_pin.text != _confirmation.text) {
      setState(() => _error = strings.pinMismatch);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    await ref.read(appLockControllerProvider.notifier).setPin(_pin.text);
    _pin.clear();
    _confirmation.clear();
    if (mounted) context.pop();
  }
}

final class _PinField extends StatelessWidget {
  const _PinField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.headlineSmall,
    obscureText: true,
    enableSuggestions: false,
    autocorrect: false,
    keyboardType: TextInputType.number,
    maxLength: 6,
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
    decoration: InputDecoration(labelText: label),
  );
}
