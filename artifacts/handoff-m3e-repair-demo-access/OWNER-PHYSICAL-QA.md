# Owner physical QA

## Candidate

- Worktree: `<MOBILE_REPOSITORY>/.dart_tool/worktrees/m3e-repair-unified-demo-access`
- APK: `build/app/outputs/flutter-apk/app-staging-debug.apk`
- Package: `app.waflo.staff.staging`

Install from PowerShell 7 while the worktree is current:

```powershell
adb install -r build\app\outputs\flutter-apk\app-staging-debug.apk
```

Run through Flutter with the required build-time configuration:

```powershell
flutter run `
  --flavor staging `
  -t lib/main_staging.dart `
  --dart-define-from-file=config/staging.json
```

## QA path

1. Unlock the phone with its owner-controlled OS credential.
2. Open Waflo Staff Staging.
3. From Pairing, select **Demo Access**, then continue into sample data.
4. Confirm the persistent restrained **Sample data** indicator.
5. Home → Scan Customer → open **Demo controls** below the camera target.
6. Simulate valid QR; confirm distinct “Code detected” and customer-loading states.
7. Confirm Customer 5/8, add one stamp, confirm, and verify success at 6/8.
8. Choose Scan Next Customer.
9. Open Demo scenarios → Customer 8/8 Reward Ready → Redeem.
10. Walk Required → Pending → Simulate approved → success → 0/8 reset.
11. Inspect invalid, expired, network, permission, threshold, billing, session, and revoked states.
12. Switch Arabic, dark mode, and large system text; inspect Scanner, Customer, Approval, App Lock, Device & Security, and Settings.
13. For the local App Lock fixture only, use PIN `2468`.
14. Select **Exit Demo** and confirm Pairing returns with no Backend call.

## Recorded physical result

The final staging debug APK installed successfully on the connected `M2101K7BG` (Android 13). Automated interaction could not proceed because Android required the owner's periodic OS PIN and remained on the lock screen. No attempt was made to bypass or disclose that credential.
