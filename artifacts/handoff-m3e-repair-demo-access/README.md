# M3E unified Demo Access repair

Status: implementation complete; owner physical interaction requires the connected phone to be unlocked.

- Starting Mobile SHA: `6dcd313793c5ddd5ac4e1b9d251d906cc5d651cb`
- Branch: `feature/m3e-repair-unified-demo-access`
- Implementation SHA: `964e424a0a92d2dde531bc62f36edd68dbe1dbc7`
- Backend changed: no
- Existing server-backed Review Access changed: no
- Historical M2 bundle changed: no

One secondary Pairing action is now presented as **Demo Access**. Development and staging debug builds enter a deterministic `LOCAL_DEMO` presentation session. Release builds retain the existing server-backed Review credential/session flow.

The local path uses the real Waflo Home, scanner, customer, stamp, redeem, approval, success, App Lock, Device & Security, Settings, Arabic, dark, and large-text presentation. It creates no Device access token, refresh token, fake Staff session, or Backend mutation.

Evidence:

- 26 fixed scenarios
- 73 executable screenshots (6 repair-specific, 37 current core regressions, 30 M3E regressions)
- 120 unit tests passed locally
- 40 widget tests passed locally
- 25 golden/screenshot tests passed locally
- Android development debug, staging debug, staging release, and production release built
- staging and production release AOT binaries passed local-Demo exclusion inspection

See the other files in this directory for architecture, production exclusion, scenario catalog, scanner QA, owner steps, and exact verification results.
