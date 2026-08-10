# Final compliance matrix

| Requirement | Result |
| --- | --- |
| M3A WIP preserved locally | PASS — commit `8fbfb14a2b34005d34d1098ee73ba118e1c25719` and backup branch retained locally |
| Clean M2 base | PASS — reconciliation began at `1d1b5f7be64f06d42f62d7af96e4f7865ae7bea7` |
| Authoritative 13-file bundle | PASS |
| Contract hashes and LF | PASS locally and from a fresh Windows worktree; intentional byte mutation rejected |
| Generated client drift | PASS locally |
| Strict purchase currency | PASS locally |
| Command recovery states | PASS locally |
| HTTP 426 update-required | PASS locally |
| iOS camera purpose copy | PASS by source inspection and macOS CI |
| M1/M2 Flutter regression | PASS locally and in hosted Linux/Android emulator jobs |
| Android builds | PASS locally and hosted: development debug, staging release, production release |
| Portable archive | PASS — 573 entries; exclusion, path, and credential scans clean |
| Hosted CI and iOS builds | PASS: Linux, Android emulator/build, and macOS/iOS jobs completed successfully |
| Pairing challenge runtime conformance | PASS: wire returns required canonical `Ed25519`; signed completion succeeds |
| Pairing focused regression | PASS: backend HTTP 6/6; Mobile pairing unit 4/4; generated drift clean |
| Contract schema/version preservation | PASS: historical M1/M2 schemas, version, and M2 bundle unchanged |
| Local Real W4 functional execution | PASS: all 42 executed and passed; backend 16/16, Flutter 26/26 |
| Remaining Real W4 compatibility | PASS: all 16 post-pairing Flutter failures were root-caused and repaired |
| Backend build/typecheck | PASS as part of the exact Flutter gate |
| Disposable database cleanup | PASS: zero `waflo_test_*` databases remain; append-only ledger guard preserved |
| Formal approved-runner GitHub closure | BLOCKED: job `93016388147` completed/cancelled without a runner; 0/42 executed |
| No M3A features | PASS by changed-path and diff review |

Local functional compatibility is complete. Full approval remains withheld only
until an approved self-hosted runner executes the formal GitHub Real W4 job.
