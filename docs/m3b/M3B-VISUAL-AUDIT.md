# M3B visual forensic audit

Audit source: all 26 executable M3A screenshots at 390 × 844. Scores are
1–10 and were assigned after inspecting the rendered pixels, not only golden
test outcomes.

Legend: H hierarchy, T typography, S spacing, A alignment, C action clarity,
V consistency, Q perceived quality, R RTL quality, X accessibility resilience,
and F retail speed.

| # | Screen | H | T | S | A | C | V | Q | R | X | F | Decision |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 01 | Home — EN light | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 10 | POLISH |
| 02 | Home — AR RTL | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 9 | 8 | 10 | POLISH |
| 03 | Home — dark | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 10 | POLISH |
| 04 | Scanner ready | 7 | 7 | 7 | 8 | 8 | 7 | 7 | 7 | 8 | 8 | REDESIGN |
| 05 | Scanner resolving | 7 | 7 | 7 | 8 | 8 | 7 | 7 | 7 | 8 | 8 | REDESIGN |
| 06 | Customer 0/8 | 8 | 8 | 6 | 8 | 7 | 8 | 7 | 8 | 7 | 7 | REDESIGN |
| 07 | Customer 5/8 | 8 | 8 | 6 | 8 | 7 | 8 | 7 | 8 | 7 | 7 | REDESIGN |
| 08 | Customer 8/8 | 9 | 8 | 8 | 9 | 9 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 09 | Add stamps | 8 | 8 | 7 | 8 | 9 | 8 | 7 | 8 | 7 | 9 | REDESIGN |
| 10 | Stamp confirmation | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 11 | Stamp success | 8 | 8 | 6 | 8 | 10 | 8 | 7 | 8 | 8 | 10 | REDESIGN |
| 12 | Reward ready | 9 | 8 | 8 | 9 | 9 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 13 | Redeem confirmation | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 14 | Redeem success/reset | 8 | 8 | 6 | 8 | 10 | 8 | 7 | 8 | 8 | 10 | REDESIGN |
| 15 | Checking status | 9 | 8 | 8 | 9 | 10 | 8 | 8 | 8 | 8 | 9 | POLISH |
| 16 | Device revoked | 8 | 8 | 6 | 9 | 7 | 8 | 7 | 8 | 8 | 7 | REDESIGN |
| 17 | Device compromised | 8 | 8 | 6 | 9 | 7 | 8 | 7 | 8 | 8 | 7 | REDESIGN |
| 18 | Session expired | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 19 | Offline | 9 | 8 | 8 | 9 | 10 | 9 | 8 | 8 | 8 | 10 | POLISH |
| 20 | Update required | 8 | 8 | 6 | 9 | 7 | 8 | 7 | 8 | 8 | 7 | REDESIGN |
| 21 | Device & Security | 8 | 8 | 8 | 9 | 9 | 9 | 8 | 8 | 8 | 9 | POLISH |
| 22 | App Lock PIN | 8 | 8 | 6 | 9 | 9 | 8 | 7 | 8 | 8 | 8 | REDESIGN |
| 23 | Large-text Home | 8 | 8 | 7 | 8 | 10 | 8 | 7 | 8 | 8 | 9 | REDESIGN |
| 24 | Large-text Customer | 8 | 8 | 7 | 8 | 8 | 8 | 7 | 8 | 8 | 8 | REDESIGN |
| 25 | Arabic customer 5/8 | 8 | 8 | 7 | 9 | 8 | 8 | 7 | 9 | 8 | 8 | REDESIGN |
| 26 | Arabic reward/redeem | 9 | 8 | 8 | 9 | 9 | 9 | 8 | 9 | 8 | 9 | POLISH |

## Shared findings

- The Home scan panel is the strongest, most ownable element. Its QR-corner
  geometry should become the single product signature.
- Scanner chrome consumes too much camera area and its instruction reads as a
  paragraph rather than a glanceable cue.
- The customer screen combines membership status and form controls into one
  long page; the loyalty state is strong, but the action area needs tighter
  grouping and a clearer boundary.
- Success screens contain useful results but feel vertically unfinished. The
  next-customer action is correct and should remain dominant.
- Revoked, compromised, and update-required states need consistent action or
  guidance regions without treating all three as the same red error.
- App Lock is secure and legible, but the composition has excessive empty
  space and insufficient device-context reassurance.
- Arabic direction is correct overall. Mixed Latin merchant names and IQD
  remain deliberately isolated by the platform's bidi handling.

This audit is the pre-implementation baseline. A second critique is recorded
after the 36-screen M3B set is rendered.

## Second rendered critique

The complete 36-screen set was rendered twice from executable widgets. The
second pass used the same 390 × 844 review viewport after scanner, success,
blocked-state, App Lock, adaptive-grid, and copy refinements.

| Screens | Product quality | Next action | Information load | RTL / scale | Result |
| --- | ---: | --- | --- | --- | --- |
| 01–02 Startup and pairing | 8 | Clear | Restrained | Resilient | SHIP |
| 03–05 Home EN/AR/dark | 9 | Immediate | Minimal | Native RTL; dark intentional | SHIP |
| 06–08 Scanner/permission | 9 | Immediate | Camera-first | Controls remain reachable | SHIP |
| 09–13 Customer/input variants | 8 | Clear after loyalty state | Relevant policy only | Scroll-safe | SHIP |
| 14–18 confirm/success/redeem | 9 | Immediate | Receipt-like | Reset remains authoritative | SHIP |
| 19–25 recovery/error/blocked | 8 | Explicit or deliberately unavailable | Safe copy only | Stable | SHIP |
| 26–29 security/settings/lock | 8 | Clear | Minimal | Touch targets preserved | SHIP |
| 30–32 Arabic loyalty/redeem | 9 | Native RTL action order | No internal metadata | Strong | SHIP |
| 33–34 200% text | 8 | Preserved by scroll | No clipping | Viable | SHIP |
| 35–36 dark loyalty/scanner | 9 | Immediate | Calm | Contrast preserved | SHIP |

The review explicitly rejected generic “stamp issuance” copy, an inaccurate
“Try again” action after a terminal policy failure, and visually empty blocked
states. Those were replaced with Staff language, Scan next customer, and a
clear operations-paused status respectively. No remaining screenshot is below
8/10 in perceived product quality.
