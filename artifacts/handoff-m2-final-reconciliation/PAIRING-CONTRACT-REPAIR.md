# Pairing challenge contract repair

## Root cause

The authoritative M1 OpenAPI and JSON Schema both require `signatureAlgorithm` in `DevicePairingRecoveryResponse`, with the single canonical value `Ed25519`. The generated Dart response model requires the same non-null string, and the Mobile pairing domain rejects any value other than `Ed25519` before signing.

The historical backend returned HTTP 200 from `POST /v1/staff/devices/pairing/challenge`, but its serialized `data` object contained only `challenge`, `challengeExpiresAt`, `message`, and `pairingPublicId`. `StaffDeviceService.challenge` did not return `signatureAlgorithm`. The request schema validates only `pairingPublicId`; there was no runtime response DTO/schema that could catch the omission.

Classification: `BACKEND_RUNTIME_OMISSION`.

## Contract and generator findings

- M1 `openapi.m1.json`: field required, `const: Ed25519`.
- M1 `schemas/m1.schema.json`: field required, `const: Ed25519`.
- M2 OpenAPI/generator: pairing challenge is not part of the M2 surface and did not alter the M1 contract.
- Mobile generated model: faithful to the M1 contract; it did not invent stricter nullability or casing.
- Historical M1 backend source at commit `16e0b4077510073777040450b84af9b055cf2a33` already omitted the field, so this was an M1 runtime defect inherited into M2 rather than an M2 schema regression.
- The M1 source manifest records a generator and pairing-recovery test from a historical working tree, but those files are absent from the recorded commit and from the partial W4 reconstruction. No unavailable source was claimed as recovered.

## Why backend tests passed

The selected signed-Staff HTTP helper claimed a pairing and completed it directly from the claim response. It did not call the challenge-recovery endpoint and its local response type did not include `signatureAlgorithm`. The other focused M2 suites cover contract schemas and loyalty operations, not the M1 recovery response. Consequently, all 16 backend tests could pass while the real generated Mobile consumer rejected the wire response.

## Authoritative repair

- historical backend SHA: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- repair branch: `fix/p5-m2-pairing-challenge-runtime-conformance`
- repair SHA: `dbd20acafc3d7687866256e8e950a5b978ba4e29`
- backend source change: return `signatureAlgorithm: "Ed25519"` from challenge recovery
- regression change: the existing six-test signed-Staff HTTP suite now recovers the challenge, completes pairing from the recovered payload, and asserts canonical `Ed25519`

No contract schema, contract version, M2 bundle byte, security algorithm, signing envelope, session binding, nonce/timestamp rule, Wallet behavior, or loyalty behavior changed.

The historical M2 manifest remains unchanged. The final additive verification
overlay pins the complete three-commit backend repair chain, exact four changed
backend paths/hashes, unchanged historical bundle, and unchanged M1 field
contract. A later compatibility sweep proved separate Mobile consumer defects;
those changes do not alter the pairing challenge schema or security model.

## Wire evidence

Before repair:

- challenge HTTP status: 200
- `signatureAlgorithm` present: no

After repair:

- challenge HTTP status: 200
- `signatureAlgorithm`: `Ed25519`
- pairing complete HTTP status: 200
- device, session, and context returned: yes
- sensitive values printed: no

## Regression result

- affected backend build: pass
- strengthened signed-Staff HTTP suite: 6/6 pass
- Mobile generated-client drift: pass
- Mobile pairing recovery unit tests: 4/4 pass
- exact backend Real W4 gate: 16/16 pass
- final exact Flutter Real W4 gate: 26/26 pass
- final exact backend Real W4 gate: 16/16 pass

Pairing remains a backend runtime-conformance repair. Full local compatibility
is 42/42; formal GitHub closure remains pending runner registration.
