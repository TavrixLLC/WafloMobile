# Security scan

The tracked-tree scan rejects backend runtime paths, private keys, credential literals outside fixtures/evidence, usable pairing/customer QR values, and QR fields in pending-operation journals. The absolute-path scan rejects machine-specific homes and local SDK paths.

Production configuration rejects test adapters, non-HTTPS/local endpoints, unsafe logs, flavor mismatches, missing defines, and placeholder hosts. Android production cleartext traffic is disabled and screenshot protection remains enabled.

No offline stamp, redemption, or notification behavior was introduced.
