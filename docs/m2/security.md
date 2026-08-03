# Security review

M2 preserves M1 Ed25519 identity, canonical request signing, single-flight refresh, secure storage, device context enforcement, privacy cover, and native security. Android applies `FLAG_SECURE`; iOS uses the M1 app-switcher privacy cover because iOS does not provide a general screenshot-prevention API.

Customer QR, tokens, signatures, nonce, request bodies, customer display names in network logs, Membership/entitlement IDs in analytics, and purchase references are redacted or never emitted. QR length is bounded before submission and transient memory is cleared on result, error, navigation, background, or blocked session.

Automated scans reject backend runtime paths, `.env`, credentials, private keys, databases, usable pairing/customer QR literals, QR persistence in the pending journal, machine paths, and credential-like archive content.
