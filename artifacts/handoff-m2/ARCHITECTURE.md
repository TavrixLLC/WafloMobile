# Architecture

See `docs/m2/architecture.md`. Riverpod remains the only state-management framework. UI owns presentation; domain objects own validation; transport owns JSON/signing; core services own money, idempotency, image digest caching, and journal persistence.
