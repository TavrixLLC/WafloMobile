# Test and build summary

## Mobile

- Analyze fatal infos/warnings: PASS.
- Unit: 112/112 PASS (M3E focused 7/7).
- Widget: 34/34 PASS (M3E focused 6/6).
- Golden/screenshot test cases: 24/24 PASS; 67 PNG review evidence.
- M2 checksum/LF: PASS; Production-v1 verifier: PASS; generated-client drift: PASS.
- Brand, security, absolute-path, and three historical archive scans: PASS.
- Android development debug: PASS.
- Android staging debug: PASS; owner-installable debug-signed artifact.
- Android staging release: PASS.
- Android production release: PASS.
- Android integration: NOT RUN — no supported device/emulator connected.
- iOS no-sign: NOT RUN locally on Windows; M3E CI workflow is prepared for macOS.

## Backend

- Biome focused check: PASS.
- API typecheck: PASS.
- API build: PASS.
- M3E boundary unit: 7/7 PASS.
- Database-backed HTTP suite: AUTHORED, NOT RUN — isolated database configuration unavailable.

The release builds emit non-blocking future Gradle/Kotlin migration warnings inherited from the existing toolchain.
