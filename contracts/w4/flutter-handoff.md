# Flutter handoff — W4 / M1

## Boundary

W4 supplies the HTTP contracts, stable error identifiers, Ed25519 canonicalization
rules, and sanitized fixtures in this directory. Flutter owns camera scanning,
platform-secure key storage, secure session storage, clock/retry UX, networking, and
localization. No backend runtime code is needed by the mobile project.

## Pairing flow

1. Create an Ed25519 key pair on the device. The private key must remain
   non-exportable where the platform allows it.
2. Create or load a stable per-installation `installationId` (16–160 characters).
   Installation identity and public key cannot be reassigned after pairing.
3. Scan the one-time QR and preserve its ASCII payload exactly. Do not log or retain it
   after pairing.
4. Call `POST /v1/staff/devices/pairing/claim` with the QR payload, installation ID,
   Ed25519 public key, platform, app version, and bounded device metadata.
5. Sign the exact UTF-8 `message` returned by the claim response. The message currently
   has the `waflo-pair-challenge-v1` form documented in `pairing-qr.md`; using the
   returned value avoids re-creation differences.
6. Call `POST /v1/staff/devices/pairing/complete` with `pairingPublicId`, `challenge`,
   the unpadded base64url signature, and optional display name.
7. Store the returned access token, refresh token, session ID, device public ID,
   organization ID, and location ID in platform secure storage. Do not store them in
   logs, analytics, crash breadcrumbs, shared preferences, or source control.
8. Confirm the session with signed `GET /v1/staff/device-context`.

The challenge is short-lived (the W4 implementation issues a two-minute challenge).
Pairing is one-time and is consumed atomically on completion.

## Session lifecycle

- Every session/context request is signed and uses `Authorization: Device <token>`.
- Refresh is itself signed by the current session and includes the current refresh
  token in its JSON body.
- A successful refresh rotates both credentials and creates a new session ID. The old
  session is revoked immediately; replace all stored session values as one atomic
  update.
- Logout is signed and returns HTTP 204 with no body.
- A revoked or compromised device makes all of its sessions unusable immediately.
- `TEST_CLIENT` exists only for backend development. Flutter releases must send `IOS`
  or `ANDROID`.

## Signing and retries

Follow `signed-request.md` exactly. Query parameters are sent normally but are excluded
from `canonicalPath`. Hash the exact request body bytes; an absent body is zero bytes.

For network retries, create a new request ID, nonce, timestamp, digest, envelope, and
signature. Later operation endpoints may have an operation idempotency UUID; preserve
that UUID across retries while still regenerating request-signing values.

## Errors and localization

Branch only on `error.code` from the standard error envelope. Use `error.requestId` for
support correlation. English and Arabic UI strings belong in the Flutter localization
layer; the server message is diagnostic fallback text.

The approved W4 round-1 source stores the supplied `appVersion` but does not expose a
minimum-version rejection code or minimum-version response field in the M1 endpoints.
Do not invent one in the client contract. Handle a future code as an unknown server
error until a later approved contract adds it.

## Recommended M1 implementation order

1. Contract models and error decoding from `openapi.m1.json`.
2. Secure Ed25519 key and installation identity service.
3. Pairing QR scanner and claim/challenge/complete coordinator.
4. Atomic secure session store.
5. Exact-byte request signer and signed HTTP adapter.
6. Refresh rotation, logout, and device-context bootstrap.
7. Fixture-driven unit tests for envelope bytes, digest bytes, and retry regeneration.
