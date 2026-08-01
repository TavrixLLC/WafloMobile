# Real backend contract

Run from the mobile repository with an exact approved W4 checkout:

```text
WAFLO_RUN_BACKEND_CONTRACT=true
WAFLO_W4_BACKEND_ROOT=<approved W4 checkout>
dart run tool/run_real_w4_contract_gate.dart
```

The runner verifies every backend source hash from the mobile manifest, builds
the real W4 API, starts it only in development mode against a local database,
uses a unique rate-limit namespace, and exposes a loopback-only authenticated
fixture controller. The controller creates pairing sessions from seeded Staff
and Location data.

Eleven checks pass: claim, challenge, complete, context, refresh, old-refresh
rejection, revoked, compromised, session expired, update required, and logout.
All private keys, QR values, device tokens, and control secrets are ephemeral.
Output is redacted. Cleanup removes temporary sessions, devices, nonces,
Location assignments, risk signals, approval rows, and pairing rows. Raw passing
output is in `raw-test-output/real-w4-contract.log`.
