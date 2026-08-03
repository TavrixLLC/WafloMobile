# Real W4 contract gate

The CI job requires the approved self-hosted Windows runner, exact backend commit and source checksums, `WAFLO_W4_BACKEND_ROOT`, and explicit gate authorization. It runs the established M1 real gate and `tool/run_real_w4_m2_contract_gate.dart`, which verifies backend commit `16e0b4077510073777040450b84af9b055cf2a33` and every M2 manifest source before invoking the backend-owned real M2 quality gate.

This gate cannot be executed on an unapproved workstation without the controlled W4 environment. Final status and run URL must be recorded in `CI-RUNS.md`; it must not be described as skipped or passed before that run is green.
