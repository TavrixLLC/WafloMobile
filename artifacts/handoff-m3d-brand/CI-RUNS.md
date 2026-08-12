# Hosted CI evidence

CI-tested implementation SHA: `62ed78d037f9b381621d9809982da5c5955b9f3b`

## Mobile main workflow

Run: [31637198547](https://github.com/TavrixLLC/WafloMobile/actions/runs/31637198547)

| Job | Job ID | Status | Conclusion |
|---|---:|---|---|
| Linux / M1-M3D quality, brand, security, archive | `94250498745` | completed | success |
| Android emulator / M1-M3D Staff flow matrix | `94250498828` | completed | success |
| Android / M3D development, staging, production | `94250498862` | completed | success |
| Approved W4 / M1 and M2 real contract gates | `94250498883` | queued | not executed — dedicated runner offline |

The Linux job passed analysis, contract/provenance checks, generated and localization drift, official brand lint, 104 unit tests, 28 widget tests, 23 golden tests, security, absolute-path, and three archive scans.

The Android emulator job passed 24 top-level integration entries across the M1 app, M1 pairing, M2, M3A, and M3C suites. The Android build job produced development debug, staging release, and production release artifacts.

## iOS workflow

Run: [31637198566](https://github.com/TavrixLLC/WafloMobile/actions/runs/31637198566)

| Job | Job ID | Status | Conclusion |
|---|---:|---|---|
| macOS / M1-M3D tests and three no-sign builds | `94250531834` | completed | success |

The job passed fatal analysis, 104 unit tests, 28 widget tests, localized camera-purpose checks, and development/staging/production no-sign builds.

## Real W4 scope note

M2 was formally closed before M3D by run `31487360271` with 42/42 real-contract tests. M3D changes presentation, native brand assets, fonts, and visual-test infrastructure; it does not modify the API contract, signing, idempotency, or loyalty semantics. Queued M3D job `94250498883` is recorded accurately and is not represented as executed or passed.
