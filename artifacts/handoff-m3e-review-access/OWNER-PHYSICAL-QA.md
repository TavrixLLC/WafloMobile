# Owner physical QA

- Worktree: `D:\install\business\WafloMobile\WafloMobile\.dart_tool\worktrees\m3e-review-access-scanner`
- Installable debug APK: `build\app\outputs\flutter-apk\app-staging-debug.apk`
- Install: `adb install -r build\app\outputs\flutter-apk\app-staging-debug.apk`
- Owner-controlled run:

```powershell
flutter run `
  --flavor staging `
  -t lib/main_staging.dart `
  --dart-define-from-file=config/staging.json
```

After Backend deployment/provisioning, choose Review / Demo Access, enter the code from secure release configuration, confirm Demo mode, inspect all seven Review Tools scenarios, scan the four environment-generated review QRs, test stamp/reward/approval presentation, Arabic, dark mode, App Lock, reset, Exit Demo, and the normal pairing screen afterward.

Release APKs are build outputs only; store signing was not verified. Use the staging debug APK for owner installation to avoid unsigned-release ambiguity.
