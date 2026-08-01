# Final compliance matrix

| Requirement | Evidence | Result |
| --- | --- | --- |
| Authoritative W4 bundle | `contracts/w4/source-manifest.json`, `UPDATED-W4-CONTRACT.md` | PASS |
| Generated source drift | `tool/generate_w4_client.dart --check` | PASS locally and CI |
| Pairing challenge recovery | `PAIRING-RECOVERY.md`, 4 recovery unit tests, Android cases 04-06 | PASS |
| Versioned lifecycle recovery | `LOCAL-SECURE-STATE.md`, boot/session tests | PASS |
| Native/Dart flavor binding | `FLAVOR-BINDING.md`, environment tests, Android case 17 | PASS |
| Safe authoritative context | `DEVICE-CONTEXT.md`, unit/widget/golden/Android case 10 | PASS |
| Real blocked states | `BLOCKED-STATES.md`, real W4 cases 07-10 | PASS |
| App integration | 18-case matrix + 3 focused Android tests | PASS 21/21 |
| Real W4 gate | `REAL-BACKEND-CONTRACT.md`, raw output | PASS 11/11 |
| Android builds | development debug, staging release, production release | PASS locally and CI |
| iOS no-sign builds | macOS workflow | PASS CI |
| GitHub hosted jobs | `CI-RUNS.md` | PASS Linux, Android emulator, Android builds, macOS |
| Approved W4 CI job | `CI-RUNS.md` | QUEUED; approved runner unavailable |
| Archive hygiene | `ARCHIVE-INSPECTION.md` | PASS locally and Linux CI |
| No M2 | `NO-M2.md` | PASS |

M1 is not labeled “Fully Approved” in this handoff until the queued approved W4
CI job is accepted by its restricted runner and passes 11/11.
