# Flavor binding

Entrypoints are explicit:

- `lib/main_development.dart`
- `lib/main_staging.dart`
- `lib/main_production.dart`

Each passes its expected native flavor to bootstrap. Dart configuration must
supply a recognized `WAFLO_ENV`, API URL, pairing environment, and log level,
and its environment must exactly match the native flavor. The generic
`lib/main.dart` has no expected flavor, so a production-capable accidental
default fails closed.

Missing values, mismatches, unsafe production transport, local production hosts,
test adapters, debug logs, and reserved deployment placeholders render
`CONFIGURATION_ERROR`. Staging and production config files intentionally retain
`.invalid` hosts until approved deployment URLs are supplied.
