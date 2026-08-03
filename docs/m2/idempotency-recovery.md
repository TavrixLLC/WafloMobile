# Idempotency and ambiguous recovery

One active mutation is allowed. Its business UUID is stable across transport retry and command-status recovery. Fresh request metadata and signatures are generated for every HTTP attempt, while the exact business body and idempotency key remain unchanged.

The versioned one-entry journal is not an offline queue. It stores command ID, operation type, Membership public ID, safe operation fields, timestamps, and status; never QR, access/refresh token, signature, nonce, customer name, or full merchant reference.

`PROCESSING` remains pending. `COMPLETED` displays the original authoritative receipt. `FAILED` maps the stable code. `NOT FOUND` requires a customer rescan before any further attempt. Records expire after the documented seven-day support window and are cleared after acknowledgment/logout; device revocation clears them safely.
