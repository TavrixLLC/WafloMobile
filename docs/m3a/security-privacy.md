# Security and privacy

App Lock is an optional local privacy layer and is not Staff authorization.
Modes are Off, platform biometric, or Local Staff PIN. PINs are 4–6 ASCII
digits. Only a PBKDF2-HMAC-SHA256 verifier, random salt, configuration, and
rate-limit state are stored in secure storage. Progressive delays cap at five
minutes. Biometric checks use `local_auth`.

Backgrounding immediately overlays the app and excludes underlying semantics.
Customer QR and active credential state are cleared. Valid backend sessions and
safe pending-command recovery survive. Android `FLAG_SECURE` remains enabled.

The main UI never exposes tokens, session IDs, keys, signatures, nonces,
database IDs, raw command IDs, or internal errors. Customer names, QR values,
and purchase references are excluded from persistent logs and crash context.
No clipboard action exists for customer identity or QR.

There is one active mutation at a time. Double taps share the same in-flight
future. Pending recovery, blocked device state, or update-required state blocks
new scans and mutations. No local role, location, daily-cap, reward, or manager
approval override exists.
