import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum WafloHaptic {
  scanDetected,
  operationConfirmed,
  operationSuccess,
  rewardReady,
  warning,
  operationFailure,
}

enum PlatformHapticPattern { selection, light, medium }

extension WafloHapticPattern on WafloHaptic {
  PlatformHapticPattern get platformPattern => switch (this) {
    WafloHaptic.scanDetected => PlatformHapticPattern.selection,
    WafloHaptic.operationConfirmed => PlatformHapticPattern.light,
    WafloHaptic.operationSuccess => PlatformHapticPattern.medium,
    WafloHaptic.rewardReady => PlatformHapticPattern.medium,
    WafloHaptic.warning => PlatformHapticPattern.light,
    WafloHaptic.operationFailure => PlatformHapticPattern.medium,
  };
}

abstract interface class HapticService {
  Future<void> play(WafloHaptic event);
}

final class PlatformHapticService implements HapticService {
  const PlatformHapticService();

  @override
  Future<void> play(WafloHaptic event) async {
    try {
      await switch (event.platformPattern) {
        PlatformHapticPattern.selection => HapticFeedback.selectionClick(),
        PlatformHapticPattern.light => HapticFeedback.lightImpact(),
        PlatformHapticPattern.medium => HapticFeedback.mediumImpact(),
      };
    } on FlutterError {
      // Haptics are an optional signal and must never block a Staff action.
    } on MissingPluginException {
      // Some test/desktop hosts do not provide a platform haptic channel.
    }
  }
}

final class FakeHapticService implements HapticService {
  final List<WafloHaptic> events = [];

  @override
  Future<void> play(WafloHaptic event) async => events.add(event);
}
