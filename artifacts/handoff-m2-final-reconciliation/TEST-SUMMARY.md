# Test summary

Local completed gates:

- exact bundle manifest/hash/LF verification: pass
- generated-code and localization drift: pass; Windows check restores platform checkout bytes
- formatting and analyzer with fatal warnings/errors: pass
- Flutter unit/widget/golden suite: 107 pass (68 unit, 18 widget, 21 golden); 26 Real W4-only scenarios disabled locally
- Android development debug, staging release, production release: pass with authoritative entrypoints/config files
- security and absolute-path scans: pass

Hosted external results:

- Linux quality job `93016388146`: 68 unit + 18 widget + 21 golden = 107 tests; contract/LF, drift, analyze, security, absolute-path, and all three archive scans passed
- Android emulator job `93016388183`: 18 M1 app + 3 M1 pairing + 1 M2 integration test = 22 tests, all passed
- Android build job `93016388081`: development debug, staging release, and production release APKs passed
- macOS/iOS job `93016388364`: 68 unit + 18 widget = 86 tests; camera localization and development/staging/production no-sign builds passed
- Real W4 job `93016388147`: completed/cancelled without a runner; 0 tests executed

Initial local exact Real W4 execution against historical backend SHA:

- Flutter real-contract gate: 26 executed; 1 passed and 25 failed
- focused backend compatibility gate: 16 executed and passed
- combined: 42 executed; 17 passed and 25 failed
- first/root failure: backend pairing-challenge response omits the required `signatureAlgorithm`; remaining Flutter failures cascade from the missing signed session
- cleanup: verified; no isolated `waflo_test_*` database remained
- source: pinned SHAs unchanged, backend tracked tree clean, Mobile product source unchanged

Pairing runtime-conformance repair regressions:

- affected backend build: pass
- strengthened signed-Staff HTTP suite: 6/6 pass
- Mobile generated-client drift: pass
- Mobile pairing recovery unit tests: 4/4 pass
- post-repair wire pairing: challenge 200 with `Ed25519`; complete 200
- pairing-only repair checkpoint: Flutter 10/26 and backend 16/16
- full runtime failure matrix: recorded before subsequent repairs
- final exact Flutter gate: 26 executed and passed
- post-repair exact backend gate: 16/16 passed
- final combined: 42 executed and passed; no skips or mocks
- focused Mobile request/result/generator regressions: 17/17 passed
- backend build and relevant typecheck: pass
- generated-client drift: pass
- strict format and fatal analyzer: pass
- cleanup: zero `waflo_test_*` databases
- tracked backend tree: clean at `966454633519bff3d9aed277ce0bcf36f17d3d60`
- contract bundle: unchanged and verified at
  `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- security/absolute-path scans: pass across 662 scanned tracked files with all
  final evidence staged

No Android AVD is installed on the Windows development host, so Android integration results are reported from the successful hosted emulator job.
