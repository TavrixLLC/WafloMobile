# Review Access contract

## Authorization

`POST /v1/staff/review-access/authorize` is unsigned and rate-limited. It accepts the normal pairing claim metadata with `reviewAccessCode` replacing `pairingToken`. Code format is uppercase `XXXX-XXXX` using unambiguous letters/digits. Success returns the normal Ed25519 pairing challenge; pairing completion remains the existing endpoint and wire security model.

## Signed review endpoints

- `GET /v1/staff/review/scenarios`
- `POST /v1/staff/review/scenarios/select` with `{scenarioId, commandId}`
- `POST /v1/staff/review/reset` with `{commandId}`

The mutation command is a UUID and replay is idempotent. Reusing the same command for a different scenario returns the existing idempotency-conflict behavior. All endpoints require Device authorization, signature verification, nonce/replay checks, `REVIEW` mode, and the exact review-tenant binding.

Typed review failures include invalid, expired, revoked, rate-limited access; invalid session; invalid scenario; unavailable tenant; and reset conflict. Staff-facing Mobile copy remains safe and does not expose hashes, tenant IDs, or credentials.
