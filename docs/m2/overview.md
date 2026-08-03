# M2 overview

M2 activates online Staff loyalty operations on the locked M1 device foundation. A Staff member explicitly opens the customer scanner, submits an opaque membership credential to W4, reviews an authoritative Membership projection, and may issue stamps or redeem an available reward. Every mutation is signed and idempotent; an uncertain result is recovered by command ID instead of being repeated.

The approved mobile-only contract is `contracts/w4/m2/`. Backend source, runtime files, credentials, real customer data, and usable QR values are excluded. M3/M4 features are not implemented.

The main coordinator is `M2OperationController`. UI screens consume validated domain objects and never sign requests, serialize API bodies, persist credentials, or perform money arithmetic.
