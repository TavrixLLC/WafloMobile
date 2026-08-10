# CI runs

Remote branch `fix/m2-mobile-final-reconciliation` was verified at `b35ca7d973918496e13915880a492652ae6c5177` before external-gate inspection.

| Workflow | Run ID | Job | Job ID | Branch | Source SHA | Status | Conclusion |
| --- | ---: | --- | ---: | --- | --- | --- | --- |
| Flutter M2 Online Loyalty Operations | [31224658248](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248) | Linux / generation, analysis, tests, security, archive | [93016388146](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248/job/93016388146) | `fix/m2-mobile-final-reconciliation` | `b35ca7d973918496e13915880a492652ae6c5177` | completed | success |
| Flutter M2 Online Loyalty Operations | [31224658248](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248) | Android emulator / M1 regression and M2 matrix | [93016388183](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248/job/93016388183) | `fix/m2-mobile-final-reconciliation` | `b35ca7d973918496e13915880a492652ae6c5177` | completed | success |
| Flutter M2 Online Loyalty Operations | [31224658248](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248) | Android / development debug and release builds | [93016388081](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248/job/93016388081) | `fix/m2-mobile-final-reconciliation` | `b35ca7d973918496e13915880a492652ae6c5177` | completed | success |
| Flutter M2 Online Loyalty Operations | [31224658248](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248) | Approved W4 / M1 and M2 real contract gates | [93016388147](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658248/job/93016388147) | `fix/m2-mobile-final-reconciliation` | `b35ca7d973918496e13915880a492652ae6c5177` | completed | cancelled |
| Flutter M2 iOS | [31224658284](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658284) | macOS / unit, widget, and three no-sign builds | [93016388364](https://github.com/TavrixLLC/WafloMobile/actions/runs/31224658284/job/93016388364) | `fix/m2-mobile-final-reconciliation` | `b35ca7d973918496e13915880a492652ae6c5177` | completed | success |

Run `31224658248` is completed/cancelled because its mandatory Real W4 job never accepted a runner; that job contains no steps and executed 0/42 tests. Run `31224658284` is completed/success. No duplicate workflow was dispatched or rerun.

The exact gate entrypoints were executed locally on 2026-08-10 for functional
evidence. The initial historical run was 17/42, and the pairing-only checkpoint
was 26/42. After the complete runtime compatibility sweep, Flutter passed 26/26
and backend passed 16/16: 42/42 executed and passed. Local execution is not a
GitHub workflow/job; formal closure remains pending approved-runner registration
and a successful replacement/rerun of the historical job.
