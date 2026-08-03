# Error mapping

All stable M2 codes in `stable-error-codes.m2.json`, plus M1 device/session codes that can interrupt M2, map to localized messages and safe next actions. Categories cover rescan, Membership/Program, Location, stamp policy, purchase, reward, Manager approval, idempotency/recovery, rate limiting, risk block, session/device, network, and malformed contract response.

The UI may show a request ID for support. It never relies on a raw backend message, displays a stack trace, or reveals risk-rule details. Retry is available only where it cannot duplicate a mutation; ambiguous mutations use command-status recovery.
