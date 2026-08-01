# ADR 002: Riverpod state management

Status: accepted.

Use Riverpod Notifiers/providers for explicit dependency construction and test overrides. It avoids secret-bearing global mutable singletons and keeps business state outside widgets.
