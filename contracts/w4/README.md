# Waflo W4 mobile contract bundle

This directory contains the exact mobile-safe machine-readable bundle from the
approved companion **W4 Mobile Contract Compatibility Patch**. The authoritative
source is backend base commit `16e0b4077510073777040450b84af9b055cf2a33` plus the
working-tree sources whose individual hashes are recorded in
`source-manifest.json`.

Bundle integrity:

- Working-tree source checksum:
  `bc3d1c4886643b1b8b399a72a50396e7dc7a4a2b58684fea58cfeb9ddf56beb6`
- Generated bundle checksum:
  `a36b0b24d00c962254d127ea0bc272ceedf94c19556922b4162745aa8c3957d0`
- Credentials or real QR values: none

## Authoritative files

- `openapi.m1.json` — approved OpenAPI 3.1 mobile surface.
- `schemas/m1.schema.json` — approved JSON Schema definitions.
- `stable-error-codes.json` — backend-supported mobile state codes.
- `device-context.fixture.json` — sanitized safe-context examples.
- `pairing-recovery.fixture.json` — sanitized challenge-recovery examples.
- `request-signing.fixture.json` — deterministic signing examples.
- `source-manifest.json` — backend source provenance and per-file SHA-256 values.

The OpenAPI bundle also describes W4 Staff operation endpoints intended for later
mobile milestones. M1 generates the authoritative client as a whole but consumes
only pairing, signed session, logout, and device-context operations. No M2 feature
or UI is implemented here.

## Security boundary

The device creates its Ed25519 key locally. Pairing QR values, one-time secrets,
private keys, session tokens, nonces, and signatures are never committed to this
directory. Control flow uses the stable backend `code`, while backend messages are
not treated as localization strings.
