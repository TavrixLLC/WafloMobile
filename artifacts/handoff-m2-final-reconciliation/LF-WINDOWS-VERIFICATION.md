# LF and Windows verification

`.gitattributes` applies `text eol=lf` narrowly to checksum-controlled JSON, Markdown, YAML, and YML under `contracts/w4/`. Binary normalization was not enabled.

The verifier checks committed bytes, exact generated hashes, aggregate digest, provenance, safety flags, schema invariants, and LF bytes.

Fresh Windows worktree results:

- 26 contract text files inspected; all used LF with no CRLF bytes
- exact 13-file verifier passed against backend `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- intentional one-byte change to `membership-resolve.fixture.json` failed with checksum mismatch and exit code 1
- the probe file was restored and the tracked worktree returned clean

Generated-client check mode canonicalizes only platform line endings when comparing generated Dart and restores the original checkout bytes afterward. Any model/content/file-set difference remains drift and fails.
