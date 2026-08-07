# Real W4 gate

Required backend commit: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e` on `fix/p5-m2-final-reconciliation`.

The approved self-hosted runner labels are `self-hosted`, `windows`, `x64`, and `waflo-w4-approved`. The mobile harness verifies backend identity/source hashes, a clean backend tracked tree, real signed pairing/context/loyalty/recovery/version flows, log redaction, and cleanup. It does not substitute mocks.

Status: BLOCKED before execution because the active GitHub credential cannot push the focused branch. A skipped, untriggered, or old-SHA run is not a pass.
