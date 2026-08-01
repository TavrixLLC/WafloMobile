# Session lifecycle

The versioned secure session stores device/session/organization/location identifiers, role/platform/status, access and refresh tokens, expiry, display name, and issue time. It is written as one record and read back to verify replacement.

Expired access triggers a single in-flight refresh shared by concurrent callers. A successful replacement is atomic from the application's perspective; persistence failure clears the unusable record. Backend refresh failure preserves the current record for diagnostics/control flow but does not authorize operations. Context is refreshed after pairing, at boot, on demand, and after a five-minute resume interval.

Logout attempts signed server invalidation once, then always clears session, identity, and safe cache locally. W4 has no re-auth endpoint for an existing key, so logout requires a new dashboard pairing QR; operators should revoke any orphaned server device when appropriate.
