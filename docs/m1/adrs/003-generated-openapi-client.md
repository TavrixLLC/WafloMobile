# ADR 003: Generated OpenAPI client

Status: accepted.

Generate typed Retrofit/JSON code from the M1-only W4 OpenAPI subset. Preserve a narrow exact-byte manual transport only for signed calls; it consumes generated response models. CI regenerates and rejects drift.
