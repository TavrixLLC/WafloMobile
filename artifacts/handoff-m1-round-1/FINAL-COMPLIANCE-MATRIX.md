# Final compliance matrix

| Requirement | Evidence | Result |
| --- | --- | --- |
| Authoritative W4 bundle | `contracts/w4/source-manifest.json`, `UPDATED-W4-CONTRACT.md` | PASS |
| Generated source drift | `tool/generate_w4_client.dart --check` | PASS locally |
| Pairing challenge recovery | `PAIRING-RECOVERY.md`, 4 recovery unit tests, Android cases 04-06 | PASS |
| Versioned lifecycle recovery | `LOCAL-SECURE-STATE.md`, boot/session tests | PASS |
| Native/Dart flavor binding | `FLAVOR-BINDING.md`, environment tests, Android case 17 | PASS |
| Safe authoritative context | `DEVICE-CONTEXT.md`, unit/widget/golden/Android case 10 | PASS |
| Real blocked states | `BLOCKED-STATES.md`, real W4 cases 07-10 | PASS |
| App integration | 18-case matrix + 3 focused Android tests | PASS 21/21 |
| Real W4 gate | `REAL-BACKEND-CONTRACT.md`, raw output | PASS 11/11 |
| Android builds | development debug, staging release, production release | PASS locally |
| iOS no-sign builds | macOS workflow | PENDING external CI |
| GitHub Actions green | `CI-RUNS.md` | PENDING actual runs |
| Archive hygiene | `ARCHIVE-INSPECTION.md` | completed when archive is generated |
| No M2 | `NO-M2.md` | PASS |

M1 is not labeled “Fully Approved” in this handoff until the external macOS and
GitHub checks are actually green.
