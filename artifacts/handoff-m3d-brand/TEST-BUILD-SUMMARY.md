# Test and build summary

## Local gates

| Gate | Result |
|---|---|
| Dart format | PASS — 235 files, 0 changed |
| Flutter analyze fatal warnings | PASS — no issues |
| Unit tests | PASS — 104/104 |
| Widget tests | PASS — 28/28 |
| Golden/screenshot tests | PASS — 23/23 |
| Executable review screenshots | PASS — 60 generated |
| M2 checksums/LF | PASS — 13 files, 12 generated hashes |
| M2 bundle | PASS — `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae` |
| Production-v1 verifier | PASS — 9 required + 4 optional direct routes |
| Generated client drift | PASS |
| Localization drift | PASS |
| Brand lint | PASS |
| Security scan | PASS — 936 files with the complete handoff present locally |
| Absolute-path scan | PASS — 936 files with the complete handoff present locally |
| Historical archive scans | PASS — 393 / 589 / 573 entries |

## Android

| Build | Result | Output |
|---|---|---|
| Development debug | PASS | `build/app/outputs/flutter-apk/app-development-debug.apk` |
| Staging release | PASS | `build/app/outputs/flutter-apk/app-staging-release.apk` |
| Production release | PASS | `build/app/outputs/flutter-apk/app-production-release.apk` |

Android tooling emitted future-compatibility warnings for Gradle 8.13, Kotlin 2.2.0, and plugin migration to built-in Kotlin. These are not M3D failures and were not changed in a brand-only sprint.

The local Android integration matrix was not executed because `flutter devices` found only Windows and Chrome and `flutter emulators` found no AVD. Hosted job `94250498828` executed 24 top-level integration entries: M1 app 18, M1 pairing 3, M2 matrix 1, M3A matrix 1, and M3C matrix 1. Every entry passed. The M2 entry retains its embedded approved 24-scenario matrix.

The clean owner-review staging APK is 74,772,007 bytes with SHA-256 `c6a3efa86823c321aaa2b9f01c81ccae52f96f4a7b56e33342c1905a802385b6`. Archive inspection proves it contains `NotoSansArabic-Variable.ttf` (844,676 bytes), not the retired static font.

## iOS

iOS development/staging/production no-sign builds cannot execute on Windows. Hosted macOS job `94250531834` passed fatal analysis, 104 unit tests, 28 widget tests, localized camera-purpose checks, and all three no-sign builds.

## Hosted CI

Implementation SHA: `62ed78d037f9b381621d9809982da5c5955b9f3b`

| Run / job | Result |
|---|---|
| Main run `31637198547`, Linux job `94250498745` | PASS |
| Main run `31637198547`, Android emulator job `94250498828` | PASS |
| Main run `31637198547`, Android builds job `94250498862` | PASS |
| iOS run `31637198566`, macOS/iOS job `94250531834` | PASS |

The main workflow also created approved-runner job `94250498883`. It remains queued because the dedicated self-hosted runner is not online. M2 formal Real W4 remains closed by prior authoritative run `31487360271` (42/42); this brand-only work does not replace or reopen that historical evidence.

## Archive

Historical portable archives are scanned without rewriting them. M3D evidence contains no credentials or environment files; APKs remain build outputs and are not committed into the handoff.
