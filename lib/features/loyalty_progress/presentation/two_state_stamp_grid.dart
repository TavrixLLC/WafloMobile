import 'package:flutter/material.dart';
import 'package:waflo_staff/core/images/digest_image_cache.dart';
import 'package:waflo_staff/features/loyalty_progress/domain/stamp_progress.dart';
import 'package:waflo_staff/features/membership_resolution/domain/resolved_membership.dart';

final class TwoStateStampGrid extends StatelessWidget {
  const TwoStateStampGrid({
    required this.progress,
    required this.artwork,
    required this.cache,
    required this.semanticLabel,
    required this.allowInsecureAssets,
    super.key,
  });

  final StampProgress progress;
  final StampArtwork artwork;
  final StampImageLoader cache;
  final String semanticLabel;
  final bool allowInsecureAssets;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = colors.surfaceContainerLow;
    final foreground = colors.primary;
    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: ColoredBox(
          color: background,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              textDirection: TextDirection.ltr,
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final slot in progress.slots)
                  _StampSlot(state: slot, foreground: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _StampSlot extends StatelessWidget {
  const _StampSlot({required this.state, required this.foreground});

  final StampSlotState state;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final filled = state == StampSlotState.filled;
    return SizedBox.square(
      dimension: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? foreground : Colors.transparent,
          border: Border.all(color: foreground, width: 2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
