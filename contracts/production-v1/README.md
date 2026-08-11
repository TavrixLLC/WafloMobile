# Production-v1 Mobile authority

This directory is a current Mobile verification layer. It does not replace or
rewrite the immutable historical M2 evidence under `contracts/w4/m2/`.

`mobile-authority.json` records the Backend Production-v1 authority at
`763f2dfccdb24fb9bfa16457f0e49936840e20a1`, the supplied documentation
fingerprints, the direct Mobile route classification, and the locked Mobile
integration rules used by `tool/verify_production_v1_contract.dart`.

The source documents were supplied in `mobile.zip`. They remain Backend-owned;
this directory contains only the narrow, reviewable Mobile authority index.
