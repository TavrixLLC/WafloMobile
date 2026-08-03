# M1 regression

M2 starts from approved M1 repair commit `921d5c3` and preserves flavor binding, boot state machine, Ed25519 identity, secure storage, pairing recovery, canonical request signing, single-flight refresh, device context, blocked-device behavior, EN/AR/RTL, privacy cover, native security, and M1 CI/tests.

The only M1 shell behavior changed is activation of the previously disabled “Scan customer” action and lifecycle notification to clear M2 transient state. Recent operations and Manager approvals remain unavailable in M2.
