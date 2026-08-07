# Waflo W4 M2 mobile contract bundle

The 13 authoritative generated files in this directory were adopted byte for
byte from the verified W4 M2 provenance-repair handoff. This README is Mobile
documentation and is not one of those generated payloads.

- Contract version: `waflo-m2-mobile-contract-v1`
- Generator version: `waflo-m2-contract-generator-v1`
- Backend branch: `fix/p5-m2-final-reconciliation`
- Backend commit: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- Parent commit: `2b0000c5541cff0128804992780aaa80853e2655`
- Bundle SHA-256:
  `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- Reconstruction:
  `PARTIAL_W4_RECOVERY_WITH_M2_COMPATIBILITY_RECONSTRUCTION`
- Migration count: 24
- M2 migration added: no

The missing historical M2 patch was not claimed as recovered. The approved
backend reconstructed M2-compatible Mobile contracts over recovered W4 source.
The manifest records all 12 generated-file hashes and safety flags; the Mobile
verifier recomputes every file hash and the aggregate bundle checksum.

Generated contract payloads must not be hand-edited. `.gitattributes` preserves
canonical LF bytes on Windows, and `tool/verify_m2_contracts.dart` fails on byte
drift, wrong inventory, provenance mismatch, unsafe manifest flags, schema
weakening, or a non-authoritative command-status set.
