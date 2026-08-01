# Pairing recovery

The domain API exposes
`Future<PairingChallengeResult> challenge(String pairingPublicId)` and calls
`POST /v1/staff/devices/pairing/challenge` through the generated client.

The secure version-2 transaction record has five explicit states:
`claimPending`, `claimed`, `signing`, `completing`, and `persisting`. It stores
only the pairing public ID and the minimum challenge/signature recovery data.
The QR and one-time secret are never written.

- A lost claim response and an already-used claim immediately recover by public ID.
- Restart in `claimPending`, `claimed`, or `signing` re-fetches the challenge.
- The message must exactly equal version, pairing public ID, challenge, and local installation ID joined by LF.
- A persisted signing-state signature is reused for the same challenge.
- Expiry deletes transaction and identity and returns the expired pairing state.
- `completing` or `persisting` ambiguity fails closed for manager-assisted repair.
- Successful session persistence marks paired before deleting challenge/signature data.

The live W4 gate separately exercises claim, challenge, and complete and proves
that the claimed challenge is stable.
