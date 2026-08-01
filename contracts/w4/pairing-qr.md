# Pairing QR contract

## Payload

The QR contains one ASCII token, not a URL and not JSON:

```text
waflo-pair-v1.<base64url(UTF8 pairing UUID)>.<base64url one-time secret>.<base64url(UTF8 environment ID)>
```

The token created by W4 uses an unpadded 32-byte base64url secret. The total claim
value is accepted only between 80 and 512 characters. The server also binds it to its
environment and stored SHA-256 hash.

The whole QR value is a short-lived credential even though some segments are not
secret. Treat it as opaque: do not decode it to make authorization decisions, do not
display its segments, and do not derive `pairingPublicId` from it. Use the ID returned
by the claim endpoint.

## Claim request

`POST /v1/staff/devices/pairing/claim` is public and rate-limited. It receives:

- `pairingToken`: exact scanned QR payload.
- `installationId`: stable per installation, trimmed, 16–160 characters.
- `publicKey`: Ed25519 SubjectPublicKeyInfo DER encoded with standard Base64. W4 also
  accepts PEM, but DER Base64 is the portable Flutter representation.
- `platform`: `IOS` or `ANDROID` for Flutter (`TEST_CLIENT` is development-only).
- `appVersion`: trimmed, 1–40 characters.
- optional `osVersion` up to 80 characters and `model` up to 120 characters.

Unknown JSON properties are rejected.

## Challenge

Claim returns `challenge`, `challengeExpiresAt`, and the exact `message` to sign. The
current message is four lines with LF separators and no trailing newline:

```text
waflo-pair-challenge-v1
<pairingPublicId>
<challenge>
<installationId>
```

Sign the UTF-8 bytes of the returned `message` with Ed25519 and encode the 64-byte
signature as unpadded base64url. If the client must recover the current challenge
before expiry, send `pairingPublicId` to
`POST /v1/staff/devices/pairing/challenge` and sign its returned `message`.

## Complete

Send `pairingPublicId`, the unchanged `challenge`, the signature, and an optional
trimmed display name (1–120 characters) to
`POST /v1/staff/devices/pairing/complete`.

Completion atomically consumes the pairing session and returns:

- public device identity and platform/status;
- opaque access and refresh tokens plus session ID and expiry;
- organization, role, and authoritative location context.

Delete the scanned token and transient challenge after a conclusive completion. A
timeout is not conclusive: query/retry with the same pairing ID only while the
challenge is valid, and never reuse an old pairing token after an already-used error.
