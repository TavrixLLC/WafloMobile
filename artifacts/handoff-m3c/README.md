# Waflo Staff Mobile M3C handoff

M3C converges the launch-quality M3B Staff application on the Production-v1 Mobile authority without changing the historical M2 evidence or adding Backend behavior.

- Starting Mobile SHA: `f25f4af630d29c20ea0486088c64b7ac79849cf1`
- Branch: `feature/m3c-production-v1-convergence`
- Worktree: `.dart_tool/worktrees/m3c-production-v1`
- Backend authority: `763f2dfccdb24fb9bfa16457f0e49936840e20a1`
- Backend documentation commit: `06067d454077cdedf827f93ed0ced72d0e2e133d`
- Historical M2 bundle SHA-256: `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- Final Mobile SHA: the commit containing this handoff; record it from the branch tip.

Implemented outcomes:

- Stamp requests cannot serialize `managerOverride`.
- `PURCHASE_THRESHOLD_NOT_MET` is the current authority; the retired M2 code exists only in an explicitly isolated historical-safe localization alias.
- `OPERATION_BILLING_BLOCKED` preserves the authoritative customer projection and provides Merchant Web recovery guidance.
- Redeem-only Manager approval preserves the original semantic command and uses fresh signed transport on every retry.
- All current approval and Staff authority-loss codes have explicit domain and presentation handling.
- Expired Staff access cannot be recovered using refresh alone.
- Pairing `INTERNAL_ERROR` fails safely and redacts security material.
- Mutations remain online-only and server-authoritative.

See the sibling documents for the contract audit, security model, visual review, test/build evidence, and external blockers.
