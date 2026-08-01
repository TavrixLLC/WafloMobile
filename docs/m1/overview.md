# M1 overview

M1 is a standalone Flutter staff-device foundation for Android and iOS. It starts unpaired, accepts only the approved W4 staff pairing QR, creates an Ed25519 identity on the device, completes the server challenge, stores the resulting session securely, and loads authoritative device context. It includes English/Arabic, RTL, light/dark themes, accessibility, offline-safe display, blocked states, tests, CI, and handoff evidence.

Repository baseline: the workspace had no Git history, so it was initialized locally on branch `main` with origin `https://github.com/TavrixLLC/WafloMobile.git`. The supplied W4 archive was read as reference only; the repository contains only the transformed artifacts under `contracts/w4/`, never backend source or runtime data.

Out of scope: customer membership scanning, stamps, redemption, reversal, approvals, history, offline operation queues, NFC, Wallet/Smart Tap, customer login, and merchant password login.
