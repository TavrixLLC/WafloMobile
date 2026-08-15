# Direction A+ authority manifest

Direction A+ is the **only** owner-selected visual and UX authority used for
M3G. The full forensic manifest is preserved at
`artifacts/m3g-a-plus/A_PLUS_AUTHORITY_MANIFEST.md`.

## Exact rendered authority

- Product route: `/`.
- Render chain: `src/routes/index.tsx` → `LabShell` → `Device` → `APlus`.
- Product renderer: `src/waflo/APlus.tsx`.
- A+ state/catalog fixture: `src/waflo/aplus/product.ts`.
- Shared elements count as authority only where they are actually rendered by
  A+: `CameraStage`, `FakeCodeArt`, `StampGrid`, `WAFLO_MARK`, and `usePrefs`.
- Lab toolbar, phone bezel, comparison controls, state-jump buttons, and notes
  are inspection chrome, not product UI.

## Forensic record

- Owner-supplied archive label: `Waflo Staff Studio.zip`.
- SHA-256:
  `50b4d3cfbfe17818ea73aa93f6b5ab80b997afa719ece00e8499d612dff89756`.
- Inventory: 86 files; 547,747 uncompressed bytes.
- Portable archive safety scan: PASS.
- Vite reference build: PASS.
- Interactive A+ walk-through: PASS.
- Reference screenshots: 28.

The Lovable source was used only as visual and interaction reference. No React,
TypeScript, Tailwind, fixture state machine, package tree, secret, or private
asset proxy was copied into production Flutter.

This is owner-selected visual direction, not Production Ready or owner physical
visual approval.
