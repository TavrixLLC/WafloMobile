# Testing strategy

Local gates cover immutable contract/LF verification, generated-client and
localization drift, formatting, fatal analysis, unit, widget, goldens, security,
absolute-path hygiene, and all three Android APK flavors.

The M3A emulator test adds 15 checkpoints for paired readiness, scanner privacy,
resolve, review, double-submit prevention, success, Rapid Scan cleanup,
background cleanup, ambiguous recovery, scanner blocking, same-command
recovery, final redemption, exact all-EMPTY reset, and next-customer flow.

Hosted Linux runs all unit/widget/golden/security/archive gates. Hosted Android
runs M1, M2, and M3A integration entrypoints. macOS runs fatal analysis,
unit/widget tests, localized purpose-string checks, and development/staging/
production no-sign builds.

Physical camera, haptic feel, biometric behavior, app-switcher privacy,
release signing, and live staging API behavior cannot be replaced by widgets or
fixtures and remain explicit physical E2E gates.
