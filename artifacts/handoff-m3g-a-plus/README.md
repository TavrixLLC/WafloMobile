# Waflo Mobile M3G — Direction A+ handoff

Status: **engineering implementation complete locally; external/device and remote
gates remain pending**.

Direction A+ is the owner-selected visual/UX authority. This handoff does not
mean Production Ready, release approved, security approved, or owner visually
approved. Physical owner review remains a separate decision.

## Outcome

- The production Flutter presentation now carries the rendered A+ hierarchy,
  typography, spacing, surfaces, dark treatment, task-first Home, canonical
  scanner, two-state loyalty grid, review/success presentation, App Lock,
  Settings, Device & Security, and blocked/recovery states.
- Existing authentication, Ed25519 identity, session, signing, API, scanner,
  mutation, ledger, manager-approval, App Lock, and M3F Demo/Review behavior
  remain the authority beneath the presentation.
- Directions A/B/C/D were not used as independent implementation sources.
- Backend changed files: **0**.
- Historical M2 evidence/contracts changed files: **0**.
- Generated drift: **none**.
- Reference evidence: **28** screenshots.
- Flutter M3G evidence: **38** screenshots.

## Handoff index

- [A_PLUS_AUTHORITY_MANIFEST.md](A_PLUS_AUTHORITY_MANIFEST.md)
- [NON_AUTHORITATIVE_DIRECTIONS.md](NON_AUTHORITATIVE_DIRECTIONS.md)
- [A_PLUS_PRODUCTION_CONFLICTS.md](A_PLUS_PRODUCTION_CONFLICTS.md)
- [SCREEN_COVERAGE.md](SCREEN_COVERAGE.md)
- [VISUAL_IMPLEMENTATION_SUMMARY.md](VISUAL_IMPLEMENTATION_SUMMARY.md)
- [SCANNER_PARITY.md](SCANNER_PARITY.md)
- [RTL_ACCESSIBILITY.md](RTL_ACCESSIBILITY.md)
- [SECURITY_PRESERVATION.md](SECURITY_PRESERVATION.md)
- [DEMO_PRODUCTION_EXCLUSION.md](DEMO_PRODUCTION_EXCLUSION.md)
- [TEST_BUILD_SUMMARY.md](TEST_BUILD_SUMMARY.md)
- [PHYSICAL_DEVICE_STATUS.md](PHYSICAL_DEVICE_STATUS.md)
- [KNOWN_EXTERNAL_BLOCKERS.md](KNOWN_EXTERNAL_BLOCKERS.md)
- [GIT_PROVENANCE.md](GIT_PROVENANCE.md)

The forensic source of truth and raw comparison evidence remain in
`artifacts/m3g-a-plus/`.

## Final review questions

1. Is A+ unquestionably the only visual authority? **Yes.**
2. Are A/B/C/D excluded from independent decisions? **Yes.**
3. Does Flutter match A+ where production constraints permit? **Yes, subject
   to owner physical visual review.**
4. Are deviations documented? **Yes.**
5. Is strict FILLED/EMPTY unchanged? **Yes.**
6. Is Demo/Review hidden from ordinary users? **Yes.**
7. Is manual-code Demo/Review routing preserved? **Yes.**
8. Is local Demo structurally excluded from production? **Yes; source and
   release-binary gates pass.**
9. Is scanner presentation unified across Normal/Demo/Review? **Yes.**
10. Is real scanner lifecycle/security unchanged? **Yes.**
11. Is manager approval behavior unchanged? **Yes.**
12. Is App Lock security unchanged? **Yes.**
13. Are auth/session/Ed25519 contracts unchanged? **Yes.**
14. Is Backend untouched? **Yes; zero changed files.**
15. Is M2 provenance untouched? **Yes; zero changed files.**
16. Are there zero committed secrets? **Pre-commit scans find zero; the final
    scan must remain green after staging.**
17. Was Lovable used only as design/interaction reference? **Yes.**
18. Were English/Arabic RTL/dark/large-text/reduced-motion verified? **Yes in
    automated visual evidence; physical review remains pending.**
19. Were missing Kurdish translations not invented? **Correct; none were
    invented.**
20. Is physical owner approval separate from automated verification? **Yes.**
