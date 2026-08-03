# Testing

Local gates are:

```text
dart run tool/verify_m2_contracts.dart
dart run tool/generate_w4_client.dart --check
flutter analyze --fatal-infos --fatal-warnings
flutter test
dart run tool/security_scan.dart
```

Unit coverage validates strict projections, two states, money, reference rules, cache/digest, stable IDs, journal serialization, recovery, redaction, and controller transitions. Widget coverage exercises customer scanner, 0/5/8 progress, purchase/review/success, rewards, Manager block, final reset, pending/error, Arabic/RTL, text scale, dark theme, and semantics. The Android emulator integration file records the required 24-scenario matrix through DI while production retains the real camera adapter.

The approved self-hosted runner verifies the exact W4 source commit/checksums and runs both M1 and backend-owned M2 real contract gates. iOS no-sign builds run only on macOS CI.
