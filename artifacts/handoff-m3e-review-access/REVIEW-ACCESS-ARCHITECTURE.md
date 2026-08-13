# Review Access architecture

Normal sessions retain merchant pairing, a Mobile Ed25519 identity, challenge proof, opaque device sessions, and signed requests. Review authorization is a separate public entrypoint that validates a rotatable server credential, then creates the same challenge/proof sequence with explicit `REVIEW` metadata and a fixed review organization binding.

Every review session is typed `REVIEW` in the server challenge/session metadata and Mobile secure session record. Every signed request still requires fresh request ID, timestamp, nonce, body digest, and signature. Server guards reject a review session whose organization/member/location/device binding is not the fixed review fixture. Normal pairing rejects the review tenant.

Mobile never persists the review code. Exit Demo performs server logout best-effort, clears review session/context/operation state, and preserves the device key for exact-device re-entry. It returns to normal Pairing without granting normal merchant authority.
