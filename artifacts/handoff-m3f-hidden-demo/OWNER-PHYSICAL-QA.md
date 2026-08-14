# Owner physical QA

Worktree:

`D:\install\business\WafloMobile\WafloMobile\.dart_tool\worktrees\m3f-hidden-demo-scanner-design-pack`

Build the owner-only staging debug APK from PowerShell 7:

```powershell
flutter build apk --debug `
  --flavor staging `
  -t lib/main_staging.dart `
  --dart-define-from-file=config/staging.json `
  --dart-define=WAFLO_LOCAL_DEMO_CODE=<OWNER_LOCAL_DEMO_CODE>
```

Expected APK:

`build\app\outputs\flutter-apk\app-staging-debug.apk`

Install:

```powershell
adb install -r build\app\outputs\flutter-apk\app-staging-debug.apk
```

Run directly:

```powershell
flutter run `
  --flavor staging `
  -t lib/main_staging.dart `
  --dart-define-from-file=config/staging.json `
  --dart-define=WAFLO_LOCAL_DEMO_CODE=<OWNER_LOCAL_DEMO_CODE>
```

The owner-code-bearing debug artifact is OWNER-QA ONLY and must not be distributed through Store channels.

QA flow: confirm no public Demo control; open scanner; select Enter code instead; enter owner code; verify Demo indicator only afterward; exercise Home, scanner beam, valid/invalid/expired/offline simulation, 0/8, 5/8, 8/8, stamp, approval states, final reset, App Lock, Arabic, dark, large text, Settings, and Exit Demo.
