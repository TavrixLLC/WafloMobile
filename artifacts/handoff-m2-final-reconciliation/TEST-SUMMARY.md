# Test summary

Local completed gates:

- exact bundle manifest/hash/LF verification: pass
- generated-code and localization drift: pass; Windows check restores platform checkout bytes
- formatting and analyzer with fatal warnings/errors: pass
- Flutter unit/widget/golden suite: 107 pass (68 unit, 18 widget, 21 golden); 26 Real W4-only scenarios disabled locally
- Android development debug, staging release, production release: pass with authoritative entrypoints/config files
- security and absolute-path scans: pass

Blocked external gates: Android emulator matrix, hosted Android builds, macOS/iOS builds, and the approved Real W4 backend gate. The branch push was rejected with HTTP 403, so no external workflow ran.

No Android AVD is installed on the Windows development host, so Android integration results are reported only from the mandatory hosted emulator job.
