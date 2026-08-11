# External blockers and dependencies

## Staging deployment

The Mobile staging flavor is fixed to `https://api.staging.waflo.app`. A read-only check on 2026-08-12 did not reach an HTTP response because the endpoint returned a TLS handshake alert. That result does not prove which Backend SHA is deployed. Physical E2E must wait until the origin is confirmed on Backend authority SHA `763f2dfccdb24fb9bfa16457f0e49936840e20a1` with green deployment readiness.

## Physical hardware and signing

Camera, biometric, app-switcher privacy, and end-to-end pairing require real Android/iOS devices. iOS device distribution requires external signing/provisioning credentials. These are validation dependencies, not missing Mobile features.

## MERCHANT_ARTWORK_RENDERING_EXTERNAL_DEPENDENCY

Current resolve authority provides stamp visual digests/metadata and colors, but no renderable asset payload or URL. Mobile cannot truthfully fetch exact merchant artwork from that data alone.

- Available: filled/empty visual identity, content digest, and contract-valid presentation metadata/colors.
- Missing: a renderable, authenticated asset delivery URL or payload.
- Safe Mobile fallback: preserve exact two-state FILLED/EMPTY semantics, accessible progress text, and contract-valid visual fallback without claiming merchant artwork delivery.
- Owner: Backend/Web contract.

No endpoint was invented and this gap does not change loyalty authority.
