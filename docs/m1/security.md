# Security

Security boundaries:

- API hosts come only from validated build configuration; QR data cannot redirect traffic.
- Production requires HTTPS/non-local hosts, minimal logs, no test adapter, and the production pairing environment.
- Pairing and signed requests have strict size/format validation and no blind completion replay.
- Keys/tokens live only in secure storage; ordinary preferences are display-only.
- Logs allowlist fields and redact authorization, QR, token, key, signature, nonce, challenge, and secret forms.
- Network responses are bounded and expected to be JSON; redirects and generic network logging are disabled.
- Cached context cannot authorize an operation, and no offline operation exists.
- App-switcher privacy cover hides content when inactive/paused/hidden.
- Android backup/device transfer is excluded; iOS Keychain is this-device-only/non-sync.

Certificate pinning is disabled because no approved pins/rotation policy were supplied; enabling the flag deliberately fails configuration. Crash reporting uses no credentials and is disabled. The repository scanner rejects backend runtime paths, credential-like runtime literals, private-key markers, databases, and signing files.
