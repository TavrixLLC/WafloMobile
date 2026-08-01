# Environments

| Flavor | App ID / bundle ID | Pairing environment | Transport |
|---|---|---|---|
| development | `app.waflo.staff.dev` | `development` | Local HTTP only or HTTPS |
| staging | `app.waflo.staff.staging` | `test` | HTTPS, non-local |
| production | `app.waflo.staff` | `production` | HTTPS, non-local |

W4 round 1 exposes `development`, `test`, and `production`; therefore the staging product flavor uses a documented adapter to the backend `test` identifier. The QR never supplies an API host.

`config/staging.json` and `config/production.json` intentionally use reserved `.invalid` hosts until deployment endpoints are approved. CI/CD may override the URL without adding secrets. Production fails configuration validation for HTTP/local URLs, test adapters, non-minimal logging, mismatched QR environments, non-backend version policy, or certificate pinning without supplied pins.
