# Test and build summary

Local Windows results:

| Gate | Result |
|---|---|
| M2 contract manifest/hash/LF | PASS — 13 files, 12 hashes, exact bundle |
| generated M1/M2 client drift | PASS |
| localization generation drift | PASS |
| format | PASS — 231 files, 0 changes |
| fatal analysis | PASS — no issues |
| unit | PASS — 82/82 |
| widget | PASS — 25/25 |
| M1 golden cases | PASS — 20/20 |
| M2 golden review states | PASS — 25/25 captured in one matrix case |
| M3A review states | PASS — 26/26 captured in one executable case |
| security scan | PASS |
| absolute-path scan | PASS |
| Android development debug APK | PASS |
| Android staging release APK | PASS |
| Android production release APK | PASS |

Hosted evidence for implementation SHA
`837d89544127f117c926b93635abe181b0afe23d`:

| Gate | Result | Evidence |
|---|---|---|
| Linux quality/security/archive | PASS — 82 unit, 25 widget, 22 golden cases | Run `31506890089`, job `93830654853` |
| Android emulator matrix | PASS — M1 18, pairing 3, M2 1 matrix, M3A 1 matrix | Run `31506890089`, job `93830655005` |
| Android development/staging/production | PASS — three APKs | Run `31506890089`, job `93830654843` |
| macOS tests | PASS — 82 unit, 25 widget | Run `31506890053`, job `93830650477` |
| iOS development/staging/production no-sign | PASS — three builds | Run `31506890053`, job `93830650477` |

- Mobile CI: <https://github.com/TavrixLLC/WafloMobile/actions/runs/31506890089>
- iOS CI: <https://github.com/TavrixLLC/WafloMobile/actions/runs/31506890053>

No local AVD was installed and Windows was not used to claim iOS execution.
The Android matrix and iOS no-sign validation above are hosted results. The
separate approved W4 job in the M3A run remains queued; the immutable M2
baseline was already formally closed by run `31487360271` at 42/42.
