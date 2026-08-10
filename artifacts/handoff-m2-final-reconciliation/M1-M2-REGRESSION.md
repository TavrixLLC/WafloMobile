# M1 and M2 regression

Local Flutter regression: 107 passed, 26 disabled Real W4 scenarios skipped because they require the approved runner/backend. Ordinary M1/M2 tests have no skipped final gate.

Locked loyalty semantics remain unchanged: 0/8 all empty, 5/8 five filled, 8/8 all filled and reward-ready outside the grid, final redemption 0/8 all empty. The grid has no third state or special slot.

Hosted Android emulator results passed: 18 M1 application tests, 3 pairing-flow tests, and the M2 integration test.

The initial exact Real W4 entrypoints executed all 42 requested tests. Backend compatibility passed 16/16, while Flutter passed 1/26 because pairing challenge omitted required `signatureAlgorithm`.

After the pairing repair, a complete failure matrix identified four additional
root-cause clusters plus a verification teardown defect. Each was repaired and
covered without weakening validation or changing loyalty economics. The final
backend gate is 16/16 and the final Flutter gate is 26/26. Reward-ready state
remains outside the two-state grid, final redemption resets immediately to
0/goal, command PROCESSING/COMPLETED/FAILED behavior is authoritative, and HTTP
426 preserves the session while blocking operations. Formal approved-runner
job `93016388147` remains canceled without executing a step.
