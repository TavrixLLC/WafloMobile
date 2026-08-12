# Waflo Staff Mobile

Waflo Staff is the Android/iOS staff-device application for Waflo merchants.
M1 is complete and M2 is implemented: Staff can pair a device, scan and resolve
a customer Membership, issue stamps, redeem eligible rewards, and recover an
ambiguous command through authoritative status checks.

This repository contains mobile source only. It does not contain or modify the
Waflo backend.

## Current mobile scope

- M1: secure pairing, on-device Ed25519 identity, signed device sessions,
  authoritative device context, explicit blocked states, English/Arabic UI,
  RTL, accessibility, and Android/iOS flavors.
- M2: customer scanning, Membership resolve, authoritative two-state stamp
  progress, online stamp/redeem operations, idempotency, and ambiguous-command
  recovery.
- M3A: production-oriented Staff UI, deterministic readiness states, hardened
  scanner lifecycle, Rapid Scan cleanup, local App Lock, privacy cover, Device
  & Security, and an English/Arabic light/dark design system.
- Loyalty mutations are online-only. There is no offline stamp, redemption, or
  mutation queue and no offline success state.
- Manager approval acquisition is not implemented. Rewards requiring approval
  remain blocked.
- Real customer notification delivery is not implemented.
- M3A remains mobile-only. It introduces no backend API, Wallet issuance,
  notification delivery, social sign-in, or loyalty-economics change.

The Staff flow remains task-focused: scan a customer, review authoritative
status, perform one safe action, and finish. Ledger, signing, session, and
database identifiers are not product UI.

## Authoritative M2 contract

The generated Mobile M2 bundle under `contracts/w4/m2/` is consumed as-is from:

- backend branch: `fix/p5-m2-final-reconciliation`
- backend commit: `0cc39d9ecb39a34fdbd91498e55b6d6ac35c281e`
- bundle SHA-256:
  `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- recovery classification:
  `PARTIAL_W4_RECOVERY_WITH_M2_COMPATIBILITY_RECONSTRUCTION`
- migrations: 24 total; no migration added for M2

The historical missing M2 patch is not represented as recovered. The repaired
backend reconstructs an M2 compatibility layer over recovered W4 source and
provides reproducible generated contracts. Its handoff reports 427/427 backend
tests passing. The repaired M2 Mobile baseline was formally approved by Real W4
run `31487360271`, job `93765720145`: 26/26 Flutter and 16/16 backend tests
passed. M3A preserves the immutable M2 contract bundle.

## Architecture and safety

The code is feature-first and layered. `lib/app` owns bootstrap and routing,
`lib/core` owns cross-cutting boundaries, and `lib/features` owns product flows.
Riverpod provides explicit dependencies. Generated Retrofit/JSON models come
from the committed W4 contracts; hand-maintained adapters validate projections
before they reach UI state.

Server rules remain authoritative. Mobile does not override Location policy,
daily caps, reward eligibility, roles, or manager approval. Production rejects
HTTP/local API hosts, debug/test adapters, and incomplete flavor configuration.
QR values, customer names, purchase references, tokens, keys, signatures, and
nonces are excluded from persistent logs and handoff archives.

## Toolchain

- Flutter 3.44.3 stable
- Dart 3.12.2
- JDK 21
- Android SDK 36 (minimum device API 23)
- Xcode/macOS for iOS (minimum iOS 13)

## Setup

```text
git clone https://github.com/TavrixLLC/WafloMobile.git
cd WafloMobile
flutter pub get
dart run tool/verify_m2_contracts.dart
dart run tool/generate_w4_client.dart --check
flutter gen-l10n
```

Committed `config/` files contain no secrets. Development can target the
Android emulator host. Staging is fixed to `https://api-staging.waflo.app` and
production is fixed to `https://api.waflo.app`; release builds provide no host
switching UI and reject HTTP/local endpoints.

## Local verification

```text
dart run tool/verify_m2_contracts.dart
dart run tool/generate_w4_client.dart --check
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
dart run tool/security_scan.dart
dart run tool/absolute_path_scan.dart
```

Android/iOS integration requires an appropriate emulator or runner. The final
Real W4 gate is separate, mandatory, and must use the approved self-hosted runner
and backend commit; an ordinary skipped contract test is not a pass.

See `docs/m1/`, `docs/m2/`, `docs/m3a/`, and `artifacts/handoff-m3a/` for
architecture, testing, physical-device preparation, screenshots, and evidence.
