# Android and iOS readiness

Android local builds:

- development debug: PASS
- staging release: PASS
- production release: PASS

Camera and biometric permissions are declared, `FlutterFragmentActivity` is
used for biometric integration, and sensitive-screen screenshot protection is
preserved. Flutter 3.44.3 reports forward-looking Gradle 8.13/Kotlin 2.2.0
deprecation warnings; these did not fail current builds.

iOS camera and Face ID purpose strings are localized in English and Arabic.
There is no photo-library permission. Windows cannot execute iOS builds;
macOS fatal analysis/tests and three no-sign builds are a hosted-CI requirement.
Physical signing remains credential-owned and was not attempted.
