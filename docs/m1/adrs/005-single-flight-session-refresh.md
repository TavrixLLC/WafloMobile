# ADR 005: Single-flight refresh

Status: accepted.

All concurrent refresh requests share one future. Successful credentials replace the secure record once; persistence failure fails closed. This prevents token rotation races and replay of superseded refresh tokens.
