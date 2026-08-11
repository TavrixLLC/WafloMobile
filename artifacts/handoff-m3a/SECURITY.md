# Security and privacy result

- optional biometric or Local Staff PIN App Lock implemented
- PIN plaintext is never stored; verifier material is secure-storage-only
- progressive local rate limits implemented and tested
- immediate background privacy cover implemented and tested
- QR cleared after use/background and absent from journals, routes, logs, keys,
  crash context, clipboard, and screenshots
- customer and purchase-reference data excluded from persistent logs
- one mutation at a time; double taps share the in-flight operation
- pending command blocks scanning and survives restart
- logout remains destructive and confirmed
- production cannot use local/HTTP API or test scanner
- no provider credentials or backend source in Mobile

`dart run tool/security_scan.dart` and
`dart run tool/absolute_path_scan.dart` pass locally.
