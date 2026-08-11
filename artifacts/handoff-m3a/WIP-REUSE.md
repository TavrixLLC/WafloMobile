# Preserved M3A WIP audit

Source reviewed: `8fbfb14a2b34005d34d1098ee73ba118e1c25719`.
It was not merged, rebased, or cherry-picked.

## Reusable and intentionally ported

- scanner state/lifecycle and duplicate-frame hardening concepts
- haptic service boundary and fake-service testing concept
- PIN/biometric local-lock architecture, secure storage, and rate-limit concept
- immediate privacy overlay and background credential cleanup
- Device & Security safe-field concept
- task-first Home and explicit Rapid Scan cleanup concept

Every port was rebuilt or manually applied over the formally approved M2 base.

## Superseded

- earlier Home/theme/App Lock presentation implementations; replaced by the
  M3A production visual system and current navigation/readiness model

## Stale or conflicting

- generated contracts, verifier copies, provenance/evidence, and raw output
  tied to the pre-reconciliation M2 state

## Deferred

- Notification Center, composer, and notification fake concepts
- any human/social authentication concept without a shared backend contract
