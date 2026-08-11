# Pairing and session audit

The current implementation preserves the Production-v1 Staff authentication model:

- no Staff login, OAuth, magic link, customer authentication, or Merchant cookies;
- stable installation identity and Mobile-generated Ed25519 keypair;
- pairing QR claim, exact challenge signature, device/session binding, and atomic secure persistence;
- relaunch through signed `GET /v1/staff/device-context` without QR rescan;
- signed access session plus refresh token;
- no invented idle-expiry policy.

An expired access session is not refreshed. Proactive refresh is allowed only while the signed access session is still valid. Server authority-loss states fail closed and require the recovery path specified by the server state.

## BCK-004

Status: `BACKEND_OPEN_NON_BLOCKING`.

Mobile safe handling: `IMPLEMENTED`.

An HTTP 500 / `INTERNAL_ERROR` during pairing is treated as pairing failure, never success. The screen provides safe retry/admin guidance, transient claim state is cleared as appropriate, and key/challenge/signature material is neither displayed nor logged. Mobile does not weaken cryptographic validation to compensate for the Backend issue.
