# Security boundary

This pack intentionally omits network clients, endpoint catalogs, session persistence, signing, cryptography, credentials, environment files, administrative routes, real QR payloads, and real people.

Demo/Review is not a bypass. Production authorizes review credentials on the server and isolates review data. Local Demo is debug-only presentation QA, has no server identity, and can mutate only deterministic fixture state.

Prototype only the visible states. Never infer production authorization behavior from the screenshots or UI-reference notes.
