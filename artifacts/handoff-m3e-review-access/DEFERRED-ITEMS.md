# Deferred and blocked items

1. Push Backend and Mobile branches and run hosted CI/macOS gates.
2. Deploy Backend SHA `d02435ddce2d79a62cab418f50af08e75d862357` to staging.
3. Provision a secret HMAC, expiry, review tenant, and fixed review fixtures.
4. Run the database-backed Backend HTTP/isolation/concurrency suite.
5. Generate four QR PNGs from the provisioned environment; do not fabricate them locally.
6. Validate review analytics exclusion/classification and provider-side wallet/email/webhook suppression in staging.
7. Perform Android camera/torch/review-mode bug bash on hardware.
8. Perform iOS no-sign CI and later physical iPhone camera/App Lock review.
9. Complete staging Review Access E2E and owner visual approval.
10. Production merchant-artwork transport remains a separate external Backend/Web dependency; review fixtures do not close it.
