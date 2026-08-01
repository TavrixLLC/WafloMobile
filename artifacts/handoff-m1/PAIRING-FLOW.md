# Pairing flow

Strict QR parse → on-device identity → claim → exact challenge validation → local Ed25519 signature → complete → atomic secure session → authoritative context. Completion is never blindly retried. Interrupted completion/local persistence remains fail-closed with an explicit recovery marker.
