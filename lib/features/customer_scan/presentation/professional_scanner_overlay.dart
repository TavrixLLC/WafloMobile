import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:waflo_staff/core/design_system/app_theme.dart';
import 'package:waflo_staff/features/customer_scan/domain/scanner_state_machine.dart';

final class ProfessionalScannerOverlay extends StatefulWidget {
  const ProfessionalScannerOverlay({
    required this.state,
    required this.semanticLabel,
    super.key,
  });

  final CustomerScannerState state;
  final String semanticLabel;

  @override
  State<ProfessionalScannerOverlay> createState() =>
      _ProfessionalScannerOverlayState();
}

/// Shared Waflo scanner control used by pairing, normal loyalty scanning and
/// local Demo. Mode changes capabilities, never the scanner's visual language.
final class WafloScannerRoundAction extends StatelessWidget {
  const WafloScannerRoundAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final radius = label == null ? 24.0 : 16.0;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xE61E1817),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: label == null ? 12 : 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  if (label != null) ...[
                    const SizedBox(width: WafloSpacing.xs),
                    Text(
                      label!,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
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

final class WafloScannerStatusPill extends StatelessWidget {
  const WafloScannerStatusPill({
    required this.label,
    required this.busy,
    super.key,
  });

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xCC091713),
          borderRadius: BorderRadius.circular(WafloRadius.pill),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            if (busy)
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: WafloColors.coral,
                ),
              )
            else
              const Icon(
                Icons.center_focus_strong_rounded,
                size: 18,
                color: WafloColors.coral,
              ),
            const SizedBox(width: WafloSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Keeps scanner guidance and controls close to the capture area. Wide
/// windows use an anchored two-part control deck; compact scanner geometry is
/// intentionally unchanged.
final class WafloScannerControlDeck extends StatelessWidget {
  const WafloScannerControlDeck({
    required this.instruction,
    required this.status,
    required this.actions,
    super.key,
  });

  final String instruction;
  final Widget status;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final instructionText = Text(
      instruction,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        shadows: const [Shadow(blurRadius: 8)],
      ),
    );
    if (!context.isWafloWide) {
      return Column(
        key: const Key('scanner-compact-control-deck'),
        mainAxisSize: MainAxisSize.min,
        children: [
          instructionText,
          const SizedBox(height: WafloSpacing.md),
          status,
          const SizedBox(height: WafloSpacing.md),
          actions,
        ],
      );
    }
    return Container(
      key: const Key('scanner-wide-control-deck'),
      padding: const EdgeInsetsDirectional.all(WafloSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xD9141110),
        borderRadius: BorderRadius.circular(WafloRadius.large),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                instructionText,
                const SizedBox(height: WafloSpacing.sm),
                Align(child: status),
              ],
            ),
          ),
          const SizedBox(width: WafloSpacing.xl),
          Flexible(flex: 5, child: actions),
        ],
      ),
    );
  }
}

final class _ProfessionalScannerOverlayState
    extends State<ProfessionalScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beam;

  bool get _scannerActive =>
      widget.state == CustomerScannerState.ready ||
      widget.state == CustomerScannerState.scanning;

  @override
  void initState() {
    super.initState();
    _beam = AnimationController(vsync: this, duration: WafloMotion.scannerBeam);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(ProfessionalScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _syncMotion();
  }

  void _syncMotion() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_scannerActive && !reduceMotion) {
      if (!_beam.isAnimating) unawaited(_beam.repeat(reverse: true));
    } else {
      _beam.stop();
      _beam.value = 0.5;
    }
  }

  @override
  void dispose() {
    _beam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Semantics(
      image: true,
      label: widget.semanticLabel,
      child: RepaintBoundary(
        key: const Key('professional-scanner-overlay'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablet = context.isWafloTablet;
            final shortest = math.min(
              constraints.maxWidth,
              constraints.maxHeight * (tablet ? 0.64 : 0.58),
            );
            final size = (shortest - (tablet ? 64 : 48)).clamp(
              208.0,
              tablet ? 420.0 : 316.0,
            );
            final rect = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight * (tablet ? 0.46 : 0.45),
              ),
              width: size,
              height: size,
            );
            return CustomPaint(
              key: Key(
                _beam.isAnimating
                    ? 'scanner-beam-animated'
                    : 'scanner-beam-static',
              ),
              painter: _ScannerOverlayPainter(
                target: rect,
                animation: _beam,
                beamVisible: _scannerActive,
                detected:
                    widget.state == CustomerScannerState.candidateCaptured ||
                    widget.state == CustomerScannerState.resolving ||
                    widget.state == CustomerScannerState.customerResolved,
              ),
            );
          },
        ),
      ),
    ),
  );
}

final class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.target,
    required this.animation,
    required this.beamVisible,
    required this.detected,
  }) : super(repaint: animation);

  final Rect target;
  final Animation<double> animation;
  final bool beamVisible;
  final bool detected;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Offset.zero & size);
    final opening = Path()
      ..addRRect(RRect.fromRectAndRadius(target, const Radius.circular(28)));
    final dimmed = Path.combine(PathOperation.difference, outer, opening);
    canvas.drawPath(dimmed, Paint()..color = const Color(0xA6241916));
    canvas.save();
    canvas.clipPath(dimmed);
    final texture = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 18) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        texture,
      );
    }
    canvas.restore();

    final frameColor = detected ? WafloColors.success : WafloColors.coral;
    canvas.drawRRect(
      RRect.fromRectAndRadius(target, const Radius.circular(28)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..color = frameColor.withValues(alpha: 0.34),
    );
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = detected ? 4.5 : 4
      ..strokeCap = StrokeCap.round
      ..color = frameColor;
    const cornerLength = 38.0;
    const radius = 28.0;
    final left = target.left;
    final top = target.top;
    final right = target.right;
    final bottom = target.bottom;
    canvas.drawPath(
      Path()
        ..moveTo(left + cornerLength, top)
        ..lineTo(left + radius, top)
        ..quadraticBezierTo(left, top, left, top + radius)
        ..lineTo(left, top + cornerLength),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right - radius, top)
        ..quadraticBezierTo(right, top, right, top + radius)
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLength)
        ..lineTo(left, bottom - radius)
        ..quadraticBezierTo(left, bottom, left + radius, bottom)
        ..lineTo(left + cornerLength, bottom),
      cornerPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - cornerLength)
        ..lineTo(right, bottom - radius)
        ..quadraticBezierTo(right, bottom, right - radius, bottom)
        ..lineTo(right - cornerLength, bottom),
      cornerPaint,
    );

    if (beamVisible) {
      final inset = target.deflate(18);
      final y = inset.top + inset.height * animation.value;
      final beamRect = Rect.fromLTRB(inset.left, y - 1, inset.right, y + 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(beamRect, const Radius.circular(2)),
        Paint()..color = WafloColors.coral.withValues(alpha: 0.72),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) =>
      oldDelegate.target != target ||
      oldDelegate.beamVisible != beamVisible ||
      oldDelegate.detected != detected;
}
