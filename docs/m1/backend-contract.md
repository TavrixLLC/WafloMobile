# Backend contract

The mobile source of truth is the exact approved bundle under `contracts/w4/`.
`source-manifest.json` records backend base commit
`16e0b4077510073777040450b84af9b055cf2a33`, every consulted source hash, and
the generated bundle checksum.

M1 consumes these generated operations:

- `POST /v1/staff/devices/pairing/claim`
- `POST /v1/staff/devices/pairing/challenge`
- `POST /v1/staff/devices/pairing/complete`
- `POST /v1/staff/devices/session/refresh`
- `POST /v1/staff/devices/session/logout`
- `GET /v1/staff/device-context`

The authoritative OpenAPI also describes Staff operation endpoints for later
milestones. They are generated for drift fidelity but are not used by M1. The
deterministic generator in `tool/generate_w4_client.dart` recreates the complete
generated tree and normalizes one documented duplicate-header limitation in the
upstream generator. No generated file is hand-edited.

Pairing uses the generated client. Signed session calls use generated response
models plus a narrow exact-byte request wrapper. The updated context DTO supplies
safe display names, all assigned Locations and capabilities, device state, and
the app update policy. Stable backend state codes are
`STAFF_DEVICE_REVOKED`, `STAFF_DEVICE_COMPROMISED`,
`STAFF_DEVICE_SESSION_EXPIRED`, and `APP_UPDATE_REQUIRED`.
