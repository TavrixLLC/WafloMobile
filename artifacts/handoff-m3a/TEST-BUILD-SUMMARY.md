# Test and build summary

Local Windows results:

| Gate | Result |
|---|---|
| M2 contract manifest/hash/LF | PASS — 13 files, 12 hashes, exact bundle |
| generated M1/M2 client drift | PASS |
| localization generation drift | PASS |
| format | PASS — 230 files, 0 changes |
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

M3A Android integration contains one executable test with 15 product-flow
checkpoints. No local AVD is installed, so the device-bound run is correctly
pending hosted Android CI. iOS no-sign runs are correctly pending macOS CI.
