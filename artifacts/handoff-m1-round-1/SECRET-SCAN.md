# Secret scan

`tool/security_scan.dart` enumerates tracked and unignored files and rejects
environment files, databases, key stores, private-key markers, backend runtime
source, credential-like runtime literals, and usable pairing QR literals.

Final scan result is recorded in `raw-test-output/security-scan.log`. The real W4
runner additionally redacts QR, token, private-key, and authorization patterns.
