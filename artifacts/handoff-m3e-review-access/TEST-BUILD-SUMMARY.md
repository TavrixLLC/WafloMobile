# Test and build summary

## Mobile

- Analyze fatal infos/warnings: PASS.
- Unit: 113/113 PASS (including the explicit scanner network-recovery regression).
- Widget: 35/35 PASS (M3E scanner/Review focused 7/7).
- Golden/screenshot test cases: 24/24 PASS; 67 PNG review evidence.
- M2 checksum/LF: PASS; Production-v1 verifier: PASS; generated-client drift: PASS.
- Brand, security, absolute-path, and three historical archive scans: PASS.
- Android development debug: PASS.
- Android staging debug: PASS; owner-installable debug-signed artifact.
- Android staging release: PASS.
- Android production release: PASS.
- Hosted Android integration: 25/25 PASS, including the M1 18-case app flow,
  M1 pairing, M2 24-scenario matrix, M3A, M3C, and M3E entry/scanner suites.
- Hosted Android development, staging release, and production release: PASS.
- Hosted macOS analysis/unit/widget/camera-copy gate: PASS.
- Hosted iOS development, staging, and production no-sign builds: PASS.

Final Mobile CI evidence for `21808e4070f728b9445c4674a38d6ff39dd88ad0`:

- Run `31756164364`: Linux job `94632233867`, Android builds
  `94632233858`, Android emulator `94632233875` — PASS.
- Run `31756164371`: macOS/iOS job `94632231299` — PASS.
- The separate historical Approved W4 job `94632233887` is queued; it is not
  an M3E Review Backend deployment or tenant-provisioning test.

## Backend

- Biome focused check: PASS.
- API typecheck: PASS.
- API build: PASS.
- M3E boundary unit: 7/7 PASS.
- Database-backed HTTP suite: AUTHORED, NOT RUN — isolated database configuration unavailable.

Review Access therefore remains unavailable in deployed staging until the
Backend branch is reviewed/deployed, a credential hash and window are securely
configured, and the isolated review tenant is provisioned.

The release builds emit non-blocking future Gradle/Kotlin migration warnings inherited from the existing toolchain.
