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
    final foreground = colors.primary;
    return Semantics(
      label: semanticLabel,
      container: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = _columnCount(progress.goal);
              final spacing = progress.goal <= 4 ? 14.0 : 10.0;
              final available = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 320.0;
              final calculated =
                  (available - (spacing * (columns - 1))) / columns;
              final slotSize = calculated.clamp(40.0, 58.0);
              return Wrap(
                textDirection: TextDirection.ltr,
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var index = 0; index < progress.slots.length; index += 1)
                    _StampSlot(
                      key: ValueKey(
                        '$index:${progress.slots[index].name}:${progress.slots[index] == StampSlotState.filled ? artwork.filledAssetDigest : artwork.emptyAssetDigest}',
                      ),
                      state: progress.slots[index],
                      foreground: foreground,
                      size: slotSize,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static int _columnCount(int goal) => switch (goal) {
    <= 4 => goal,
    <= 6 => 3,
    <= 8 => 4,
    <= 10 => 5,
    _ => 6,
  };
}

final class _StampSlot extends StatelessWidget {
  const _StampSlot({
    required this.state,
    required this.foreground,
    required this.size,
    super.key,
  });

  final StampSlotState state;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = state == StampSlotState.filled;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? foreground : Colors.transparent,
          border: Border.all(color: foreground, width: filled ? 0 : 2.5),
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: filled
            ? Center(
                child: SizedBox.square(
                  dimension: size * 0.28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(size * 0.09),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
