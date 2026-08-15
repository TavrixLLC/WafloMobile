# Security preservation

M3G is a presentation-layer implementation. It does not change:

- Ed25519 device identity or challenge proof.
- Access/refresh session semantics.
- Signed request ID, timestamp, nonce, body hash, or signature behavior.
- Pairing authorization, device lifecycle, revocation, location, or capability
  authority.
- Staff authorization or the absence of traditional login methods.
- Backend API contracts, data models, ledger, eligibility, or mutation rules.
- Manager-approval authority, approval public ID, original semantic operation,
  or idempotency behavior.
- Secure storage, App Lock PIN material, biometric outcome, progressive delays,
  privacy overlay, or screenshot protections.
- Online-only mutation and ambiguous-operation recovery.

No email/password, OAuth, magic link, master code, universal PIN, production
bypass, tracked credential, private key, or client-side approval capability was
added.

Security scan, brand lint, absolute-path scan, portable archive scan, contract
checks, generation drift, and release binary exclusion all pass locally.
Backend changed files: **0**.
