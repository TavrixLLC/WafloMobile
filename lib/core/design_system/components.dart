import 'package:flutter/material.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';

final class WafloPage extends StatelessWidget {
  const WafloPage({required this.child, this.appBar, super.key});

  final PreferredSizeWidget? appBar;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(WafloSpacing.lg),
            child: child,
          ),
        ),
      ),
    ),
  );
}

final class WafloBrandMark extends StatelessWidget {
  const WafloBrandMark({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    excludeSemantics: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const SizedBox.square(
        dimension: 72,
        child: Icon(Icons.loyalty_outlined, size: 40),
      ),
    ),
  );
}

final class WafloStatusBanner extends StatelessWidget {
  const WafloStatusBanner({
    required this.icon,
    required this.message,
    this.color,
    super.key,
  });

  final IconData icon;
  final String message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
        decoration: BoxDecoration(
          color: resolved.withValues(alpha: 0.1),
          border: Border.all(color: resolved),
          borderRadius: BorderRadius.circular(WafloRadius.button),
        ),
        child: Row(
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon),
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
    ),
  );
}
