# M3E Review Access and professional scanner

M3E adds a server-authorized `REVIEW` device-session mode, fixed review-only scenarios, Review Tools, and a camera-first scanner UI. It does not add a master code, local bypass, Staff login, offline mutation, or a second customer QR protocol.

## State

- Mobile start: `32bf9e8e56980cded03b57256882285054326c82`
- Mobile branch: `feature/m3e-review-access-scanner`
- Mobile primary implementation SHA: `88d5f2d5e70b52bff819c9617c917e911957ef25`
- Mobile verified implementation tip: `21808e4070f728b9445c4674a38d6ff39dd88ad0`
- Backend resolved base: `3c4ef965f60a9286249e95983b39eff9cd9f3660`
- Backend branch: `feature/m3e-review-access`
- Backend implementation: `d02435ddce2d79a62cab418f50af08e75d862357`
- Historical M2 bundle: unchanged at `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`

Local and hosted Mobile verification is green. The hosted Linux, Android build,
Android emulator, macOS, and iOS no-sign jobs all passed at the verified Mobile
tip. Deployment, review-tenant provisioning, database-backed Backend HTTP
tests, generated review QR PNGs, Android hardware validation, and iOS hardware
validation remain external verification gates. No P0/P1 defect was found in the
executed Mobile scope; those external gates are not represented as passed.

The 30-screen M3E review matrix is in `screenshots/`; the 37-screen M3D regression set is in `screenshots/core-regression/`.
