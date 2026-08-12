# Waflo Mobile M3D brand handoff

M3D integrates the official Waflo Brand System into the existing Staff product without changing API contracts, security, idempotency, manager approval, loyalty economics, or environment hosts.

- Starting Mobile SHA: `69e3a7926c198eb144e5a4c3dcb0f77040639c50`
- CI-tested implementation SHA: `62ed78d037f9b381621d9809982da5c5955b9f3b`
- Branch: `feature/m3d-official-brand-integration`
- Worktree: `.dart_tool/worktrees/m3d-official-brand`
- Brand authority ZIP SHA-256: `586c9b5369317ef27b3ec02960bd734cf02b49036c47b6d1165f648d381afc4e`
- Staging API: `https://api-staging.waflo.app`
- Production API: `https://api.waflo.app`
- Historical M2 bundle: unchanged at `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`

The implementation covers official colors, radii, typography, app icons, adaptive/themed Android icons, iOS icons, native splash, Flutter startup, application surfaces, Arabic, dark mode, accessibility, brand lint, and the physical-owner review package.

Functional product flow remains:

`Pair → Home → Scan → Resolve → Stamp / Redeem → Success → Scan next customer`

## Verification summary

- Format: pass
- Flutter analysis with fatal warnings: pass
- Unit: 104/104
- Widget: 28/28
- Golden/screenshot tests: 23/23
- Executable M3D review screenshots: 60
- M2 contract checksum/LF verification: pass
- Production-v1 authority verification: pass
- Generated client drift: pass
- Localization drift: pass
- Brand lint: pass
- Security scan: pass
- Absolute-path scan: pass
- Android development debug: pass
- Android staging release: pass
- Android production release: pass
- Hosted Android integration: pass — 24 top-level test entries across M1, pairing, M2, M3A, and M3C
- Physical Android launch: not run; no device or AVD was connected
- iOS development/staging/production no-sign builds: pass on hosted macOS

See `PHYSICAL-OWNER-REVIEW.md` for the exact staging run command and `TEST-BUILD-SUMMARY.md` for gate detail.
The launch-leftover classification is in `REPOSITORY-AUDIT.md`.
