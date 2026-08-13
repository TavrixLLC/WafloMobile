# Review credential operations

Credential material is never committed or compiled into Flutter.

1. Generate a random human-enterable code through the release secret-management process.
2. Normalize it to uppercase `XXXX-XXXX`.
3. Compute `HMAC-SHA256(DEVICE_SESSION_SECRET, "waflo-review-access-v1\n<CODE>")` without logging the code.
4. Store only the hex digest as `REVIEW_ACCESS_CODE_HASH` in the deployment secret store.
5. Set `REVIEW_ACCESS_ENABLED=true`, an explicit future `REVIEW_ACCESS_EXPIRES_AT`, the review tenant slug, attempt limit, and window.
6. Deploy and provision the review tenant with `pnpm review:provision -- --confirm-review-tenant` using the environment's normal database/QR secrets.
7. Supply the plaintext code only through App Store Connect / Play Console secure reviewer fields.

Rotate by replacing the code hash and redeploying. Revoke immediately with `REVIEW_ACCESS_ENABLED=false` or an expired window; every signed review boundary rechecks the window. Default rate policy is five attempts per hashed source address per 15 minutes. Audit records store outcome category and safe device/platform metadata, never the code.
