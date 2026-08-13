enum ReviewScenario {
  customerNew('CUSTOMER_NEW'),
  customerActive('CUSTOMER_ACTIVE_5_OF_8'),
  customerRewardReady('CUSTOMER_REWARD_READY_8_OF_8'),
  managerApprovalRequired('MANAGER_APPROVAL_REQUIRED'),
  purchaseThresholdFailure('PURCHASE_THRESHOLD_FAILURE'),
  billingBlocked('BILLING_BLOCKED'),
  invalidQr('INVALID_QR');

  const ReviewScenario(this.wireValue);
  final String wireValue;

  static ReviewScenario parse(String value) => values.firstWhere(
    (scenario) => scenario.wireValue == value,
    orElse: () => throw const FormatException('Unknown review scenario.'),
  );
}

final class ReviewScenarioSummary {
  const ReviewScenarioSummary({
    required this.id,
    required this.progress,
    required this.goal,
    required this.rewardReady,
    required this.credentialStatus,
  });

  final ReviewScenario id;
  final int progress;
  final int goal;
  final bool rewardReady;
  final String credentialStatus;
}

abstract interface class ReviewAccessRepository {
  Future<List<ReviewScenarioSummary>> scenarios();
  Future<ReviewScenarioSummary> select(ReviewScenario scenario);
  Future<int> reset();
}
