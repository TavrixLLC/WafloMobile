# Security scan

The tracked-tree scan rejects backend runtime paths, private keys, credential
literals outside fixtures/evidence, usable pairing/customer QR values, and QR
fields in pending-operation journals. The absolute-path scan rejects
machine-specific homes and local SDK paths.

Final runtime-sweep evidence was additionally inspected before staging:

- machine-specific absolute-path hits: 0
- PostgreSQL URL or `DATABASE_URL` assignments: 0
- usable pairing/customer QR prefixes: 0
- private-key delimiters: 0
- `.env` contents: not captured

Final staged-evidence result:

- `tool/security_scan.dart`: pass across 662 scanned tracked files
- `tool/absolute_path_scan.dart`: pass across 662 scanned tracked files

Production configuration rejects test adapters, non-HTTPS/local endpoints, unsafe logs, flavor mismatches, missing defines, and placeholder hosts. Android production cleartext traffic is disabled and screenshot protection remains enabled.

No offline stamp, redemption, or notification behavior was introduced.
