# ADR 002: No offline loyalty mutations

Status: accepted.

Offline mode permits static/local settings and safe cached context only. Stamp,
redemption, and notification mutations are never queued and never report fake
success.
