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

- Flutter 3.44.0 stable
- Dart 3.12.0
- JDK 21
- Android SDK 36 (minimum device API 23)
- Xcode/macOS for iOS (minimum iOS 13)

## Setup

```text
git clone https://github.com/TavrixLLC/WafloMobile.git
cd WafloMobile
flutter pub get
dart run swagger_parser -f swagger_parser.yaml
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

The approved, mobile-safe contract is committed under `contracts/w4/`. Do not copy W4 backend runtime source, environment files, databases, credentials, or keys into this repository.

## Environment configuration

Committed files in `config/` contain no secrets. Development targets the Android emulator host. Staging and production use reserved `.invalid` placeholders because no deployment hosts were supplied; provide an approved HTTPS host through CI/CD `--dart-define` values before distribution. Production validation rejects HTTP, local hosts, debug logging, test adapters, environment mismatch, and unsupplied certificate-pinning mode.

```text
flutter run --flavor development --dart-define-from-file=config/development.json
flutter run --flavor development --dart-define-from-file=config/development.json --dart-define=WAFLO_API_BASE_URL=http://127.0.0.1:3000
flutter build apk --flavor staging --debug --dart-define-from-file=config/staging.json
flutter build apk --flavor production --debug --dart-define-from-file=config/production.json
```

The second command is the iOS-simulator localhost override. iOS builds use the corresponding Xcode schemes:

```text
flutter build ios --no-codesign --flavor development --debug --dart-define-from-file=config/development.json
flutter build ios --no-codesign --flavor staging --release --dart-define-from-file=config/staging.json
flutter build ios --no-codesign --flavor production --release --dart-define-from-file=config/production.json
```

## Tests and generation checks

```text
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter test integration_test --flavor development --dart-define-from-file=config/development.json
dart run tool/security_scan.dart
```

The integration suite requires an Android/iOS runner. The opt-in real W4 contract test is skipped unless a seeded development backend and temporary pairing QR are supplied as compile-time defines; it never writes key material to the repository. CI repeats code generation and fails on a diff.

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

The approved W4 context returns internal IDs plus role/platform, not staff, organization, or location display names; M1 does not expose raw IDs or invent names. Approved W4 round 1 also does not define distinct revoked/compromised/minimum-version codes, so those UI states are implemented and tested but await backend codes. The staging app maps to W4's internal `test` environment. Real backend certification and iOS no-sign results require external infrastructure/CI.

M2 may add customer operations only after the backend contracts and authorization policies are approved. See [docs/m1/m2-handoff.md](docs/m1/m2-handoff.md). No M2 operation is implemented here.
