# Waflo Staff Mobile

Waflo Staff is the Android/iOS staff-device application for Waflo merchants. Milestone M1 establishes a secure Flutter foundation: English/Arabic UI, staff-device pairing, on-device Ed25519 identity, signed device sessions, device-context loading, and explicit blocked states. Customer scanning and merchant operations are intentionally absent.

## M1 scope

- Unpaired boot, camera rationale, QR-only staff pairing scanner, and obscured manual fallback.
- Approved W4 claim → challenge → Ed25519 signature → complete flow.
- Secure identity/session persistence, exact-byte canonical request signing, single-flight refresh, logout, and re-pair recovery.
- Material 3 light/dark UI, Arabic RTL, accessibility semantics, offline display-only state, and safe logging.
- Android/iOS flavors: `development`, `staging`, and `production`.

See [docs/m1/overview.md](docs/m1/overview.md) and [docs/m1/architecture.md](docs/m1/architecture.md).

## Architecture

The code is feature-first and layered. `lib/app` owns bootstrap/routing, `lib/core` owns cross-cutting boundaries, and `lib/features` owns boot, pairing, device session/context, home, and settings. Riverpod provides explicit dependencies and state; Retrofit/JSON models are generated from the mobile-safe W4 OpenAPI subset. Signed session calls use a narrow manual transport wrapper so the SHA-256 digest and signature cover the exact UTF-8 bytes sent.

## Requirements

- Flutter 3.44.8 stable
- Dart 3.12.0
- JDK 21
- Android SDK 36 (minimum device API 23)
- Xcode/macOS for iOS (minimum iOS 13)

## Setup

```text
git clone https://github.com/TavrixLLC/WafloMobile.git
cd WafloMobile
flutter pub get
dart run tool/generate_w4_client.dart
flutter gen-l10n
```

The approved, mobile-safe contract is committed under `contracts/w4/`. Do not copy W4 backend runtime source, environment files, databases, credentials, or keys into this repository.

## Environment configuration

Committed files in `config/` contain no secrets. Development targets the Android emulator host. Staging and production use reserved `.invalid` placeholders because no deployment hosts were supplied; provide an approved HTTPS host through CI/CD `--dart-define` values before distribution. Production validation rejects HTTP, local hosts, debug logging, test adapters, environment mismatch, and unsupplied certificate-pinning mode.

```text
flutter run -t lib/main_development.dart --flavor development --dart-define-from-file=config/development.json
flutter run -t lib/main_development.dart --flavor development --dart-define-from-file=config/development.json --dart-define=WAFLO_API_BASE_URL=http://127.0.0.1:3000
flutter build apk -t lib/main_staging.dart --flavor staging --release --dart-define-from-file=config/staging.json
flutter build apk -t lib/main_production.dart --flavor production --release --dart-define-from-file=config/production.json
```

The second command is the iOS-simulator localhost override. iOS builds use the corresponding Xcode schemes:

```text
flutter build ios -t lib/main_development.dart --no-codesign --flavor development --debug --dart-define-from-file=config/development.json
flutter build ios -t lib/main_staging.dart --no-codesign --flavor staging --release --dart-define-from-file=config/staging.json
flutter build ios -t lib/main_production.dart --no-codesign --flavor production --release --dart-define-from-file=config/production.json
```

## Tests and generation checks

```text
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter test integration_test --flavor development --dart-define-from-file=config/development.json
dart run tool/generate_w4_client.dart --check
dart run tool/security_scan.dart
```

The integration suite requires an Android/iOS runner. The real W4 gate verifies the
approved backend source manifest, builds W4, creates ephemeral pairings, runs 11
contract checks, and cleans the devices. It fails closed unless explicitly enabled:

```text
set WAFLO_RUN_BACKEND_CONTRACT=true
set WAFLO_W4_BACKEND_ROOT=C:\path\to\approved-w4
dart run tool/run_real_w4_contract_gate.dart
```

No QR, private key, control secret, or device token is committed or printed. The
ordinary test suite leaves this external gate skipped; the final CI contract job
does not permit that skip.

## Security notes

- The Ed25519 private key and session record exist only in platform secure storage.
- Android backup/device transfer excludes app data; iOS Keychain data is `ThisDeviceOnly` and not synchronizable.
- Pairing QR hosts are never trusted; API hosts come only from validated build configuration.
- Logs are allowlisted and redact tokens, QR values, keys, signatures, nonces, and challenges.
- Cached context is display-only and never authorizes an operation.
- Signing certificates, provisioning profiles, provider credentials, and production secrets are not committed.

## Localization and accessibility

Generated ARB localization supports English and Arabic with RTL, pluralization, user override, and device-locale fallback. Widget tests cover RTL, 200% text scale, live-region semantics, blocked states, and the obscured manual pairing fallback. TalkBack/VoiceOver hardware review remains a release-device gate.

## Known limitations and M2 handoff

The repaired W4 contract now supplies safe organization, staff, device, current
Location, assigned Location, capability, and update-policy fields. M1 displays
those values without showing internal IDs and handles the distinct revoked,
compromised, session-expired, and update-required codes. Staging maps to W4's
approved `test` pairing environment. The committed staging and production hosts
remain reserved `.invalid` values until deployment URLs are supplied; those builds
therefore fail closed with `CONFIGURATION_ERROR` if launched unchanged.

M2 may add customer operations only after the backend contracts and authorization policies are approved. See [docs/m1/m2-handoff.md](docs/m1/m2-handoff.md). No M2 operation is implemented here.
