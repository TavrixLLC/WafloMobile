# Test and build summary

## Green local gates

- Format: PASS, 272 Dart files checked, zero changes.
- Flutter analyze fatal infos/warnings: PASS, zero issues.
- Unit: PASS, 124/124.
- Widget: PASS, 44/44.
- M3G golden matrix: PASS, 1 matrix test / 38 stable screenshots.
- Historical M1 screenshot matrix: PASS, 20/20 layout/semantics cases; the
  immutable M1 pixels are available only through the explicit
  `WAFLO_COMPARE_LEGACY_M1_GOLDENS` reproduction switch.
- M2 contract/checksum gate: PASS.
- Production-v1 Mobile authority gate: PASS.
- Generated client drift: PASS; zero resulting diff.
- Localization generated drift: no M3G localization changes.
- Absolute-path scan: PASS, 1,304 tracked files.
- Official-brand lint: PASS.
- Security/secret scan: PASS, 1,304 tracked files.
- Local-Demo source exclusion: PASS.
- Portable archive scans: PASS for three historical bundles and the 86-entry
  owner reference archive.
- Android development debug APK: PASS.
- Android staging debug APK with `config/staging.json`: PASS.
- Android staging release APK: PASS.
- Android production release APK: PASS.
- Staging and production release APK local-Demo binary exclusion: PASS.

## Evidence counts

- A+ reference screenshots: 28.
- Flutter M3G screenshots: 38.
- Total M3G comparison screenshots: 66.
- Flutter screenshot bytes: 1,630,334.

## Hosted CI on validated implementation SHA `52e34a7`

- Linux quality/brand/security/archive: PASS. Contract and generated drift,
  absolute-path, brand, format, fatal analyze, unit, widget, golden, security,
  and historical archive steps all completed successfully.
- Android builds: PASS. Development debug, staging release, production release,
  and release LOCAL_DEMO binary exclusion all completed successfully.
- Android emulator integration: PASS. The authoritative M1–M3E Staff flow
  matrix completed, including M3C recovery and both M3E Review/Local Demo flows.
- macOS/iOS: PASS. Fatal analyze, unit, widget, localized camera-purpose strings,
  and development/staging/production no-sign builds all completed successfully.
- Approved real-W4 contract job: **QUEUED** on the approved self-hosted runner.
  The parent workflow therefore remains queued; no substitute runner was used
  and W4 is not claimed green.

## Pending physical/owner gates

- Android physical install: blocked by ADB `unauthorized` until the owner
  unlocks the device and approves USB debugging.
- Owner physical visual approval: pending and separate from automated evidence.

Known non-failing build warnings concern future Gradle/Kotlin support and the
existing Cupertino icon reference. Neither the hosted successes nor M3G
completion are treated as Production Ready evidence.
