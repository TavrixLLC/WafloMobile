# Demo and Review production exclusion

M3F behavior survives M3G.

- Ordinary users see no Demo Access, Review Access, Test Mode, Developer Mode,
  or Owner Mode entry on Pairing, Home, Settings, scanner chrome, or navigation.
- Authorized entry remains: normal Scanner → Enter code manually → typed
  manual-code routing.
- Development/staging DEBUG may inject the untracked deterministic local owner
  code through the existing debug-only composition.
- Production has no local Demo runtime, route table, simulation controls,
  manual-code matcher, master code, or hardcoded secret.
- Production/review remains server-backed.
- Demo simulation controls appear only after LOCAL_DEMO authorization and only
  in allowed debug composition.

Verification:

- Source production-exclusion gate: PASS.
- M3F hidden-entry/scanner widget regressions: PASS.
- Staging release APK binary exclusion: PASS.
- Production release APK binary exclusion: PASS.
- Windows CRLF portability of the source gate was repaired without changing
  its security policy.
