# Waflo Mobile M2 final reconciliation

This handoff records the mobile reconciliation against the authoritative repaired W4 M2 contract from backend commit `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`.

The adopted aggregate bundle SHA-256 is `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`. The reconstruction is classified `PARTIAL_W4_RECOVERY_WITH_M2_COMPATIBILITY_RECONSTRUCTION`: the missing historical patch is not represented as recovered.

This directory contains Mobile-track evidence. It contains no backend source,
credentials, usable QR, customer data, runtime journal, or M3A implementation.

Hosted Linux, Android emulator/build, and macOS/iOS gates passed on mobile SHA `b35ca7d973918496e13915880a492652ae6c5177`.

The pairing omission was classified `BACKEND_RUNTIME_OMISSION` and repaired at
`dbd20acafc3d7687866256e8e950a5b978ba4e29`. The cumulative runtime-conformance
backend is `966454633519bff3d9aed277ce0bcf36f17d3d60`; it also restores signed
response correlation and distinct device lifecycle error codes. The Mobile
verification branch corrects three proven consumer/generator defects and
isolates the real Flutter gate in a disposable database.

Local Real W4 now passes 42/42: Flutter 26/26 and backend 16/16. All tests
executed against real HTTP routes and the exact cumulative backend; no mock or
skip was substituted. Contract schema/version and the historical M2 bundle are
unchanged. This is functional evidence, not formal GitHub closure. Historical
job `93016388147` remains canceled at 0/42 pending approved-runner registration.
