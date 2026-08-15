# Git provenance

- Starting branch: `feature/m3f-hidden-demo-scanner-design-pack`.
- Starting SHA: `20323dadb4345c1c0a71c1aa94634d3aeec2235e`.
- M3G branch: `feature/m3g-a-plus-production-ui`.
- Isolated worktree: `.dart_tool/worktrees/m3g-a-plus-production-ui`.
- History rewrite/reset/rebase/squash: none.
- Force push: none.
- Core A+ implementation and handoff payload SHA:
  `e405c77bde620fdc518fa944cf68765cd0270f4a`.
- Legacy M1 golden-preservation SHA:
  `e2155c9486cbe37f257cf75ca14a670a9fcfe1da`.
- Validated M3G implementation SHA, including the M3C A+ recovery expectation:
  `52e34a7b9c23b25cf74de3268443b0ca88a55fad`.
- Verified remote SHA before the final documentation-only provenance update:
  `52e34a7b9c23b25cf74de3268443b0ca88a55fad`.
- Final provenance-update SHA: reported after its Git object exists; it cannot
  be embedded self-referentially in the commit that creates it.
- Changed file count from the starting SHA at the validated implementation SHA:
  99.
- Backend changed file count: 0.
- Historical M2 evidence/contract changed file count: 0.
- Generated drift: none against the starting SHA.
- Committed secrets: 0 detected locally and on Linux CI.
- Lovable application source/archive committed: no.

## CI provenance

- Flutter M1 run `31903267750`: Linux PASS, Android builds PASS, Android
  emulator/integration PASS, approved W4 job QUEUED.
- Flutter M1 iOS run `31903268011`: macOS/iOS tests and three no-sign builds
  PASS.
- The parent Flutter M1 run remains queued solely because the approved W4
  self-hosted job has not acquired a runner. This is recorded as queued, not
  green.

The branch was pushed normally. Exact later CI/provenance SHAs are reported only
after those Git objects exist; they are not guessed or self-referentially
fabricated.
