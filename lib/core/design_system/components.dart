import 'package:flutter/material.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';

final class WafloPage extends StatelessWidget {
  const WafloPage({
    required this.child,
    this.appBar,
    this.padding = const EdgeInsetsDirectional.all(WafloLayout.pageGutter),
    this.tabletPadding = const EdgeInsetsDirectional.all(
      WafloLayout.tabletPageGutter,
    ),
    this.maxWidth = WafloLayout.maximumContentWidth,
    this.scrollable = true,
    super.key,
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry tabletPadding;
  final double maxWidth;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          key: const Key('waflo-page-content'),
          width: double.infinity,
          child: Padding(
            padding: context.isWafloTablet ? tabletPadding : padding,
            child: child,
          ),
        ),
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

/// A centered, bounded scroll surface for screen content that should remain
/// full-width on phones without stretching across a tablet viewport.
final class WafloResponsiveListView extends StatelessWidget {
  const WafloResponsiveListView({
    required this.children,
    this.maxWidth = WafloLayout.maximumContentWidth,
    this.compactHorizontalPadding = WafloLayout.pageGutter,
    this.topPadding = 8,
    this.bottomPadding = WafloSpacing.xl,
    this.physics,
    super.key,
  });

  final List<Widget> children;
  final double maxWidth;
  final double compactHorizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final horizontal = context.wafloPageGutter(
      compact: compactHorizontalPadding,
    );
    return ListView(
      padding: EdgeInsets.zero,
      physics: physics,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SizedBox(
              key: const Key('waflo-responsive-content'),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  horizontal,
                  topPadding,
                  horizontal,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Applies the same centered tablet geometry to non-scrolling and sliver
/// content while leaving compact layouts unchanged.
final class WafloConstrainedContent extends StatelessWidget {
  const WafloConstrainedContent({
    required this.child,
    this.maxWidth = WafloLayout.maximumContentWidth,
    this.padding = EdgeInsets.zero,
    this.contentKey,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Key? contentKey;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(
        key: contentKey,
        width: double.infinity,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

final class WafloReadyBeacon extends StatelessWidget {
  const WafloReadyBeacon({this.color, this.size = 26, super.key});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? context.waflo.brandAction;
    return Semantics(
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _FlowDot(size: size * 0.22, color: resolved, x: -size * .27),
            _FlowDot(size: size * 0.32, color: resolved, x: 0),
            _FlowDot(size: size * 0.44, color: resolved, x: size * .28),
          ],
        ),
      ),
    );
  }
}

final class WafloBrandMark extends StatelessWidget {
  const WafloBrandMark({this.size = 72, this.darkSurface = false, super.key});

  final double size;
  final bool darkSurface;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Waflo',
    child: SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: darkSurface ? WafloColors.white : WafloColors.brick,
              borderRadius: BorderRadius.circular(size * .22),
            ),
            child: Center(
              child: WafloReadyBeacon(
                color: darkSurface ? WafloColors.brick : WafloColors.white,
                size: size * .42,
              ),
            ),
          ),
          Image.asset(
            darkSurface
                ? 'assets/brand/logo/waflo-mark-white-1024.png'
                : 'assets/brand/logo/waflo-mark-primary-512.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            excludeFromSemantics: true,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}

final class WafloBrandLockup extends StatelessWidget {
  const WafloBrandLockup({
    this.width = 180,
    this.darkSurface = false,
    super.key,
  });

  final double width;
  final bool darkSurface;

  @override
  Widget build(BuildContext context) => Image.asset(
    darkSurface
        ? 'assets/brand/logo/waflo-logo-white-horizontal-1600.png'
        : 'assets/brand/logo/waflo-logo-primary-horizontal-1600.png',
    width: width,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    semanticLabel: 'Waflo',
  );
}

final class _FlowDot extends StatelessWidget {
  const _FlowDot({required this.size, required this.color, required this.x});

  final double size;
  final Color color;
  final double x;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(x, -x * .22),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    ),
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
    style: Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: color ?? context.waflo.subtleText),
  );
}

/// Direction A+ top bar: quiet navigation, no elevated app chrome.
final class WafloTopBar extends StatelessWidget {
  const WafloTopBar({
    required this.title,
    this.onBack,
    this.backTooltip,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final String? backTooltip;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 56),
    child: Row(
      children: [
        if (onBack != null) ...[
          IconButton(
            tooltip: backTooltip,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: WafloSpacing.xs),
        ],
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    ),
  );
}

/// A logical forward/detail chevron. Material mirrors this icon in RTL.
final class WafloForwardChevron extends StatelessWidget {
  const WafloForwardChevron({this.color, this.size, super.key});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.chevron_right_rounded, color: color, size: size);
}

/// Flat, coherent grouping surface used throughout the selected A+ system.
final class WafloSurfaceCard extends StatelessWidget {
  const WafloSurfaceCard({
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(WafloSpacing.lg),
    this.color,
    this.radius = WafloRadius.large,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) => Material(
    color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(radius),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
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
    final resolved = color ?? context.waflo.brandAction;
    final background = backgroundColor ?? resolved.withValues(alpha: 0.10);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(WafloRadius.medium),
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
  Widget build(BuildContext context) => WafloSurfaceCard(
    padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
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
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final background = enabled
        ? context.waflo.brandAction
        : Theme.of(context).colorScheme.surfaceContainer;
    final foreground = enabled
        ? context.waflo.onBrandAction
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title. $subtitle',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(WafloRadius.extraLarge),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const Key('primary-scan-customer'),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 188),
            child: Stack(
              children: [
                PositionedDirectional(
                  top: 22,
                  end: 24,
                  child: Opacity(
                    opacity: .22,
                    child: WafloReadyBeacon(color: foreground, size: 46),
                  ),
                ),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 48, 24, 24),
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
                      if (!largeText) ...[
                        const SizedBox(width: WafloSpacing.md),
                        Icon(icon, size: 34, color: foreground),
                      ],
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

/// Thumb-zone action used by A+ confirmation and completion surfaces.
final class WafloBottomAction extends StatelessWidget {
  const WafloBottomAction({
    required this.title,
    required this.onPressed,
    this.subtitle,
    this.keyName,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final background = enabled
        ? context.waflo.brandAction
        : Theme.of(context).colorScheme.surfaceContainer;
    final foreground = enabled
        ? context.waflo.onBrandAction
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      enabled: enabled,
      label: subtitle == null ? title : '$title. $subtitle',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(WafloRadius.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: keyName == null ? null : Key(keyName!),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: subtitle == null ? 64 : 94),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: WafloSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground.withValues(alpha: .82),
                      ),
                    ),
                  ],
                ],
              ),
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
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final labelWidget = Text(
      label,
      style: TextStyle(color: context.waflo.subtleText),
    );
    final valueWidget = Text(
      value,
      textAlign: largeText ? TextAlign.start : TextAlign.end,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: divider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            )
          : null,
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelWidget,
                const SizedBox(height: WafloSpacing.xs),
                valueWidget,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: labelWidget),
                const SizedBox(width: WafloSpacing.md),
                Flexible(child: valueWidget),
              ],
            ),
    );
  }
}
