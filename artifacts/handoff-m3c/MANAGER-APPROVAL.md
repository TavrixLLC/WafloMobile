# Redeem-only Manager approval

## State machine

The domain models all Production-v1 states centrally:

`REQUIRED`, `PENDING`, `CHECKING`, `REJECTED`, `EXPIRED`, `CONSUMED`, `MISMATCH`, `INVALID`, `NOT_APPLICABLE`, `ALREADY_DECIDED`, `STALE`, and `APPROVER_INACTIVE`.

Widgets render domain state; they do not compare machine-code strings.

## Initial request

The first signed redeem contains the customer QR payload, reward entitlement public ID, optional note, and durable command/idempotency UUID. It contains no approval fingerprint and no internal Membership, entitlement, device, or Location ID.

For a valid `409 MANAGER_APPROVAL_REQUIRED` or `MANAGER_APPROVAL_PENDING`, Mobile strictly validates:

- `operationType == REDEEM`
- `retryWithSameIdempotencyKey == true`
- a UUID approval public ID
- an allowed approval status
- a parseable expiry

The exact semantic redeem intent is stored in secure storage. The normal pending journal retains only safe blocking/recovery metadata and contains neither QR nor approval public ID.

## Retry and recovery

After Merchant Web approval, the originating device retries the exact semantic redeem with the same command UUID and the returned `managerApprovalPublicId`. Request ID, timestamp, nonce, body digest, and Ed25519 signature are regenerated for every transmission.

If the approved retry response is lost, Mobile keeps the same command and approval intent, then uses command-status recovery. It never creates a replacement mutation.

Rejected and expired intents require a new deliberate Staff attempt. Consumed, mismatch, invalid, not-applicable, already-decided, stale, and inactive-approver states fail closed, clear the unusable approval intent, and require authoritative state refresh.

## UX

The visual signature is a compact three-step handoff rail: Staff requested → Manager decides on Web → Staff completes here. It communicates ownership without implying that the phone can approve. Required, pending, terminal, Arabic, dark, and 200% text states are in the screenshot set.
