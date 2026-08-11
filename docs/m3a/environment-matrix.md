# Mobile environment matrix

| Flavor | API host | Transport | Test adapter | Host switching |
| --- | --- | --- | --- | --- |
| development | Build-time controlled local endpoint | HTTP allowed only for loopback/private development hosts | Allowed only when explicitly compiled | Build-time only |
| staging | `https://api.staging.waflo.app` | HTTPS required | Forbidden | None in release UI |
| production | `https://api.waflo.app` | HTTPS required | Forbidden | None |

All values are supplied at build time. Flutter stores no provider credentials,
backend secret, Wallet credential, or production authentication material.
Certificate pinning stays disabled because this repository has no approved
pin-rotation and incident-recovery model.
