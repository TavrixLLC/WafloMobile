import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waflo_staff/app/providers.dart';
import 'package:waflo_staff/core/errors/app_failure.dart';
import 'package:waflo_staff/features/review_access/domain/review_access.dart';

final class ReviewToolsState {
  const ReviewToolsState({
    this.loading = false,
    this.scenarios = const [],
    this.selected,
    this.failure,
    this.resetComplete = false,
  });

  final bool loading;
  final List<ReviewScenarioSummary> scenarios;
  final ReviewScenario? selected;
  final AppFailure? failure;
  final bool resetComplete;
}

final class ReviewAccessController extends Notifier<ReviewToolsState> {
  Future<void>? _operation;

  @override
  ReviewToolsState build() => const ReviewToolsState();

  Future<void> load() => _singleFlight(_load);

  Future<void> _load() async {
    state = ReviewToolsState(
      loading: true,
      scenarios: state.scenarios,
      selected: state.selected,
    );
    try {
      final scenarios = await ref
          .read(reviewAccessRepositoryProvider)
          .scenarios();
      state = ReviewToolsState(scenarios: scenarios, selected: state.selected);
    } on AppFailure catch (failure) {
      state = ReviewToolsState(scenarios: state.scenarios, failure: failure);
    }
  }

  Future<void> select(ReviewScenario scenario) => _singleFlight(() async {
    state = ReviewToolsState(
      loading: true,
      scenarios: state.scenarios,
      selected: state.selected,
    );
    try {
      await ref.read(reviewAccessRepositoryProvider).select(scenario);
      state = ReviewToolsState(scenarios: state.scenarios, selected: scenario);
    } on AppFailure catch (failure) {
      state = ReviewToolsState(
        scenarios: state.scenarios,
        selected: state.selected,
        failure: failure,
      );
    }
  });

  Future<void> resetFixtures() => _singleFlight(() async {
    state = ReviewToolsState(
      loading: true,
      scenarios: state.scenarios,
      selected: state.selected,
    );
    try {
      await ref.read(reviewAccessRepositoryProvider).reset();
      final scenarios = await ref
          .read(reviewAccessRepositoryProvider)
          .scenarios();
      state = ReviewToolsState(scenarios: scenarios, resetComplete: true);
    } on AppFailure catch (failure) {
      state = ReviewToolsState(
        scenarios: state.scenarios,
        selected: state.selected,
        failure: failure,
      );
    }
  });

  Future<void> _singleFlight(Future<void> Function() action) {
    final running = _operation;
    if (running != null) return running;
    final operation = action();
    _operation = operation;
    unawaited(
      operation.whenComplete(() {
        if (identical(_operation, operation)) _operation = null;
      }),
    );
    return operation;
  }
}
