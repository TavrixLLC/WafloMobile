# Canonical signed-request contract

## Constants

- Envelope version: `waflo-device-request-v1`
- Signature: Ed25519 over the UTF-8 envelope bytes
- Body digest: lowercase SHA-256 hex of the exact transmitted body bytes
- Signature encoding: unpadded base64url
- Line separator: LF (`\n`, byte `0x0A`)
- Trailing newline: none

## Required headers

| Header | Value |
| --- | --- |
| `Authorization` | `Device <opaque access token>` |
| `X-Waflo-Device-Id` | `device.publicId` from pairing completion |
| `X-Waflo-Device-Session-Id` | current `session.id` |
| `X-Waflo-Request-Id` | unique request ID, UUID recommended |
| `X-Waflo-Timestamp` | ISO-8601 timestamp, UTC recommended |
| `X-Waflo-Nonce` | fresh unpredictable value, at most 128 characters |
| `X-Waflo-Body-Sha256` | 64 lowercase hexadecimal characters |
| `X-Waflo-Signature` | unpadded base64url Ed25519 signature |

`X-Request-Id` is accepted by W4 as a fallback, but the mobile contract always emits
`X-Waflo-Request-Id`.

## Exact envelope

The signed payload is exactly these nine lines:

```text
waflo-device-request-v1
<UPPERCASE_METHOD>
<PATH_WITHOUT_QUERY_OR_FRAGMENT>
<REQUEST_ID>
<ISO_TIMESTAMP>
<NONCE>
<LOWERCASE_BODY_SHA256>
<DEVICE_SESSION_ID>
<ORGANIZATION_ID>
```

Allowed methods are `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`. The path starts with
`/`, excludes query and fragment, and is at most 512 characters. Every field must be a
single line without CR, LF, or NUL.

## Exact-body rule

Serialize a JSON body once to UTF-8 bytes, compute SHA-256 over those bytes, and send
the same bytes. Do not let a later HTTP layer reformat or re-encode the JSON. For a
request with no body, hash zero bytes:

```text
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

## Verification and retry behavior

W4 verifies the opaque session, active device/member state, development-client policy,
clock window, body digest, Ed25519 signature, and then inserts the `(device, nonce)`
record before the handler runs. Reusing a nonce returns
`STAFF_DEVICE_NONCE_REPLAYED` with HTTP 409.

Every retry gets a fresh request ID, nonce, timestamp, digest, and signature. When a
later operation endpoint has an idempotency UUID, preserve only that operation UUID
across retries. Never resend a captured signed envelope.

Never log the Authorization value, refresh token, QR token, signature, nonce, raw
secret-bearing body, or private key.
