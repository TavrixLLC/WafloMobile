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

## Device and hosted gates

No local Android AVD is installed; desktop/web are not valid substitutes. The CI Android emulator matrix runs M1 app, M1 pairing, M2, M3A, and M3C Production-v1 flows. iOS no-sign builds require the repository macOS workflow. Hosted run IDs and conclusions are added after the branch push.

The M3C integration scenario contains 15 explicit checkpoints covering resolve, initial redeem, required/pending approval, same-command retry, authoritative success/reset, ambiguous approved retry recovery, and billing denial without local mutation.
