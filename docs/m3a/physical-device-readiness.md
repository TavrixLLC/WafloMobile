# Physical-device readiness

## Android

- Camera permission is declared; no photo-library permission is added.
- Biometric permission and `FlutterFragmentActivity` support local App Lock.
- Sensitive activity screenshot protection remains active.
- Development, staging, and production flavors build from separate entrypoints.
- Staging/production are HTTPS-only and have fixed hosts.
- Development debug, staging release, and production release APKs build locally.
- A physical camera, dim-light flash, biometric, background/app-switcher, and
  release-signing run still require real Android hardware.

## iOS

- English and Arabic camera purpose copy covers Staff pairing and customer
  Membership QR scanning.
- Face ID purpose copy is localized when biometric App Lock is enabled.
- No photo-library permission is requested.
- Development/staging/production schemes remain configured.
- macOS analysis/tests and three no-sign builds require hosted CI.
- Physical signing, camera, Face ID/Touch ID, background snapshot, and RTL checks
  require a real iPhone and project signing credentials.

No physical-device result is claimed by this Windows implementation run.
