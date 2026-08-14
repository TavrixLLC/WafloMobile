# Production exclusion

- Production entrypoint imports no local debug bootstrap.
- Product providers default to the deny-all local runtime.
- Product manual-code resolver has no local matcher.
- Debug owner-code resolver is imported only by the debug bootstrap.
- Production config forbids local Demo.
- Product route table defaults to no local scenario routes.
- Simulation-control slots default to empty.
- APK verifier rejects scenario routes, simulation markers, fixture PIN, owner-code define marker, and debug resolver marker.
- Server Review authorization remains the only Review path in production.

Verification entrypoints:

```text
dart run tool/verify_local_demo_exclusion.dart
dart run tool/verify_local_demo_apk.dart <production-or-staging-release-apk>
```
