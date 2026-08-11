# M3A production readiness overview

M3A turns the approved M1/M2 implementation into a focused retail Staff tool.
The primary path is Pair device → Home → Scan customer → Resolve → Add stamps
or redeem → Success → Scan next customer.

The implementation is mobile-only and starts from
`c17a56b18ca356cfc77fc49517b9586f5e3992a4`. It does not alter the historical
M2 contracts, backend source, loyalty rules, Wallet issuance, or provider
delivery. Server state remains authoritative.

Product changes include a task-first Home, production scanner state machine,
optional local App Lock, background privacy cover, safe Device & Security
screen, Rapid Scan cleanup, haptic abstraction, semantic two-state stamp grid,
English/Arabic RTL, and a shared light/dark visual system.

The 26-screen executable review set is under
`artifacts/handoff-m3a/screenshots/`.
