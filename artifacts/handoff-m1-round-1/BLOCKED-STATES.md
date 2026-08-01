# Blocked states

Control flow maps only authoritative stable codes:

| Code | Local action |
| --- | --- |
| `STAFF_DEVICE_REVOKED` | clear active session; retain repair evidence |
| `STAFF_DEVICE_COMPROMISED` | clear active session; retain repair evidence |
| `STAFF_DEVICE_SESSION_EXPIRED` | clear active session; require recovery |
| `APP_UPDATE_REQUIRED` | preserve identity/session; block operations |

Network errors remain retryable offline state and never become revocation.
Generic inactive responses are not guessed as compromised. The real W4 gate
creates each server state and verifies the returned code and local policy.
