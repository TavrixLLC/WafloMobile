# M3F hidden Demo entry, scanner parity, and design pack

Starting SHA: `510d6f3336ad12d8fcafd7334b5a007390e18b3d`

Branch: `feature/m3f-hidden-demo-scanner-design-pack`

Normal users now see only merchant pairing and a standard Waflo scanner. The prior public Demo/Review card is removed. A generic manual-code surface behind the scanner routes normal pairing payloads, server-authorized Review credentials, and—only in development/staging debug with an injected owner code—the isolated local presentation Demo.

The pairing scanner now uses the same adaptive Waflo target, 2.3-second beam, status treatment, torch control, RTL behavior, semantics, and Reduce Motion behavior as customer scanning. The sanitized Lovable pack is at `artifacts/lovable-mobile-design-pack/`.
