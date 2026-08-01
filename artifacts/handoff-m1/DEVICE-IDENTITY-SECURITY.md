# Device identity security

Ed25519 is generated on device; the public key uses RFC 8410 SPKI Base64. The private record exists only in platform secure storage, is excluded from backup/sync, is never transmitted/logged, and is deleted on logout/repair. Tests verify signing with the approved W4 fixture message.
