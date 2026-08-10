# Real W4 gate

Verified identities before execution:

- backend repository: `https://github.com/TavrixLLC/Waflo.git`
- backend branch: `fix/p5-m2-final-reconciliation`
- backend SHA: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- mobile SHA: `b35ca7d973918496e13915880a492652ae6c5177`
- job: `93016388147` in run `31224658248`
- requested labels: `self-hosted`, `windows`, `x64`, `waflo-w4-approved`

The mobile harness is configured to verify backend identity/source hashes, a clean backend tracked tree, real signed pairing/context/loyalty/recovery/version flows, log redaction, and cleanup. It does not substitute mocks.

## Local exact-entrypoint execution

The following committed workflow entrypoints were executed with `WAFLO_W4_BACKEND_ROOT` bound to the dedicated historical test checkout and the development-only gate latch enabled:

- `dart run tool/run_real_w4_contract_gate.dart`
- `dart run tool/run_real_w4_m2_contract_gate.dart`

Initial historical results:

- Flutter real-contract tests: 26 executed, 1 passed, 25 failed.
- Focused backend compatibility tests: 16 executed, 16 passed.
- Total: 42 executed, 17 passed, 25 failed.
- Cleanup: all ephemeral fixture data was cleaned and all isolated `waflo_test_*` databases were dropped.
- Source integrity after execution: both pinned HEADs unchanged; backend tracked tree clean; Mobile product source unchanged.

The first Flutter failure was deterministic at pairing challenge recovery. The historical backend omitted `signatureAlgorithm`, while the authoritative M1 schema and generated Mobile client require canonical `Ed25519`.

## Runtime-conformance repair execution

- pairing repair SHA: `dbd20acafc3d7687866256e8e950a5b978ba4e29`
- final cumulative backend repair SHA: `966454633519bff3d9aed277ce0bcf36f17d3d60`
- historical backend base: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- Mobile product SHA: `b35ca7d973918496e13915880a492652ae6c5177`
- final tested Mobile verification source SHA: `b9703a1feaab42e154bff52c2bbf80970b111f56`
- contract schema/version changed: no
- historical bundle changed: no

The complete compatibility sweep repaired runtime response correlation, device
lifecycle safe errors, out-of-contract Mobile locale emission, optional pairing
metadata null emission, and an undeclared Mobile equality assumption between an
operation's committed request ID and a later HTTP envelope request ID. The
verification fixture now uses and force-drops a dedicated `waflo_test_*`
database instead of attempting to delete append-only ledger history.

Final exact gate results:

- Flutter: 26 executed, 26 passed, 0 failed
- backend: 16 executed, 16 passed
- total: 42 executed, 42 passed, 0 failed
- every requested test executed: yes
- temporary `waflo_test_*` databases after execution: zero

The full sanitized logs are `raw-test-output/local-real-w4-final-flutter-26.txt`
and `raw-test-output/local-real-w4-final-backend-16.txt`.

## Formal GitHub status

Historical job `93016388147` in run `31224658248` is `completed/cancelled`. It
never accepted a runner and contains no steps, so its exact executed count
remains 0/42. Repository-runner registration is still unavailable without
administrator permission. Local 42/42 establishes functional compatibility but
does not substitute for the formal self-hosted GitHub closure.
