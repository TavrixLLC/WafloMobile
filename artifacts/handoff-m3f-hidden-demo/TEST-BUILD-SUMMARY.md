# Test and build summary

Completed in this worktree:

- Dart format and analyzer: PASS, zero issues.
- Contract checksums, production-v1 authority, generation drift, localization drift,
  absolute-path, official-brand, security, and production local-Demo exclusion:
  PASS.
- Focused M3F router/scanner/M3E regression tests: PASS, 20 tests.
- Full unit/widget/golden suite: PASS, 193 tests. The 26 real-W4 contract
  cases remained intentionally skipped because they require the separately
  approved development Backend runner.
- Reviewed golden baselines were updated only for the intended hidden-entry and
  unified-scanner changes.
- Android development debug APK: PASS.
- Android staging release APK: PASS; release local-Demo binary exclusion PASS.
- Android production release APK: PASS; release local-Demo binary exclusion
  PASS.
- Android physical-device integration matrix: PASS in portrait on Android 13.
  This includes M1 app (18 cases), M1 pairing flow (3 cases), the approved M2
  24-scenario matrix, M3A Staff flow, M3C Production-v1, M3E server-backed
  Review entry/scanner lifecycle, and M3E debug-only local Demo flow.
- Lovable directory and ZIP security verification: PASS. ZIP SHA-256:
  `cce76330f5c080470bc8acad7349f916e70a98be3ee14d739e0b04bd3c590200`.

Not completed and not claimed green:

- iOS no-sign build matrix: requires the macOS CI runner.
- Real-W4 contract execution: requires the approved Backend runner; Mobile did
  not modify or start Backend services.
- Owner physical visual approval remains pending.

Android build warnings are limited to future Flutter support changes for Gradle
8.13/Kotlin 2.2 and the existing Cupertino icon reference. They did not fail the
successful APK builds, but are not treated as Production Ready evidence.
