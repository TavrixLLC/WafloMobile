# Backend contract

The application consumes only `contracts/w4/`. Generated M1 operations are pairing claim/complete, session refresh/logout, and device context. `DateTime`→`IsoDateTime` and inline-error extraction are generator-only schema-name adapters with unchanged JSON wire fields. No backend source was copied.

W4 gaps: context lacks display names; round 1 lacks distinct revoked/compromised/update codes. The UI does not expose internal IDs or invent values.
