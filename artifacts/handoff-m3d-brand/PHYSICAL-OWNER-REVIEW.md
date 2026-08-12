# Physical owner review

## Staging APK

Exact output path:

`D:\install\business\WafloMobile\WafloMobile\.dart_tool\worktrees\m3d-official-brand\build\app\outputs\flutter-apk\app-staging-release.apk`

This APK was built with:

- target `lib/main_staging.dart`
- flavor `staging`
- `config/staging.json`
- fixed API origin `https://api-staging.waflo.app`

Clean-build SHA-256:

`c6a3efa86823c321aaa2b9f01c81ccae52f96f4a7b56e33342c1905a802385b6`

The APK archive was inspected after a clean build. It contains the official `NotoSansArabic-Variable.ttf` asset and does not contain the retired `NotoSansArabic-Regular.ttf` asset.

## Owner-controlled Flutter run

From PowerShell 7:

```powershell
Set-Location -LiteralPath 'D:\install\business\WafloMobile\WafloMobile\.dart_tool\worktrees\m3d-official-brand'
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json
```

The `--dart-define-from-file` argument is required. Do not run staging without it.

## Remaining manual actions

1. Connect and unlock the Android phone with USB debugging authorized.
2. Confirm it appears in `flutter devices`.
3. Run the exact command above, or install the generated staging APK using the owner’s normal approved Android installation method.
4. Visually inspect native splash, startup, invalid-config fail-safe (separate test build only), pairing, Home, scanner, customer, App Lock, Arabic, and dark mode.

No phone or AVD was connected during local M3D validation, so physical launch is not claimed.
