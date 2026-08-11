# Signed transport and idempotency

For every transmission Mobile creates a fresh request ID, UTC timestamp, nonce, exact-body SHA-256 digest, and Ed25519 signature.

Semantic idempotency is separate from transport freshness:

- initial redeem and Manager-approved retry use the same business command UUID;
- the approved retry carries the same QR, reward entitlement, and note plus the authoritative approval public ID;
- a response-loss recovery uses the command-status endpoint with the original command UUID;
- no retry reuses the transport envelope;
- stamp and redeem ambiguity never creates a second business command.

Focused API tests capture two actual signed requests and prove same command/body semantics with different request IDs, timestamps, nonces, and signatures.
