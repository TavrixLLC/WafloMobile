# Final compliance matrix

| Area | Evidence | Status |
|---|---|---|
| Flutter Android/iOS foundation | `android/`, `ios/`, `lib/` | Implemented |
| Three isolated flavors | `config/`, native flavor/scheme files | Implemented; deployment hosts required |
| W4 mobile-only contract | `contracts/w4/` | Implemented |
| Ed25519 identity / secure storage | unit tests and security docs | Passed locally |
| Claim/challenge/complete | service, fake integration, opt-in real test | Fake integration passed; real backend not run |
| Canonical signing | approved deterministic fixtures | Passed locally |
| Session/context/logout | unit and fake integration suites | Passed locally |
| English/Arabic/RTL | ARB, widget/golden tests | Passed locally |
| Accessibility automation | widget semantics/text-scale tests | Passed; physical reader review pending |
| Android builds | development/staging/production | Local results in `TEST-SUMMARY.md` |
| iOS builds | macOS workflow | Configured; no local Xcode result |
| CI | `.github/workflows/` | Configured; external run pending |
| M2 exclusion | `NO-M2.md`, disabled UI placeholders | Confirmed |
| Portable archive | ZIP, extraction inspection, SHA-256 | See final gate output |
