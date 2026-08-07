# Command recovery

The typed command state is exactly `PROCESSING`, `COMPLETED`, or `FAILED`.

- `PROCESSING` retains the same command journal, blocks scanning, and performs no new mutation.
- `COMPLETED` validates command ID and operation/result compatibility, presents the authoritative result, and clears only after acknowledgment.
- `FAILED` presents a localized safe failure and never creates an automatic replacement command.

Wrong-device, cross-tenant, and not-found remain indistinguishable safe not-found outcomes. Restart tests cover the persisted processing and failure paths. This is not an offline queue; offline mutations remain forbidden.
