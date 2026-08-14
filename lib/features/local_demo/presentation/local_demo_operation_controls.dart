import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalDemoScannerControlsBuilder = Widget Function();
typedef LocalDemoApprovalControlBuilder = Widget Function(String locale);

/// The defaults are deliberately inert. Debug entrypoints override these
/// builders; product entrypoints never import the fixture widgets.
final localDemoScannerControlsBuilderProvider =
    Provider<LocalDemoScannerControlsBuilder>(
      (ref) =>
          () => const SizedBox.shrink(),
    );

final localDemoApprovalControlBuilderProvider =
    Provider<LocalDemoApprovalControlBuilder>(
      (ref) =>
          (locale) => const SizedBox.shrink(),
    );

final class LocalDemoScannerControlsSlot extends ConsumerWidget {
  const LocalDemoScannerControlsSlot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(localDemoScannerControlsBuilderProvider)();
}

final class LocalDemoManagerApprovalAction extends ConsumerWidget {
  const LocalDemoManagerApprovalAction({required this.locale, super.key});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(localDemoApprovalControlBuilderProvider)(locale);
}
