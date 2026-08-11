# M3A Staff product audit

## Audit baseline

- Mobile source: `c17a56b18ca356cfc77fc49517b9586f5e3992a4`
- M2 contract bundle: `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- Preserved M3A reference: `8fbfb14a2b34005d34d1098ee73ba118e1c25719`
- Product subject: a Staff phone at a busy retail counter.
- Primary audience: a one-handed operator serving a customer.
- Recurring job: identify the next safe action, complete it, and scan the next customer.

The approved M2 application already has sound device identity, pairing, signed
sessions, server-authoritative device context, membership resolution, two-state
stamp projections, stamp/redeem mutations, and command recovery. Its primary
product weakness is presentation: several screens expose implementation-shaped
information in long Material card stacks, making the next action less obvious.

## Screen and state inventory

| Area | Existing state | Classification | M3A direction |
| --- | --- | --- | --- |
| Startup | Boot gate with deterministic local/session checks | REFINE | Preserve the controller; align visible states with Staff language and prevent protected-route bypass. |
| Environment failure | Configuration-error blocked screen | REFINE | Keep fail-closed behavior; add explicit approved staging/production hosts. |
| Not paired | Welcome and pairing rationale | REFINE | Turn into a short, confidence-building setup flow. |
| Pairing permission | Camera rationale and denial path | REFINE | Clarify why the camera is used and make Settings recovery obvious. |
| Pairing scanner | Live QR scanner and manual test-only adapter | REFINE | Add lifecycle/state feedback and a production scanner frame without exposing QR data. |
| Pairing progress | Challenge/claim/complete progress | REFINE | Use plain Staff copy and a compact step indicator. |
| Pairing success | Success screen | REFINE | Show merchant/location context, then one Continue action. |
| Pairing failure/expiry | Safe localized error | REFINE | Keep safe error mapping; make retry/expired guidance distinct. |
| Device pending | Backend state exists in context semantics | MISSING | Add a dedicated blocked/readiness presentation without inventing authorization. |
| Device revoked | Blocked screen | REDESIGN | Explain removal from service; do not silently return to pairing. |
| Device compromised | Blocked screen | REDESIGN | Explain security block and next safe action. |
| Session expired | Blocked screen | REDESIGN | Preserve identity; guide Staff to authorized recovery. |
| Network unavailable | Generic backend-unavailable screen and in-flow banners | REDESIGN | Separate offline from backend failure; state that loyalty changes cannot be queued. |
| Update required | HTTP 426 mapped to blocked state | REFINE | Preserve session/device state and make update the sole action. |
| App locked | No approved-M2 product UI | MISSING | Add optional local PIN/biometric layer; backend authorization remains authoritative. |
| Home | Diagnostic organization/device/location/policy card stack | REDESIGN | One dominant Scan customer action, compact organization/location/readiness, two supporting actions. |
| Pending operation on Home | Warning and recovery link | REFINE | Move above Scan and block scanning until authoritative resolution. |
| Customer scanner | Full-screen camera with limited explicit state | REDESIGN | Harden permission/lifecycle/debounce and make scan target, flash, cancel, and resolving states explicit. |
| Membership resolving | Spinner | REFINE | Preserve one request; use a calm `Finding membership` transition. |
| Membership invalid/not found/inactive | Shared failure surface | REDESIGN | Map each safe state to a concise explanation and next action. |
| Customer membership | Program card, grid, input card, rewards cards | REDESIGN | Establish customer/program hierarchy, one progress surface, actions below; no internal identifiers. |
| 0/goal | Two-state grid | KEEP | All positions EMPTY. |
| Partial progress | Two-state grid | KEEP | Filled count equals authoritative progress; semantic summary only. |
| Goal/reward ready | Two-state grid and reward list | REFINE | Grid stays all FILLED; reward-ready treatment lives outside the grid. |
| Add stamps | Amount stepper, purchase fields, reference | REFINE | Show only authoritative relevant inputs and keep the flow on one surface. |
| Stamp confirmation | Review list | REDESIGN | Compact receipt-like summary; do not project the grid before success. |
| Stamp submitting | Progress state | REFINE | Block double-submit and keep identity hidden from logs. |
| Stamp success | Card with Scan next customer | REDESIGN | Strong outcome, new progress, reward status, dominant Scan next customer. |
| Reward list | Nested cards | REDESIGN | Keep rewards outside the grid and make the eligible action unmistakable. |
| Manager approval required | Informational panel only | KEEP | Acquisition remains deferred; never invent local elevation. |
| Redeem confirmation | Review list with reset warning | REDESIGN | Deliberate but quick confirmation with final-cycle impact. |
| Redeem success | Success card | REDESIGN | Final reward immediately shows authoritative 0/goal and all EMPTY. |
| Ambiguous mutation | Command recovery panel | REDESIGN | `Checking transaction status`, no rescanning, same command ID, Check again. |
| Settings | Language/theme/device info plus disabled future items | REFINE | Limit to Language, Appearance, Device & Security, App information. |
| Device & Security | Not present in approved M2 | MISSING | Add a safe Staff-readable device summary and App Lock entry. |
| Privacy cover | Immediate background cover already exists | KEEP/REFINE | Preserve immediate cover; integrate App Lock and scanner release. |
| Arabic RTL | Generated Arabic localization and RTL goldens | REFINE | Re-audit directional spacing, mixed Latin values, scanner controls, and large text. |
| Dark mode | Seed-based Material theme | REDESIGN | One semantic token system with a purpose-built dark counter palette. |
| Accessibility | Baseline semantics and 48dp actions | REFINE | Add grouped progress semantics, focus order, 200% layouts, and state announcements. |
| Notifications | Preserved WIP UI concept only | DEFER | Not needed for physical Staff flow; real delivery stays server-side. |
| Human sign-in | No approved shared contract | DEFER | Do not introduce Clerk or speculative social authentication. |

## Preserved M3A WIP classification

| Preserved piece | Classification | Decision |
| --- | --- | --- |
| Haptic service abstraction and fake | REUSABLE | Port the interface; refine the mapping so errors are subtle and never the only signal. |
| Customer scanner state machine | REUSABLE | Port as a starting point, expand states and tighten transition/debounce tests. |
| Scanner adapter lifecycle hooks | REUSABLE | Port manually against the approved adapter and preserve one-candidate semantics. |
| PIN verifier in secure storage | REUSABLE | Port with explicit ASCII PIN validation and rate-limit tests. |
| App Lock state/controller | REUSABLE | Port and refine lifecycle/revalidation behavior. |
| `local_auth` biometric adapter | REUSABLE | Port with platform configuration and failure handling. |
| Privacy overlay integration | REUSABLE | Preserve immediate cover and exclude underlying semantics while covered/locked. |
| Device & Security screen concept | REUSABLE | Rebuild using the new visual system; do not expose raw identifiers. |
| Rapid-scan controller reset | REUSABLE | Port only the safe state cleanup and explicit-tap scanner return. |
| Task-first Home concept | SUPERSEDED | Product principle is correct; replace its remaining card/tile treatment with the new scan-stage composition. |
| WIP App Lock screens | SUPERSEDED | Keep behavior, redesign presentation and PIN input for accessibility/RTL. |
| WIP theme changes | SUPERSEDED | Palette direction is useful, but replace with explicit semantic light/dark tokens. |
| WIP localization strings | REUSABLE | Port only strings used by selected features and rewrite awkward copy. |
| Notification repository/UI/templates | DEFER | Do not port in this Staff physical-readiness milestone. |
| WIP M3A notification documentation | DEFER | Preserve in the backup commit; not part of the current product slice. |
| WIP M2 verifier/LF/CI changes | STALE | Approved M2 already contains authoritative reconciliation; do not reapply. |
| WIP generated contracts or contract-adjacent changes | CONFLICTING | Never port; the approved bundle remains immutable. |
| WIP handoff raw-output rewrites | STALE | New evidence will be produced from this branch. |

## Contract-bound limitation

The approved M2 membership contract supplies FILLED/EMPTY state and optional
content digests, but no asset bytes, asset URL, or color values. The app cannot
truthfully fetch merchant artwork from a digest alone. M3A will keep the exact
two-state projection and digest integrity boundary, will not fabricate merchant
artwork, and records merchant-artwork resolution as a staging/backend-owned
dependency. No contract change is made here.
