# Test summary

| Layer | Count | Local result |
| --- | ---: | --- |
| M1 unit | 41 | PASS |
| M1 widget | 10 | PASS |
| M1 golden | 20 | PASS |
| M1 Android app integration | 21 | PASS on API 36 emulator |
| Real W4 contract | 11 | PASS; not skipped |

Android builds:

- development debug APK: PASS
- staging release APK: PASS, 68.0 MB
- production release APK: PASS, 68.0 MB

iOS builds: not runnable on the local Windows host; actual macOS CI result is
pending and is not claimed.

Local Flutter 3.41.9/Dart 3.11.5 required a temporary Riverpod 3.3.2 compatibility
resolution for execution. The repository has been restored to its declared
Flutter 3.44.8/Dart 3.12/Riverpod 3.4.2 resolution; CI is the authoritative check
for that final toolchain. Raw outputs are under `raw-test-output/`.
