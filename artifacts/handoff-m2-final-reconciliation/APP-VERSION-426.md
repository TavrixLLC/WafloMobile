# App version and HTTP 426

Pairing sends the installed package version normalized to exact `major.minor.patch`; build metadata is not sent. The repaired device context fields `appVersion`, `minimumSupportedAppVersion`, and `appVersionSupported` are consumed, and a successful context requires support to be true.

HTTP 426 with `STAFF_APP_VERSION_UNSUPPORTED` maps to the authoritative Update Required blocked state in English and Arabic. It does not trigger logout or automatic re-pair, and route gating prevents customer operations until an updated app succeeds.
