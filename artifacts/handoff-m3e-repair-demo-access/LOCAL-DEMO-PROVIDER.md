# Local Demo provider

The debug-only provider supplies deterministic implementations behind existing seams:

- authoritative-looking device context containing fictional sample organization/location data;
- the existing loyalty repository contract, backed only by in-memory fixtures;
- the existing pending-operation and Manager Approval intent stores, backed in memory;
- the existing customer scanner adapter with real camera ownership and deterministic simulation hooks;
- an isolated in-memory App Lock store with the real verifier/rate-limit behavior.

It never creates or persists:

- Device access/refresh tokens;
- a fake `StaffDeviceSession`;
- merchant/customer identifiers from production;
- customer QR payloads in storage or logs;
- a queued offline mutation.

Stamp and redeem actions alter only local deterministic fixture state. They never call the operational API. A successful local screen therefore means “presentation simulation,” not server authority.

The App Lock scenario uses a debug-only fixture PIN (`2468`). It is not used by normal or server-backed Review sessions, and release APK inspection proves that it is absent from staging/production release AOT binaries.
