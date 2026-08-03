# Architecture

M2 follows the existing Riverpod boundaries:

1. `customer_scan` supplies a customer-only camera adapter with an explicit scanner mode.
2. `membership_resolution` owns W4 transport and strict authoritative DTO validation.
3. `loyalty_progress` reduces progress to exactly `filled` or `empty` and renders Program artwork.
4. `stamp_operation` and `reward_redemption` own inputs, results, review, and mutation coordination.
5. `pending_operation` and `core/operation_recovery` own the one-entry recovery journal.
6. Core money, image, signing, and idempotency services are injected into features.

The QR exists only in the private controller field long enough to resolve or submit. Public Riverpod state, routes, widget keys, logs, analytics, and the journal never contain it. M1 session refresh and device blocking remain authoritative.
