# Deferred items

Only external/manual or intentionally out-of-scope items remain:

1. Product-owner visual approval on a physical Android phone.
2. Physical Android native splash/startup and biometric/camera review; no device was attached locally.
3. Platform signing and store submission credentials.
4. Operational staging pairing/stamp/redeem E2E, which remains a separate authorized physical test.
5. Renderable merchant stamp artwork remains dependent on a supported Backend/Web asset URL or payload when only digest metadata is available; M3D does not invent an endpoint or recolor merchant artwork.
6. Future Gradle/Kotlin built-in-Kotlin migration signaled by Flutter 3.44.3 warnings; this is maintenance scope, not a brand integration defect.

Hosted Linux, Android emulator, Android build, and macOS/iOS no-sign jobs all passed for the CI-tested implementation SHA. The branch workflow's additional approved-runner Real W4 job is queued because that dedicated runner is offline; historical M2 formal closure remains the authoritative 42/42 evidence and is not reopened by M3D.

Explicitly not implemented: Backend/Web changes, API schemas, auth redesign, Manager Approval semantic changes, loyalty changes, NFC, Smart Tap, POS, offline mutations, Wallet issuance, location switching, or notifications.
