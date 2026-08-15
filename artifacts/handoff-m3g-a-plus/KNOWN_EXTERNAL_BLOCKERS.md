# Known external blockers

1. **Physical Android authorization** — ADB reports the known device as
   `unauthorized`; owner action on the unlocked phone is required before install
   or device integration tests.
2. **Approved W4 runner** — the real Backend contract job remains queued on the
   approved self-hosted runner; no alternate Backend or local substitute was
   started and W4 is not claimed green.
3. **Owner visual approval** — automated comparison and device installation do
   not grant owner approval.
4. **Kurdish localization authority** — no authoritative Sorani/Badini product
   source exists in the starting Mobile tree; no translation was invented.

Hosted Linux, Android build, Android emulator/integration, and macOS/iOS gates
passed on validated implementation SHA `52e34a7`. The blockers above prevent a
Production Ready claim; they do not indicate a known Backend regression,
security weakening, or generated drift.
