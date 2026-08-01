# Testing

The M1 suites separately cover 41 unit tests, 10 widget tests, 20 golden tests,
21 Android app-integration tests, and 11 real W4 contract tests.

The 18-case app matrix boots the real application with controlled Riverpod
overrides. It covers fresh install, English/Arabic pairing, claim restart,
challenge recovery, completion, restoration, single-flight refresh, old-token
rejection, multiple Locations, all blocked states, retry, logout, recovery,
environment mismatch, and large text. Three focused Android tests cover the
end-to-end pairing lifecycle, interrupted claim, and fail-closed persistence.
Production still defaults to `mobile_scanner`; tests inject an explicit fake
scanner adapter.

`test/contract/real_backend_contract_test.dart` is executed only by
`tool/run_real_w4_contract_gate.dart`. The runner verifies every backend source
checksum, builds approved W4, starts it in development mode, creates temporary
pairings, and runs claim, challenge, complete, context, refresh, old-token
rejection, revoked, compromised, session-expired, update-required, and logout
checks. All QR, key, token, and control values are ephemeral and redacted. The
fixture deletes temporary devices, sessions, nonces, Location bindings, risk
signals, and pairing rows.

The ordinary suite deliberately reports the external contract file as skipped
when the gate is not enabled. The final real-W4 CI job calls the runner and
therefore cannot treat that skip as a pass.
