# Physical-device preflight

## Android manual actions

1. Install the staging release on a supported physical Android phone.
2. Grant camera permission only when the scanner requests it.
3. Scan a sanitized staging Membership QR in bright and dim conditions; toggle flash.
4. Background/resume during scanning and a pending transaction; confirm camera release and privacy cover.
5. Enable biometric App Lock and verify lock intervals, failed attempts, and screenshot protection.
6. Repeat the final-reward reset and Scan next customer flow one-handed.
7. Sign the production artifact with the approved release key outside this repository.

## iOS manual actions

1. Configure the approved Apple signing team/profile without committing credentials.
2. Install development and staging builds on a physical iPhone.
3. Verify localized camera and Face ID purpose dialogs in English and Arabic.
4. Exercise camera/flash, background snapshot cover, Face ID/Touch ID, RTL, and 200% text.
5. Run the same final-reward reset and next-customer flow.

These are the only hardware/signing actions; no Mobile feature development is
required before physical staging E2E.
