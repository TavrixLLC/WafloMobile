# Archive inspection

The portable source archive is created from the focused committed tree with Git export rules. Build/runtime caches, local properties, generated machine files, credentials, databases, pending journals, PII, and handoff recursion are excluded.

Archive result:

- file: `waflo-mobile-m2-final-reconciliation-portable-source.zip`
- size: 2,196,068 bytes
- entries: 573
- SHA-256: `7b09bb53cd7b5c14795e66f487166e4a1b874533c67513b3118d6f7c3b534eb3`
- reproducibility: exported from the Git tree (no commit-ID ZIP metadata) with timestamp fixed at `2026-08-08T00:00:00Z`; `/artifacts` excluded
- exclusion, extraction, absolute-path, and credential scan: pass
- forbidden build/runtime/generated machine paths: none
