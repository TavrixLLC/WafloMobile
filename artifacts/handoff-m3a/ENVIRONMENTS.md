# Environment matrix

| Flavor | Entrypoint | API | Release controls |
|---|---|---|---|
| development | `lib/main_development.dart` | controlled local emulator endpoint | test adapter allowed only here |
| staging | `lib/main_staging.dart` | `https://api.staging.waflo.app` | HTTPS, no localhost, no host switching |
| production | `lib/main_production.dart` | `https://api.waflo.app` | HTTPS, no localhost, no test adapter, no host switching |

No credentials, provider keys, or notification/Wallet secrets are compiled into
Flutter. Certificate pinning is not added without an operational rotation model.
