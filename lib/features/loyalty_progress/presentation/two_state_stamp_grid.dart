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
          child: Wrap(
            textDirection: TextDirection.ltr,
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var index = 0; index < progress.slots.length; index += 1)
                _StampSlot(
                  key: ValueKey(
                    '$index:${progress.slots[index].name}:${progress.slots[index] == StampSlotState.filled ? artwork.filledAssetDigest : artwork.emptyAssetDigest}',
                  ),
                  state: progress.slots[index],
                  foreground: foreground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _StampSlot extends StatelessWidget {
  const _StampSlot({required this.state, required this.foreground, super.key});

  final StampSlotState state;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final filled = state == StampSlotState.filled;
    return SizedBox.square(
      dimension: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? foreground : Colors.transparent,
          border: Border.all(color: foreground, width: filled ? 0 : 2.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: filled
            ? Center(
                child: SizedBox.square(
                  dimension: 17,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
