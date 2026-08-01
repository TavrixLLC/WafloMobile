# Test summary

| Layer | Count | Result |
| --- | ---: | --- |
| M1 unit | 41 | PASS locally and on Linux/macOS CI |
| M1 widget | 10 | PASS locally and on Linux/macOS CI |
| M1 golden | 20 | PASS locally and strict Linux CI |
| M1 Android app integration | 21 | PASS locally on API 36 and hosted CI on API 29 |
| Real W4 contract | 11 | PASS; not skipped |

Android builds:

- development debug APK: PASS
- staging release APK: PASS locally (68.0 MB) and in CI
- production release APK: PASS locally (68.0 MB) and in CI

iOS development debug, staging release, and production release no-sign builds:
PASS on macOS 26 CI.

Local Flutter 3.41.9/Dart 3.11.5 required a temporary Riverpod 3.3.2 compatibility
resolution for execution. The repository has been restored to its declared
Flutter 3.44.8/Dart 3.12/Riverpod 3.4.2 resolution; CI is the authoritative check
for that final toolchain. The final Flutter 3.44.8 CI checks passed. Raw outputs
are under `raw-test-output/`.
