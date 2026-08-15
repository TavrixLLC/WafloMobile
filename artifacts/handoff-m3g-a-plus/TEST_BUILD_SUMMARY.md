# Test and build summary

## Green local gates

- Format: PASS, 272 Dart files checked, zero changes.
- Flutter analyze fatal infos/warnings: PASS, zero issues.
- Unit: PASS, 124/124.
- Widget: PASS, 44/44.
- M3G golden matrix: PASS, 1 matrix test / 38 stable screenshots.
- M2 contract/checksum gate: PASS.
- Production-v1 Mobile authority gate: PASS.
- Generated client drift: PASS; zero resulting diff.
- Localization generated drift: no M3G localization changes.
- Absolute-path scan: PASS, 1,290 tracked files.
- Official-brand lint: PASS.
- Security/secret scan: PASS, 1,290 tracked files.
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

## Pending external/platform gates

- Android physical install/integration: blocked by ADB `unauthorized` until the
  owner unlocks the device and approves USB debugging.
- Full historical golden layout job: pending Linux CI; historical evidence was
  not overwritten on Windows.
- iOS no-sign development/staging/production builds: pending macOS CI.
- Approved real-W4 contract gates: pending the approved self-hosted runner
  after a branch push; no substitute runner was used.
- Owner physical visual approval: pending and separate.

Known non-failing build warnings concern future Gradle/Kotlin support and the
existing Cupertino icon reference. They are not treated as Production Ready
evidence.
