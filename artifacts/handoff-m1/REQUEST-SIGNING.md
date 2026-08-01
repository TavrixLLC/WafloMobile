# Request signing

The nine-line `waflo-device-request-v1` envelope, lowercase SHA-256, UTC timestamp, fresh nonce/request ID, and Ed25519 signature match the approved provider and M1 refresh fixtures. The digest covers the exact body string passed to Dio.
