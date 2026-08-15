# Known external blockers

1. **Physical Android authorization** — ADB reports the known device as
   `unauthorized`; owner action on the unlocked phone is required before install
   or device integration tests.
2. **macOS/iOS runner** — iOS no-sign builds cannot run on this Windows host.
3. **Approved W4 runner** — real Backend contract execution must use the
   approved self-hosted runner; no alternate Backend or local substitute was
   started.
4. **Remote CI** — macOS passed on the implementation SHA. A final Linux,
   Android, and macOS rerun is pending the legacy-M1 layout-mode fix push; the
   approved W4 job has remained queued. No pending job is claimed green.
5. **Owner visual approval** — automated comparison and device installation do
   not grant owner approval.
6. **Kurdish localization authority** — no authoritative Sorani/Badini product
   source exists in the starting Mobile tree; no translation was invented.

These blockers prevent a Production Ready claim. They do not indicate a known
Backend regression, security weakening, or generated drift.
