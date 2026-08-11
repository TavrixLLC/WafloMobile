# M3C UI review

The frontend-design pass preserved the M3B Waflo Staff language: Counter Ink, Evergreen action, Signal Mint, Receipt surfaces, controlled Amber, and Safety Red; Waflo Sans/Waflo Arabic typography; calm, task-first layouts; and the exact two-state stamp grid.

The subject is a busy retail counter and the screen's one job is to preserve one redeem intent safely while making the next Staff action obvious. The signature element is a truthful three-step approval handoff rail, not a generic admin shield or dashboard card.

## First critique

All 23 executable states were reviewed for hierarchy, action clarity, spacing, RTL, dark mode, and text scaling. Manager-required and pending states communicated the handoff clearly, terminal states did not expose IDs, Arabic flowed naturally, the dark surface hierarchy remained legible, and the 200% state remained scrollable without clipping.

Two operational error screens still used a generic scan-oriented recovery action. That could imply that billing or threshold denial was resolved.

## Refinement

- Billing blocked now uses **Return home**, confirms no customer progress changed, and identifies Merchant Web as the Owner recovery surface.
- Purchase threshold now uses **Review details**, returning Staff to the editable operation inputs.
- Action icons match those outcomes instead of reusing a scanner symbol.

## Final critique

The second render confirms that approval ownership, next action, and non-mutation guarantees are immediately legible. No Mobile approval affordance, raw code, command UUID, approval public ID, or cryptographic detail is visible. New states match the M3B visual system and do not redesign unrelated screens.

Result: all 23 M3C review states are `SHIP` for Mobile implementation review.
