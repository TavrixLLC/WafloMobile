# M3G screen and state coverage

## Implemented A+ language

| Surface/state | Evidence |
|---|---|
| Pairing welcome and authorized access | `01-pairing-en-light.png` |
| Home light / Arabic RTL / dark / 200% | `02`–`05` |
| Scanner ready / detected / resolving / invalid / permission denied | `06`–`10` |
| Scanner reduced motion / Arabic RTL / dark / 200% | `11`, `33`–`35` |
| Customer 0/8 / 5/8 / 8/8 | `12`–`14` |
| Customer Arabic RTL / dark / 200% | `15`–`17` |
| Stamp confirmation / success | `18`–`19` |
| Redeem confirmation | `20` |
| Manager approval required / pending / rejected / expired | `21`–`24` |
| Redeem success | `25` |
| Ambiguous/pending operation recovery | `26` |
| Billing blocked | `27` |
| App Lock PIN / biometric / 200% | `28`–`29`, `36` |
| Device & Security / 200% | `30`, `37` |
| Settings / 200% | `31`, `38` |
| Session expired | `32` |

All filenames above are under
`artifacts/m3g-a-plus/flutter-screenshots/`.

Additional authoritative states remain carried by the existing production
controllers and were regression-tested, including device revoked, staff or
membership inactive, location invalid, offline/network errors, expired QR,
camera unavailable/permanent denial, scanner background/resume, approval
checking, successful approval continuation, and safe operation recovery.

No duplicate product screens or parallel fake state machines were created.
