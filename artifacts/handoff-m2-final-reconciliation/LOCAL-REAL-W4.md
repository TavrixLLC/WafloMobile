# Local Real W4 execution

This evidence records an exact local execution of the two committed Real W4 workflow entrypoints. It is functional validation only and does not substitute for the formal self-hosted GitHub job.

## Pinned inputs

- Mobile SHA: `b35ca7d973918496e13915880a492652ae6c5177`
- Backend SHA: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- Backend source manifest: 22/22 hashes verified by each gate as applicable
- Backend root: dedicated historical test checkout through `WAFLO_W4_BACKEND_ROOT`
- PowerShell: 7.6.4
- Node: 24.12.0
- pnpm: 11.5.2
- PostgreSQL service: running

## Exact commands

```text
dart run tool/run_real_w4_contract_gate.dart
dart run tool/run_real_w4_m2_contract_gate.dart
```

The required `WAFLO_RUN_BACKEND_CONTRACT=true` development-only authorization latch was enabled. No mock backend or alternate SHA was used.

## Initial results

| Gate | Executed | Passed | Failed |
| --- | ---: | ---: | ---: |
| Flutter real-contract | 26 | 1 | 25 |
| Backend compatibility | 16 | 16 | 0 |
| Total | 42 | 17 | 25 |

Every requested test actually executed. The first Flutter test (pairing claim) passed. Pairing challenge then failed because the authoritative backend response omits the required `signatureAlgorithm` field. The remaining 24 Flutter failures are downstream session-dependent failures.

This is classified as a genuine historical backend/Mobile compatibility defect, not an environment, PostgreSQL, PATH, dependency, generated-output, mock, or skipped-test issue. Neither authoritative repository was modified.

## Cleanup and integrity

- backend tracked tree: clean
- backend and Mobile HEADs: unchanged
- Mobile product source: unchanged
- remaining `waflo_test_*` databases: zero
- captured-log credential-pattern hits: zero
- machine-local repository and SDK paths in logs: redacted

## Formal GitHub closure

Run `31224658248`, job `93016388147`, is completed/cancelled with no runner and no steps. It executed 0/42 tests. Repository-admin access is still required to register an approved runner with labels `self-hosted`, `windows`, `x64`, and `waflo-w4-approved`.

## Pairing repair result

The backend runtime now returns the already-required `signatureAlgorithm: Ed25519`. A real wire audit completed the signed pairing and returned device, session, and context data. The contract schema/version and historical M2 bundle did not change.

Post-repair exact entrypoints executed all 42 tests:

| Gate | Executed | Passed | Failed |
| --- | ---: | ---: | ---: |
| Flutter real-contract | 26 | 10 | 16 |
| Backend compatibility | 16 | 16 | 0 |
| Total | 42 | 26 | 16 |

Pairing tests 1–3 pass. A subsequent full runtime sweep audited and repaired all
16 remaining Flutter failures without changing the historical contract bundle.

## Final full runtime sweep

| Gate | Executed | Passed | Failed |
| --- | ---: | ---: | ---: |
| Flutter real-contract | 26 | 26 | 0 |
| Backend compatibility | 16 | 16 | 0 |
| Total | 42 | 42 | 0 |

Every requested test executed against backend
`966454633519bff3d9aed277ce0bcf36f17d3d60`. The backend build and TypeScript
package builds passed as part of the Flutter gate. All disposable databases
were dropped. The historical GitHub job remains unexecuted, so this local pass
is functional validation only.
