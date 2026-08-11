# Test and build summary

## Local Windows gates

| Gate | Result |
| --- | --- |
| M2 contract/hash/LF | PASS — 13 files, 12 hashes, immutable bundle |
| generated client drift | PASS |
| localization generation | PASS |
| format | PASS — 231 files |
| fatal analysis | PASS — no issues |
| unit | PASS — 83/83 |
| widget | PASS — 26/26 |
| golden cases | PASS — 22/22 |
| executable M3B review states | PASS — 36/36 in one matrix case |
| security scan | PASS — 783 tracked files |
| absolute-path scan | PASS — 783 files |
| three CI-controlled historical portable archives | PASS |
| Android development debug | PASS — 174.7 MiB |
| Android staging release | PASS — 70.5 MiB |
| Android production release | PASS — 70.5 MiB |

No assertion was weakened. Tests add permanent-camera-denial coverage and
adaptive 4/5/6/8/10/14-goal stamp layouts. The existing Android toolchain
emitted future Gradle/Kotlin migration warnings; current artifacts completed
successfully and the warnings are not hidden.

Hosted Android emulator and macOS/iOS no-sign results are appended after the
pushed commit finishes CI.
