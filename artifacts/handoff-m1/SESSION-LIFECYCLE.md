# Session lifecycle

One versioned secure record is atomically replaced and verified. Concurrent refresh is single-flight. Context fetch retries once only for a transport failure with freshly signed headers. Logout attempts server invalidation, then always clears session, identity, and safe cache.
