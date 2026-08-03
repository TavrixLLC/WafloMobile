# ADR 0002: Command journal is not an offline queue

Status: Accepted

The one-entry journal exists solely to resolve a mutation whose outcome is uncertain. It cannot accept a new offline operation, does not retain QR, and never claims server cancellation. `PROCESSING` is preserved until status can be checked; `NOT FOUND` requires a rescan.
