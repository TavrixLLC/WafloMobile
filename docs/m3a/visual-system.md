# Waflo Staff visual system

## Product frame

Waflo Staff is a retail instrument, not a merchant dashboard. Its visual
language borrows from a clean paper receipt, a dependable counter terminal, and
the square cadence of a QR target. Each screen should make one operational
action dominant and let context recede.

## Token exploration

### Color tokens

| Token | Hex | Role |
| --- | --- | --- |
| Counter Pine | `#075E46` | Primary actions and confirmed readiness |
| Deep Counter | `#103A2F` | High-contrast action surfaces and dark-mode structure |
| Fresh Mint | `#DFF3EA` | Positive, low-emphasis status fields |
| Receipt | `#F7F5EF` | Warm light-mode canvas |
| Signal Amber | `#A85D00` | Pending, offline, and caution states |
| Seal Red | `#B3261E` | Revoked, compromised, and destructive actions |

Neutral ink and outlines are derived semantically from the theme rather than
introduced as decorative brand colors.

### Typography roles

- **Shift display:** 30–36sp, bold, tight tracking. Used for the current
  merchant, customer, success outcome, and large progress value.
- **Action voice:** 17–20sp, bold. Used for the one primary Staff action.
- **Operational label:** 12–13sp, medium, modest tracking. Used for readiness,
  location, and section labels.
- **Body:** 15–16sp, regular. Used for short explanations and summaries.

The existing `WafloSans` and `WafloArabic` assets remain the font families, so
Arabic rendering does not regress and no network font dependency is added.

## Layout alternatives considered

### A — terminal dashboard (rejected)

```text
[ App bar                 ]
[ ready card              ]
[ merchant card           ]
[ location card           ]
[ scan button             ]
[ settings card           ]
```

This repeats the approved-M2 card stack and makes every block compete.

### B — bottom command dock (not selected)

```text
[ merchant + ready        ]
[ location                ]
[                        ]
[ support links           ]
===========================
[ SCAN CUSTOMER dock      ]
```

Reachability is strong, but the persistent dock is awkward on scanner and
operation screens and resembles a generic commerce app.

### C — scan stage (selected)

```text
[ Waflo Staff       menu  ]

  READY BEACON  DEVICE READY
  Merchant name
  Location name

[┌                         ]
[   Scan customer          ]
[   Point at membership QR ]
[                    ┘  →  ]

  Device & Security    Settings
```

The central action surface sits in the natural thumb zone, while readiness and
location remain visible without becoming dashboard cards.

## Signature element

The **Ready Beacon** is a compact square module with one inset square. It echoes
a QR finder pattern without depicting or storing a QR. It appears beside
readiness, success, and security states, giving Waflo a recognisable operational
rhythm without adding decorative illustration.

## Generic-default critique and revision

The first preserved M3A direction still depended on rounded cards, `ListTile`,
and standard Material icons for nearly every piece of information. That could
belong to any administrative app. The revision:

- removes bottom navigation from the two-destination shell;
- treats background space as structure instead of wrapping every section;
- limits prominent rounded surfaces to the primary action, critical recovery,
  and confirmation/success states;
- uses typography and alignment for identity/context;
- retains icons only where they clarify an action or status;
- repeats the Ready Beacon and scanner-corner geometry as product-specific
  motifs;
- keeps shadows near zero and uses borders/tonal contrast for hierarchy.

## Component rules

- Primary actions are at least 56dp tall and full-width on compact phones.
- Secondary actions are quiet rows or outlined buttons, never competing filled
  cards.
- Status chips contain short state only; explanations sit beside or below.
- Customer identity is grouped as one semantic header.
- Stamp progress has one concise semantic label; individual positions are
  excluded from accessibility traversal.
- Recovery and destructive actions use explicit confirmation and never rely on
  color alone.
- Motion is short and functional; reduced-motion users see immediate state
  changes.

## Dark mode

Dark mode uses Deep Counter as the canvas family, pale mint for readable action
contrast, and low-chroma surfaces. Merchant-provided artwork is never recolored.
Error and warning contrast is validated independently of the light palette.
