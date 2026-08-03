# Stamp operation

The selectable maximum is the minimum of the backend effective maximum, remaining progress capacity, and daily remaining allowance. The authoritative grid does not pre-fill during review; a separate projected-progress label is shown.

Confirmation creates one business UUID, writes a safe submitting journal record, clears the QR from controller memory immediately after request launch, and sends the exact payload with `x-idempotency-key` equal to that UUID. A definite pre-response retry keeps the same body and command ID while request ID, timestamp, nonce, digest, and signature are regenerated.

Success is displayed only from a committed backend receipt or a recovered `COMPLETED` command. There is no reversal, offline queue, background mutation, or automatic second stamp.
