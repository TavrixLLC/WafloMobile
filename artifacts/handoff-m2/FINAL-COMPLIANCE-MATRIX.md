# Final compliance matrix

| Requirement | Evidence | Status |
|---|---|---|
| Approved M2 contract/checksums | `contracts/w4/m2`, verifier output | Pass |
| M1 locked foundation | M1 regression tests/workflows | Pass locally |
| Customer-only transient QR scanner | scanner source/tests/security scan | Pass |
| Strict Membership resolution | domain/unit/widget tests | Pass |
| Exact filled/empty grid | domain/renderer/goldens | Pass |
| Minor-unit purchase handling | parser/unit tests | Pass |
| Signed/idempotent mutations | API/controller tests | Pass |
| Ambiguous recovery journal | controller/restart tests | Pass |
| Rewards/final reset/Manager block | widget/controller evidence | Pass |
| EN/AR/RTL/accessibility | localization/widget/goldens | Pass |
| 25 Flutter screenshots | `screenshots/`, `screenshots.sha256` | Pass |
| Android 24-scenario integration | emulator workflow | Pending final CI |
| Android three-flavor builds | local raw outputs/build workflow | Pass locally; pending final CI |
| macOS/iOS three no-sign builds | iOS workflow | Pending final CI |
| Real approved W4 M1+M2 gates | approved self-hosted workflow | Pending final CI |
| Portable archive clean | archive scanner | Pass locally after archive generation |
| M3/M4 excluded | `NO-M3.md` | Pass |

“M2 Fully Approved” is only valid after every pending final-CI row is green on the final commit.
