# Direction A+ authority manifest

## Status and provenance

Direction A+ is the owner-selected visual and UX authority for M3G. This does
not mean production approved, security approved, release approved, or
Production Ready.

- Starting Mobile SHA: `20323dadb4345c1c0a71c1aa94634d3aeec2235e`.
- Owner-supplied reference: `Waflo Staff Studio.zip`.
- Archive SHA-256: `50b4d3cfbfe17818ea73aa93f6b5ab80b997afa719ece00e8499d612dff89756`.
- Archive inventory: 86 files, 547,747 uncompressed bytes.
- Archive safety before extraction: no unsafe paths, sensitive filenames,
  private keys, credentials, tokens, environment files, or real customer data
  detected. A route-documentation `/users` example caused the sole local-path
  regex false positive.
- The archive was extracted to an ignored temporary reference directory and
  all 86 source files were marked read-only. A separate ignored runtime copy
  was used to install dependencies, build, render, and inspect the prototype.
- The temporary Lovable runtime built successfully with Vite. No Lovable
  source or dependency tree is part of the production Flutter application.

## Exact A+ entrypoint

The rendered route is `/`:

`src/routes/index.tsx` → `LabShell` → `Device` → `APlus`

`LabShell` defaults to `single = "A+"`. For that direction, its `plus` branch
renders `src/waflo/APlus.tsx` with state from
`src/waflo/aplus/product.ts`. The `Component: DirectionA` metadata entry in the
direction list is not the rendered A+ product component because the explicit
`plus ? <APlus ...> : <Screen ...>` branch overrides it.

The only shared reference components actually rendered inside A+ are:

- `CameraStage`
- `FakeCodeArt`
- `StampGrid`
- `WAFLO_MARK`
- `usePrefs`

They come from `src/waflo/lab.tsx`. Their rendered A+ use is authoritative;
their use by historical directions does not make those directions
authoritative.

The graphite lab toolbar, comparison controls, phone bezel, state-jump buttons,
and lab notes are inspection chrome and are not product UI.

## A+ screen and state catalog

The A+ product renderer contains these screen families:

- Pairing welcome and pairing progress
- Home
- Canonical scanner
- Manual code
- Authorized local-demo scenario browser
- Customer loyalty and suspended membership
- Stamp review and redemption review
- Manager approval required, checking, pending, rejected, and expired
- Stamp success and redemption success
- Pending/ambiguous operation recovery
- Failed operation recovery
- App Lock
- Device & Security
- Settings
- Offline, update required, session expired, device revoked, device
  compromised, and billing-blocked notices

Scanner reference phases are requesting/starting, ready, detected, resolving,
invalid, membership not found, network failure, permission denied, and paused.
Production-only scanner states that the prototype does not distinctly render
must receive the same A+ visual language without changing their existing
semantics.

The prototype's authorized fixture browser exposes deterministic examples for
scanner, customer 0/8, customer 5/8, reward-ready 8/8, stamp/redeem,
manager-approval, recovery, App Lock, Device & Security, and Settings. It is a
reference harness, not a production state machine.

## Visual system extracted from the rendered A+

### Composition

- Quiet Cloud/White canvas with warm Ink text and restrained dividers.
- One dominant task per screen, generally anchored in the bottom thumb zone.
- Text-led hierarchy instead of decorative icon grids.
- Content uses roughly 20 px horizontal gutters on the 348 px reference
  viewport.
- Large operational actions use Brick, 22–32 px radii, generous padding, a
  strong title, and a short explanatory line.
- Cards exist only when they group a decision or a coherent state.
- Device and settings details use contained sections with hairline row
  separators rather than nested cards.
- Failure and blocked states share one calm, text-led notice composition with
  a single safe next action.

### Brand and color

- Brick `#AE3115`
- Coral `#FF6B4A`
- Ember `#7D2311`
- Ink `#241916`
- Soft Coral `#FFF0EC`
- Cloud `#F7F9FF`
- White `#FFFFFF`
- Muted `#76645F`
- Success `#1F8F6A`
- Warning `#E6A23C`
- Danger `#C93C2B`

