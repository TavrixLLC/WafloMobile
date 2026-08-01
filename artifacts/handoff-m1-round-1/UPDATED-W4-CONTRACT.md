# Updated W4 contract

The exact approved companion bundle was copied to `contracts/w4/`.

- Backend base commit: `16e0b4077510073777040450b84af9b055cf2a33`
- Working-tree source checksum: `bc3d1c4886643b1b8b399a72a50396e7dc7a4a2b58684fea58cfeb9ddf56beb6`
- Generated bundle checksum: `a36b0b24d00c962254d127ea0bc272ceedf94c19556922b4162745aa8c3957d0`

All six bundle-file SHA-256 values match `source-manifest.json`. Dart generation
deletes and recreates the full API tree from `openapi.m1.json`, applies one
deterministic duplicate-header normalization, runs serializers, and formats the
result. `--check` compares the complete before/after tree and passed locally.

The authoritative OpenAPI contains later Staff operation descriptions, but M1
does not consume them as features.
