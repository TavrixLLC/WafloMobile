# Physical device status

Target device:

- Model: M2101K7BG.
- Android: 13 / API 33.
- ADB serial: `CQSWH6KB5LZP8HUW`.

The correctly configured staging DEBUG APK was built with
`--dart-define-from-file=config/staging.json`.

Current status: **not installed in this M3G run**. ADB sees the device but
reports `unauthorized`. The owner must unlock the phone and approve the USB
debugging prompt. Device security was not bypassed.

After authorization, the intended review sequence is:

1. Install the staging DEBUG APK normally.
2. Run the applicable Android integration matrix.
3. Open the normal scanner.
4. Choose Enter code manually.
5. Use the existing untracked M3F review/local-demo mechanism appropriate to
   that build.
6. Complete subjective owner review separately.

An install restriction or keyguard/MIUI approval prompt is not automatically
an application defect.
