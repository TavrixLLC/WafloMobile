import 'package:flutter/material.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';

final class WafloPage extends StatelessWidget {
  const WafloPage({
    required this.child,
    this.appBar,
    this.padding = const EdgeInsetsDirectional.all(WafloSpacing.lg),
    this.scrollable = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(padding: padding, child: child),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(child: content)
            : SizedBox.expand(child: content),
      ),
    );
  }
}

final class WafloReadyBeacon extends StatelessWidget {
  const WafloReadyBeacon({this.color, this.size = 26, super.key});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.waflo.counter;
    return Semantics(
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: resolved,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Center(
            child: SizedBox.square(
              dimension: size * 0.36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(size * 0.08),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class WafloBrandMark extends StatelessWidget {
  const WafloBrandMark({super.key});

  @override
  Widget build(BuildContext context) => const Align(
    child: SizedBox.square(dimension: 72, child: WafloReadyBeacon(size: 72)),
  );
}

final class WafloScanFrame extends StatelessWidget {
  const WafloScanFrame({
    this.size = 252,
    this.color = Colors.white,
    this.strokeWidth = 4,
    this.cornerLength = 38,
    super.key,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    key: const Key('customer-scanner-frame'),
    dimension: size,
    child: Stack(
      children: [
        _ScanCorner(
          alignment: AlignmentDirectional.topStart,
          color: color,
          strokeWidth: strokeWidth,
          length: cornerLength,
        ),
        _ScanCorner(
          alignment: AlignmentDirectional.topEnd,
          quarterTurns: 1,
          color: color,
          strokeWidth: strokeWidth,
          length: cornerLength,
        ),
        _ScanCorner(
          alignment: AlignmentDirectional.bottomEnd,
          quarterTurns: 2,
          color: color,
          strokeWidth: strokeWidth,
          length: cornerLength,
        ),
        _ScanCorner(
          alignment: AlignmentDirectional.bottomStart,
          quarterTurns: 3,
          color: color,
          strokeWidth: strokeWidth,
          length: cornerLength,
        ),
      ],
    ),
  );
}

final class _ScanCorner extends StatelessWidget {
  const _ScanCorner({
    required this.alignment,
    required this.color,
    required this.strokeWidth,
    required this.length,
    this.quarterTurns = 0,
  });

  final AlignmentGeometry alignment;
  final Color color;
  final double strokeWidth;
  final double length;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: RotatedBox(
      quarterTurns: quarterTurns,
      child: SizedBox.square(
        dimension: length,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              top: BorderSide(color: color, width: strokeWidth),
              start: BorderSide(color: color, width: strokeWidth),
            ),
          ),
        ),
      ),
    ),
  );
}

final class WafloOperationalLabel extends StatelessWidget {
  const WafloOperationalLabel(this.label, {this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: color ?? context.waflo.subtleInk),
  );
}

final class WafloStatusBanner extends StatelessWidget {
  const WafloStatusBanner({
    required this.icon,
    required this.message,
    this.color,
    this.backgroundColor,
    super.key,
  });

  final IconData icon;
  final String message;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.waflo.counter;
    final background = backgroundColor ?? resolved.withValues(alpha: 0.10);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(WafloRadius.compact),
          border: BorderDirectional(
            start: BorderSide(color: resolved, width: 4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: resolved),
            const SizedBox(width: WafloSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

final class WafloInfoCard extends StatelessWidget {
  const WafloInfoCard({
    required this.title,
    required this.child,
    this.icon,
    super.key,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(WafloRadius.card),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: WafloSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: WafloSpacing.sm),
        child,
      ],
    ),
  );
}

final class WafloPrimaryActionPanel extends StatelessWidget {
  const WafloPrimaryActionPanel({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.icon = Icons.qr_code_scanner_rounded,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = enabled
        ? context.waflo.counter
        : Theme.of(context).colorScheme.surfaceContainer;
    final foreground = enabled
        ? context.waflo.onCounter
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title. $subtitle',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(WafloRadius.stage),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('primary-scan-customer'),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 184),
            child: Stack(
              children: [
                PositionedDirectional(
                  top: 22,
                  start: 22,
                  child: _ScannerCorner(color: foreground),
                ),
                PositionedDirectional(
                  bottom: 22,
                  end: 22,
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: _ScannerCorner(color: foreground),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 48, 28, 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: foreground),
                            ),
                            const SizedBox(height: WafloSpacing.sm),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: foreground.withValues(alpha: 0.82),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: WafloSpacing.md),
                      Icon(icon, size: 34, color: foreground),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 28,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: color, width: 3),
          start: BorderSide(color: color, width: 3),
        ),
      ),
    ),
  );
}

final class WafloSummaryRow extends StatelessWidget {
  const WafloSummaryRow({
    required this.label,
    required this.value,
    this.divider = true,
    super.key,
  });

  final String label;
  final String value;
  final bool divider;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: divider
        ? BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          )
        : null,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: context.waflo.subtleInk)),
        ),
        const SizedBox(width: WafloSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
