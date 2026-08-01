# CI runs

| Field | Value |
| --- | --- |
| Branch | `feature/m1-repair-round-1` |
| Source/archive commit SHA | `8dc7410` |
| Linux job | PASS — [job 91411337872](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919900/job/91411337872) |
| Android emulator job | PASS, 18 + 3 = 21 tests on API 29 — [job 91411337879](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919900/job/91411337879) |
| Android build job | PASS, development debug + staging release + production release — [job 91411337862](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919900/job/91411337862) |
| Real W4 job | QUEUED for `[self-hosted, windows, x64, waflo-w4-approved]`; no approved runner accepted it — [job 91411337902](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919900/job/91411337902) |
| macOS job | PASS, analysis + 41 unit + 10 widget + three no-sign builds — [run 30715919895](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919895) |
| Main workflow | Hosted jobs PASS; workflow remains queued solely for approved W4 — [run 30715919900](https://github.com/TavrixLLC/WafloMobile/actions/runs/30715919900) |

The local real W4 gate passed 11/11 against the authoritative backend and was
not skipped. It is not substituted for the queued approved-runner job, so this
handoff does not claim the overall workflow or M1 as fully approved.
