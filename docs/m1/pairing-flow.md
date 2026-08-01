# Pairing flow

1. Validate total length, printable ASCII, four segments, `waflo-pair-v1`, UUID, 32-byte secret, and build environment.
2. Persist a non-secret pairing transaction marker.
3. Create/load the device Ed25519 identity. W4 claim requires its public key, so key creation necessarily precedes claim.
4. Send claim with the opaque QR token, installation ID, SPKI public key, and bounded device metadata.
5. Reconstruct the exact challenge message and reject mismatched ID, algorithm, expiry, length, or bytes.
6. Sign the message locally; send challenge/signature to complete.
7. Atomically write and re-read the secure session. On failure, remain fail-closed with a `persisting` marker.
8. Fetch authoritative context and show success.

Claim is not blindly retried. Completion is not automatically replayed because the server may have committed while local persistence failed. The user receives a deliberate reset/re-pair path without secret diagnostics.
