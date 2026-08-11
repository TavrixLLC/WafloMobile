# M3B design direction

## Subject and job

Waflo Staff is a bilingual counter instrument for a cashier serving a queue.
Its visual job is to expose one safe next action while keeping merchant,
location, customer, and transaction context unmistakable.

## Tokens

- Counter Ink — `#171A18`: primary copy and scanner-night foundation
- Waflo Evergreen — `#006B55`: decisive action and confirmed readiness
- Signal Mint — `#8EDCC5`: dark-mode action and positive emphasis
- Receipt — `#F7F6F1`: quiet operational canvas
- Warning Amber — `#B45F00`: recoverable attention and pending work
- Safety Red — `#BA2D27`: revoked/compromised boundaries only

Typography keeps Waflo Sans for decisive Latin headings and body copy, Waflo
Arabic for Arabic shaping, and tabular numeral features for progress and money.
The hierarchy is intentionally compact: one display result, one operational
heading, one body instruction, and one utility label.

## Layout

Home:

```text
[ready + location]
[merchant]

┌ scan-corner ──────────┐
│ SCAN CUSTOMER      QR │
└──────────────── corner┘

[Device & Security] [Settings]
```

Customer operation:

```text
[customer + program]
[progress number]
[adaptive FILLED / EMPTY grid]
[reward outside grid, if ready]
──────── action rail ────────
[quantity / required money]
[single primary action]
```

Scanner:

```text
[close] [location]

      ┌ scan frame ┐
      │   camera   │
      └────────────┘
      short live status

[flash]                    [help/cancel]
```

## Signature and restraint

Scanner-corner geometry is the one deliberate visual risk. It connects Home,
camera recognition, operation recovery, and Scan Next Customer without adding
illustration or decoration. Cards remain flat, borders remain quiet, and
motion is limited to state transitions that help a cashier understand what the
system accepted.

The initial idea of expanding mint panels and celebratory surfaces was rejected
because it would make the product resemble a generic loyalty template. M3B
instead spends its visual emphasis on the scan rail and authoritative progress.
