# Non-authoritative design directions

## Owner decision

- Direction A: historical exploration only.
- Direction B: historical exploration only.
- Direction C: historical exploration only.
- Direction D: historical exploration only.
- Direction A+: the only owner-selected visual and UX authority for M3G.

The files `DirectionA.tsx`, `DirectionB.tsx`, `DirectionC.tsx`, and
`DirectionD.tsx` are not independent implementation inputs. Flutter must not
mix their layouts, typography, scanner treatments, success presentations, or
navigation patterns into M3G.

A+ describes itself as evolving ideas first explored in A and shares a small
set of lab primitives with older directions. Reuse is allowed only when the
element is visibly rendered by `APlus.tsx`. Its historical origin does not
grant the older direction authority.

## Also excluded from product authority

- The graphite Lovable lab shell and comparison toolbar
- The simulated phone frame and fake status-bar island
- State-jump controls and fixture navigation outside the phone
- React, TypeScript, Tailwind, TanStack, and Radix architecture
- Fixture names, operation references, device model, version, and timestamps
- Fake camera artwork and timer-driven state changes
- Local browser storage or lab-only state
- The inspection-only temporary `Demo authorized` lab jump added outside the
  phone to accelerate forensic capture

The Lovable code is design and interaction reference only. It will not be
copied into the Flutter application, packaged as production source, or used to
replace existing Flutter state machines.

Historical M2 evidence, approved archives, and provenance remain untouched.
