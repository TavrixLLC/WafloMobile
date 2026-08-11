# Staging readiness

- Staging API: `https://api.staging.waflo.app`
- Production API: `https://api.waflo.app`
- Staging/production require HTTPS and have no runtime host editor.
- Test scanners/adapters are forbidden by production binding.
- No Flutter secret, Wallet credential, provider credential, or production
  authentication value is required or stored.
- Offline loyalty mutation remains impossible.

Once staging is deployed, physical E2E can begin without feature code changes.
External dependencies are endpoint availability, approved real merchant data,
device pairing authority, physical hardware, and platform signing.
