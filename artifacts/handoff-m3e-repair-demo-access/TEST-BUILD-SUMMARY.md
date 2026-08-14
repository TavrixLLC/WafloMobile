# Test and build summary

## Local tests

| Gate | Result |
|---|---|
| Format | PASS — 266 files, zero drift |
| Fatal analyze | PASS — no issues |
| Unit | PASS — 120/120 |
| Widget | PASS — 40/40 |
| Golden/executable screenshot | PASS — 25/25 |
| M2 checksum/LF | PASS — immutable bundle `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae` |
| Production-v1 verifier | PASS |
| Generated client drift | PASS |
| Localization drift | PASS |
| Brand lint | PASS |
| Security scan | PASS |
| Absolute-path scan | PASS |
| Historical archive scans | PASS |
| LOCAL_DEMO source exclusion | PASS |
| Staging release AOT exclusion | PASS |
| Production release AOT exclusion | PASS |

## Android

| Artifact | Result |
|---|---|
| Development debug APK | PASS |
| Staging debug APK | PASS; installed successfully on connected Android 13 device |
| Staging release APK | PASS; local Demo binary exclusion PASS |
| Production release APK | PASS; local Demo binary exclusion PASS |
| Android integration | The first hosted run exposed a missing debug composition override in the new test harness; the focused repair is committed at `964e424a0a92d2dde531bc62f36edd68dbe1dbc7`. The authoritative result is the check suite attached to the final handoff commit. |

## iOS

No local Windows iOS claim is made. The implementation run's macOS job passed fatal analysis, 120/120 unit tests, 40/40 widget tests, camera-string validation, and development/staging/production no-sign builds. The authoritative final result remains the check suite attached to the final handoff commit.

## Evidence

There are 73 executable PNGs under `screenshots/`: 6 repair-specific views, 37 current core product regressions, and 30 M3E scanner/Review Access regressions. The first visual review found no debug-looking menu, blocked target, RTL defect, dark-mode regression, or 200% text exception. The post-composition golden rerun remained 25/25.

The first hosted Linux pass confirmed all non-golden gates and identified five platform baselines whose only intentional change is the unified **Demo Access** label. Their hosted Flutter renders were visually inspected and adopted in the focused repair commit; the final handoff check suite is the closure authority.

## Physical boundary

ADB detected and installed to the connected Android device. The device remained protected by its owner OS PIN, so camera/torch/touch bug-bash execution is recorded as manual owner QA, not falsely reported as passed.
