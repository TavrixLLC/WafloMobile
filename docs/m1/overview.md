# M1 overview

M1 is a standalone Flutter staff-device foundation for Android and iOS. It starts unpaired, accepts only the approved W4 staff pairing QR, creates an Ed25519 identity on the device, completes the server challenge, stores the resulting session securely, and loads authoritative device context. It includes English/Arabic, RTL, light/dark themes, accessibility, offline-safe display, blocked states, tests, CI, and handoff evidence.

The repository contains only the approved machine-readable W4 bundle under
`contracts/w4/`, never backend runtime source or data. Round 1 repairs live on
`feature/m1-repair-round-1`.

Out of scope: customer membership scanning, stamps, redemption, reversal, approvals, history, offline operation queues, NFC, Wallet/Smart Tap, customer login, and merchant password login.
