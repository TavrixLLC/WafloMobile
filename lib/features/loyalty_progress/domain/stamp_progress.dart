enum StampSlotState { filled, empty }

final class StampProgress {
  const StampProgress({required this.progress, required this.goal})
    : assert(goal > 0),
      assert(progress >= 0 && progress <= goal);

  final int progress;
  final int goal;

  List<StampSlotState> get slots => List<StampSlotState>.generate(
    goal,
    (index) => index < progress ? StampSlotState.filled : StampSlotState.empty,
    growable: false,
  );

  static StampProgress validated({required int progress, required int goal}) {
    if (goal <= 0 || progress < 0 || progress > goal) {
      throw const FormatException('INVALID_STAMP_PROJECTION');
    }
    return StampProgress(progress: progress, goal: goal);
  }
}
