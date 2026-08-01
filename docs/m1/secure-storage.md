# Secure storage

Sensitive values use `flutter_secure_storage` behind a small interface.

- Android: encrypted storage with algorithm migration, no backup-assisted migration, a versioned namespace, `allowBackup=false`, and cloud/device-transfer exclusions. Minimum API is 23.
- iOS: Keychain accessibility `unlocked_this_device`, not synchronizable, versioned account name. Minimum iOS is 13.

Ordinary preferences contain only locale, theme, and a display-only safe context (role, platform, device display name, synchronization time). All keys are versioned. Unsupported/corrupt sensitive records fail closed; migrations must be explicit and transactional.
