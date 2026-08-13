# Deterministic review scenarios

The server owns exactly seven identifiers:

1. `CUSTOMER_NEW` — 0/8, eight EMPTY.
2. `CUSTOMER_ACTIVE_5_OF_8` — 5/8, five FILLED and three EMPTY.
3. `CUSTOMER_REWARD_READY_8_OF_8` — 8/8, eight FILLED; reward outside grid.
4. `MANAGER_APPROVAL_REQUIRED` — real Production-v1 required/pending presentation; Mobile never approves.
5. `PURCHASE_THRESHOLD_FAILURE` — current `PURCHASE_THRESHOLD_NOT_MET` path.
6. `BILLING_BLOCKED` — `OPERATION_BILLING_BLOCKED` without real billing.
7. `INVALID_QR` — safe invalid/expired credential presentation.

Scenario selection restores the selected fixed membership's ledger/projection deterministically. Reset restores all seven under the same review-organization lock used by loyalty mutations. Mobile accepts no arbitrary ID.
