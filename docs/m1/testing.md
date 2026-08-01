# Testing

Automated suites cover environment policy; QR bounds/version/environment; Ed25519/SPKI; challenge and canonical fixtures; exact body hashes; nonce/timestamp; corrupt secure records; atomic replacement; single-flight refresh and failure; logout; error mapping; redaction; locale persistence; RTL; safe context; pairing UI; paired/settings/blocked/offline screens; large text; and secret-free visible/semantic behavior.

`integration_test/m1_pairing_flow_test.dart` uses explicit fakes to cover fresh install, claim/sign/complete, persistence, restart, context, refresh, revocation response, logout, claim interruption, and post-completion storage failure. It requires an Android/iOS runner and is scheduled on an Android emulator in CI.

`test/contract/real_backend_contract_test.dart` is opt-in. It requires `WAFLO_RUN_BACKEND_CONTRACT`, a local development URL, and a freshly seeded one-time QR through compile-time defines. It creates ephemeral key material, performs pairing/context/refresh/logout, and otherwise skips with a clear reason.

Golden tests are supplemental; widget semantics remain separate assertions.
