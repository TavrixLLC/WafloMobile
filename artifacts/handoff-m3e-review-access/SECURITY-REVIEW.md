# Security review

No master password, skip-auth flag, Staff login, arbitrary tenant/Location/customer ID, merchant cookie call, or unsigned Review Tools call was introduced. Review codes are validated only by Backend HMAC comparison with timing-safe equality, expire server-side, are rate-limited by hashed source address, and are absent from audit metadata.

Review sessions retain Ed25519 challenge proof and signed transport. Guards verify explicit mode and exact fixed tenant bindings. Review Tools are absent for normal sessions. Exit Demo clears review authority and cached operational state.

The Mobile security scan checks runtime source for credential-shaped Review secrets and bypass identifiers. All built APKs were searched for a known sample code, review-secret assignment, old staging hostname, and bypass identifiers: clean. A generic eight-character regex is intentionally not used against native binaries because random compiled bytes generate false positives.

Static/unit verification is green. Database HTTP isolation, deployed rate limiting, provider-side suppression, and physical review remain mandatory before release-candidate status.
