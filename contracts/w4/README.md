# Waflo W4 mobile contracts

This directory is the mobile-safe W4 contract bundle for Flutter M1. It is a curated
transformation of the approved W4 backend archive; it is not a backend source copy.

## M1 contents

- `flutter-handoff.md`: implementation boundary and M1 pairing/session flow.
- `pairing-qr.md`: exact QR payload contract and handling rules.
- `signed-request.md`: canonical Ed25519 request contract and retry rules.
- `schemas/m1.schema.json`: JSON Schema 2020-12 definitions for pairing, device
  sessions, device context, signed requests, and API envelopes.
- `openapi.m1.json`: self-contained OpenAPI 3.1 subset for the six M1 Staff-device
  endpoints.
- `stable-error-codes.json`: stable machine codes and mobile recovery guidance.
- `deterministic-fixtures.json`: sanitized canonicalization, digest, QR-shape, and
  error-envelope fixtures. They contain no usable credentials or private keys.
- `source-manifest.json`: archive checksum and the exact approved entries consulted.

## Authoritative rules

1. Generate the Ed25519 key pair on the device. Never export, log, back up, or add the
   private key to this directory.
2. Treat pairing QR values, access tokens, refresh tokens, nonces, and signatures as
   sensitive. The examples here are deliberately non-secret fixtures.
3. Hash the exact UTF-8 request bytes that are sent. Do not hash one JSON serialization
   and send another.
4. Sign the exact nine-line envelope in `signed-request.md` with LF (`0x0A`)
   separators and no trailing newline.
5. On a retry, keep the operation idempotency UUID when the operation has one, but
   generate a fresh request ID, nonce, timestamp, body digest, and signature.
6. Use error `code` for control flow and localization. Server English messages are not
   localization strings.

## M1 endpoint scope

- `POST /v1/staff/devices/pairing/claim`
- `POST /v1/staff/devices/pairing/challenge`
- `POST /v1/staff/devices/pairing/complete`
- `POST /v1/staff/devices/session/refresh`
- `POST /v1/staff/devices/session/logout`
- `GET /v1/staff/device-context`

The broader W4 operation endpoints belong to later mobile milestones and are
intentionally absent from `openapi.m1.json`.
