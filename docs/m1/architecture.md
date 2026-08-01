# Architecture

The project uses feature-first layered architecture:

- `app/`: validated environment, bootstrap, router, dependency graph, and lifecycle privacy cover.
- `core/`: generated API types, signing/identity, secure storage, localization, design system, network policy, safe errors, and logging.
- `features/`: boot, pairing, device session/context, paired shell, and settings.

Presentation widgets render state and dispatch intents. Riverpod notifiers own view/boot transitions. Domain services coordinate pairing and session rules. Data adapters are the only HTTP/platform boundary. Models are typed; generated OpenAPI files are never edited manually.

The signed transport deliberately serializes a body once, hashes those exact UTF-8 bytes, signs the canonical nine-line envelope, and sends the same string. This avoids generator or interceptor re-serialization changing signed bytes.
