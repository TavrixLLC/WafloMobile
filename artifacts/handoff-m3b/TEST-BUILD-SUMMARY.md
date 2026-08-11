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

## Hosted launch-candidate evidence

Source SHA: `e8e2e472b36b13a3a06732f15d2c5746a25555e3`

| Workflow / job | Run / job | Result |
| --- | --- | --- |
| Flutter M3B Staff Launch Candidate — Linux quality | `31517875440` / `93867514506` | PASS — contract, drift, path, format, analyze, 83 unit, 26 widget, 22 golden, security, three CI-controlled archives |
| Flutter M3B Staff Launch Candidate — Android emulator | `31517875440` / `93867514539` | PASS — M1 18/18, pairing 3/3, M2 matrix 1/1, M3A matrix 1/1; 23/23 total |
| Flutter M3B Staff Launch Candidate — Android builds | `31517875440` / `93867514315` | PASS — development debug, staging release, production release |
| Flutter M3B iOS Launch Candidate — macOS/iOS | `31517875406` / `93867522935` | PASS — analyze, 83 unit, 26 widget, camera copy, development/staging/production no-sign |
| Approved W4 / M1 and M2 real contract gates | `31517875440` / `93867514384` | PENDING — queued with `runner_id: 0`; requires `self-hosted`, `windows`, `x64`, `waflo-w4-approved` |

The first superseded run exposed 16 stale Linux M1 visual baselines. The actual
Linux renders were reviewed, exactly those baselines were refreshed, and the
authoritative Linux job above then passed. No product assertion was weakened.

The approved Real W4 job is the only unfinished CI item. GitHub has not assigned
a runner, no local runner process/service or registered runner installation is
available to start, and the current GitHub credentials cannot list repository
runners (`403`). This is an external runner-availability condition, not a
Mobile source, contract, Android, iOS, or product-test failure.
