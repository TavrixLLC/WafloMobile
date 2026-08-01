# Backend contract

The mobile source of truth is `contracts/w4/`, derived from the approved archive. It contains the handoff, QR/signing notes, JSON Schema, stable errors, deterministic fixtures, source manifest, and an M1-only OpenAPI document.

Generated clients cover:

- `POST /v1/staff/devices/pairing/claim`
- `POST /v1/staff/devices/pairing/complete`
- `POST /v1/staff/devices/session/refresh`
- `POST /v1/staff/devices/session/logout`
- `GET /v1/staff/device-context`

The generator adapter renames the schema component `DateTime` to `IsoDateTime` and extracts the inline error body to `ApiErrorBody`; JSON wire names and values are unchanged. Pairing uses generated clients. Signed session calls use generated response models plus a manual exact-byte request wrapper.

Contract gaps are explicit: device context provides IDs, role, and platform but no display names; M1 shows safe role/platform/count without raw IDs. W4 round 1 does not define a minimum-version rejection or distinct revoked/compromised codes. `LOCATION_NOT_AUTHORIZED` and `RISK_HARD_BLOCK` remain localized catalog entries for future operational contracts but are not advertised as M1 endpoint results.