Light semantic surfaces are Cloud canvas, White surface, Soft Coral raised,
Ink text, Muted secondary text, and Brick accent. A+ dark mode is deliberately
warm rather than an inversion: `#14100F` canvas, `#1E1817` surface,
`#2A201D` raised, `#F6EFEC` text, `#A7938D` secondary text, `#362C29`
dividers, and Coral accent.

The Lovable asset URLs require its private asset proxy. For faithful local
rendering only, the ignored runtime copy substituted the repository's official
Waflo primary/white mark files. The reference source stayed read-only. Flutter
will continue using its existing official brand assets.

### Typography

- Manrope for Latin UI.
- Noto Sans Arabic for Arabic-script UI.
- Reference scale: 44 px hero, 32 px display, 22 px title, 17 px lead,
  15 px body, 13 px small, 11 px uppercase operational label, and 40 px
  tabular numeral.
- Heavy 700–800 weights carry task and state hierarchy; supporting copy is
  quiet and short.

Flutter may adapt exact metrics for native rendering and 200% text reflow, but
must preserve the hierarchy and relative emphasis.

### Radius, density, and touch

- Official radii: 8, 14, 22, 32, and pill 999.
- Typical grouping card: 22 px.
- Scanner target: 28 px.
- Primary Home task: 32 px.
- Interactive controls target at least 48×48 logical pixels.

### Motion

- Scanner beam: 2.3 seconds, restrained ease, only while ready/scanning.
- Content rise: 260 ms.
- Bottom sheet entrance: 280 ms.
- Newly filled stamp pop: 300 ms with a short stagger.
- Reduced motion removes the scanner beam and animation/transition effects but
  leaves a complete, understandable static state.

### Scanner signature

The canonical A+ scanner is full-bleed dark camera content with a large rounded
target, four Coral corners, quiet diagonal texture, a compact top identity row,
and one grounded bottom rail. Ready state uses a restrained beam. Detection
changes the corner/status color and stops active scanning motion. Resolving and
failure states become bottom sheets rather than unrelated scanner designs.

### Loyalty invariant

The rendered A+ `StampGrid` has exactly two slot states: FILLED and EMPTY. It
uses eight rounded slots in a 4×2 layout for the eight-stamp program. Reward
readiness, reward description, cycle count, and all milestones remain outside
the grid. Redemption success renders 0/8 as eight EMPTY slots.

## Localization and accessibility extraction

- English and Arabic RTL render as complete product experiences.
- RTL uses structural direction, logical start/end placement, reordered
  controls, Arabic typography, and LTR treatment for technical values.
- Sorani and Badini are explicitly unavailable because authoritative copy was
  not supplied; no translation is to be invented.
- The lab's large-text switch uses a 1.55 scale. Flutter verification will use
  the product requirement of approximately 200% and preserve reflow rather
  than copy the lab's exact multiplier.
- The rendered scanner under reduced motion has no beam element and retains
  its status, target, instructions, torch, and manual-entry controls.
- An axe WCAG A/AA audit of the rendered reduced-motion scanner reported zero
  violations and one incomplete contrast group caused by composited camera
  layers/non-text glyphs. Flutter contrast must be measured independently.

## Reference evidence

`reference-a-plus/` contains 28 sanitized phone-surface captures covering
light, dark, English, Arabic RTL, large text, reduced motion, scanner states,
loyalty states, operation reviews, approval, success, App Lock, security,
settings, pending, and billing blocked. The captures exclude Lovable source and
the lab toolbar.

## Implementation authority rule

Flutter will reproduce the rendered A+ visual hierarchy, composition,
presentation, and motion intent. Existing Flutter controllers, repositories,
security boundaries, API contracts, and lifecycle semantics remain the sole
production authority. Every conflict is resolved and recorded in
`A_PLUS_PRODUCTION_CONFLICTS.md`.
