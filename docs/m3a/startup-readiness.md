# Startup and readiness

Startup resolves one deterministic state before showing operational content:

- `BOOTING`
- `DEVICE_NOT_PAIRED`
- `DEVICE_READY`
- `DEVICE_PENDING`
- `DEVICE_REVOKED`
- `DEVICE_COMPROMISED`
- `SESSION_EXPIRED`
- `NETWORK_UNAVAILABLE`
- `UPDATE_REQUIRED`
- `APP_LOCKED`
- `FATAL_CONFIGURATION_ERROR`

Revoked, compromised, expired, and update-required states have distinct safe
copy and cannot be bypassed by navigation. HTTP 426 with
`STAFF_APP_VERSION_UNSUPPORTED` maps to Update Required without deleting the
device identity, logging out, or forcing re-pairing. Unlock refreshes the
authoritative device context before Staff operations continue.
