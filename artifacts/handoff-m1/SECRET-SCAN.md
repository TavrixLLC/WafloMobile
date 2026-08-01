# Secret scan

`dart run tool/security_scan.dart` checks repository paths for environment/signing/database/backend-runtime artifacts and text for private-key markers, runtime credential literals, and pairing QR literals. Deterministic W4 fixtures are server-invalid and explicitly separated. Final result and exit code are in the quality-gate record.
