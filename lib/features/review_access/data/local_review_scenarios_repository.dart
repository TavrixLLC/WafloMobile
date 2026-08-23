import 'package:waflo_staff/features/review_access/domain/review_access.dart';

/// Safe, deterministic data used only by the local Review tooling UI.
final class LocalReviewScenariosRepository implements ReviewAccessRepository {
  const LocalReviewScenariosRepository();

  static const values = <ReviewScenarioSummary>[
    ReviewScenarioSummary(
      id: ReviewScenario.customerNew,
      progress: 0,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.customerActive,
      progress: 5,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.customerRewardReady,
      progress: 8,
      goal: 8,
      rewardReady: true,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.managerApprovalRequired,
      progress: 8,
      goal: 8,
      rewardReady: true,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.purchaseThresholdFailure,
      progress: 5,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.billingBlocked,
      progress: 5,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'ACTIVE',
    ),
    ReviewScenarioSummary(
      id: ReviewScenario.invalidQr,
      progress: 0,
      goal: 8,
      rewardReady: false,
      credentialStatus: 'LOCAL_FIXTURE',
    ),
  ];

  @override
  Future<List<ReviewScenarioSummary>> scenarios() async => values;

  @override
  Future<ReviewScenarioSummary> select(ReviewScenario scenario) async =>
      values.firstWhere((value) => value.id == scenario);

  @override
  Future<int> reset() async => values.length;
}
