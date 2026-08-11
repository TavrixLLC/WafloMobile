# M3C test and build summary

## Local completed gates

| Gate | Result |
|---|---|
| M1–M3C unit suite | PASS — 99/99 |
| M1–M3C widget suite | PASS — 27/27 |
| Golden/screenshot test cases | PASS — 23/23 |
| M3C executable review images | PASS — 23/23 generated |
| Fatal Flutter analysis | PASS — zero issues |
| Dart format | PASS — zero drift |
| Historical M2 checksum/LF | PASS — 13 files, 12 generated hashes |
| Production-v1 authority verifier | PASS |
| Generated-client drift | PASS |
| Localization generation | PASS |
| Security scan | PASS — 816 tracked files |
| Absolute-path scan | PASS — 816 files |
| M1/M2/final-reconciliation archives | PASS — 393/589/573 entries |
| Android development debug APK | PASS |
| Android staging release APK | PASS |
| Android production release APK | PASS |

## Hosted gates

CI-tested implementation SHA: `7de8ab7a941e509b126ab937626cbb4e08277398`.

| Workflow/job | Run / job | Result |
|---|---|---|
| Linux quality/security/archive | `31537636409` / `93932505964` | PASS — unit 99/99, widget 27/27, golden 23/23 |
| Android emulator flow matrix | `31537636409` / `93932506105` | PASS — 24/24 tests across M1 app, M1 pairing, M2, M3A, and M3C |
| Android development/staging/production | `31537636409` / `93932505916` | PASS — three APKs |
| Approved Real W4 M1/M2 | `31537636409` / `93932506114` | PASS — Flutter 26/26 + Backend 16/16 = 42/42; Backend `966454633519bff3d9aed277ce0bcf36f17d3d60` |
| macOS tests and iOS no-sign | `31537636449` / `93932455117` | PASS — unit 99/99, widget 27/27, development/staging/production builds |

No local Android AVD is installed; desktop/web were not used as substitutes. The hosted Android emulator executed every listed integration entrypoint. The M3C scenario contains 15 explicit checkpoints covering resolve, initial redeem, required/pending approval, same-command retry, authoritative success/reset, ambiguous approved retry recovery, and billing denial without local mutation.
