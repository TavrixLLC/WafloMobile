# Request signing

The canonical UTF-8 envelope is exactly nine LF-separated lines:

```text
waflo-device-request-v1
METHOD
/canonical/path
request-id
UTC timestamp
nonce
lowercase SHA-256 body digest
device-session-id
organization-id
```

No trailing newline, query, or fragment is allowed. Required headers include Device authorization, device/session/request IDs, timestamp, nonce, digest, and Ed25519 signature. Empty bodies use the standard empty SHA-256. Non-empty bodies are serialized once and the exact transmitted bytes are hashed. Tests match both approved W4 canonical fixtures and generate unique nonce/timestamp/signature values.
