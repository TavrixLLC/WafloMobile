# Production-v1 Mobile contract audit

Audit baseline: Mobile `f25f4af630d29c20ea0486088c64b7ac79849cf1`

Current Backend authority: `release/production-v1` at `763f2dfccdb24fb9bfa16457f0e49936840e20a1`

Canonical documentation: Backend documentation commit `06067d454077cdedf827f93ed0ced72d0e2e133d`

This audit is current Production-v1 integration guidance. It does not replace or rewrite the immutable historical M2 bundle (`3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`). Executable Backend source at the pinned authority takes precedence over prose.

## Inventory boundary

The Backend catalog contains 178 API routes: 9 `DIRECT_MOBILE_REQUIRED`, 4 `DIRECT_MOBILE_OPTIONAL`, 12 `MOBILE_SUPPORTING`, and 153 `NOT_FOR_MOBILE`. Staff Mobile may call the 13 direct routes only. The 12 supporting Merchant routes use browser session cookies/CSRF and are never Mobile API dependencies.

## Direct Mobile endpoints

| Route | Usage | Request / response | Auth and lifecycle | Errors / idempotency | Baseline status | M3C change |
|---|---|---|---|---|---|---|
| `POST /v1/staff/devices/pairing/claim` | Claim a Merchant-authorized pairing QR | Opaque pairing token, stable installation ID, Ed25519 public key, platform and strict app version → challenge, message, expiry and `signatureAlgorithm: Ed25519` | Unsigned; pairing rate limit; QR and key material are transient/redacted | Pairing invalid/expired/used, assignment and app-version failures; not idempotent | Implemented | Preserve; add safe `INTERNAL_ERROR` failure coverage for BCK-004 |
| `POST /v1/staff/devices/pairing/complete` | Prove possession of the Mobile private key | Pairing public ID, exact challenge, Ed25519 signature, optional display name → device, opaque access/refresh session and authoritative context | Unsigned challenge completion; atomic secure persistence required | Invalid/expired/used and assignment failures; never infer success | Implemented | Audit secure atomic persistence and failure cleanup |
| `POST /v1/staff/devices/session/refresh` | Rotate a still-valid Staff device session | Refresh token → rotated opaque access/refresh bundle | Signed Device request; current access session must still be valid and every current authority check passes | Expired access is not refreshable; authority errors require blocked/re-pair flow | Partially conforming | Stop attempting refresh after access expiry; preserve proactive refresh only while access is valid |
| `POST /v1/staff/devices/session/logout` | Revoke current local Device session | Empty body → 204 | Signed Device request; local secure bundle cleared only through deliberate logout policy | Safe replay is server-side session revocation; no Merchant auth | Implemented | Regression only |
| `GET /v1/staff/device-context` | Relaunch/readiness authority | No body → organization role, Location, device/session identity, platform, app/minimum versions, support flag and request ID | Signed Device request on every relaunch/resume; current user, membership, device and Location authority enforced | 401 lifecycle codes; 426 `STAFF_APP_VERSION_UNSUPPORTED`; not a mutation | Implemented | Add distinct lifecycle dispositions and block navigation immediately |
| `POST /v1/staff/memberships/resolve` | Resolve opaque customer Membership QR | `qrPayload` → safe customer/program/progress/policy/eligibility/reward/visual digest projection | Signed Device request; current Location comes from paired session | Billing, credential, Membership, program, Location, lifecycle and update errors; read-only | Implemented | Treat billing denial as authoritative without changing cached customer projection |
| `POST /v1/staff/operations/stamps` | Add stamps online | QR, integer stamp amount, conditional minor-unit purchase data, optional Merchant reference and observed time → authoritative stamp result | Signed Device request; exact transmitted body digest; online only | Durable UUID idempotency; ambiguous response uses command lookup. Production Mobile must omit `managerOverride` | Partially conforming | Prove wire serialization cannot emit `managerOverride`; current error code is `PURCHASE_THRESHOLD_NOT_MET`; add billing denial coverage |
| `POST /v1/staff/operations/redeem` | Redeem an entitlement online | QR, entitlement public ID, optional note, and only on approval retry `managerApprovalPublicId` → authoritative redemption result | Signed Device request; Manager decision occurs on Merchant Web, never in Mobile | Same durable command UUID and exact semantic payload across approval retry; approval ID added only after server issuance; timeout uses command recovery | Missing Production-v1 flow | Add explicit approval state machine, protected pending intent, same-key/fresh-envelope retry and polished Staff UX |
| `GET /v1/staff/operations/commands/:commandId` | Resolve an ambiguous mutation | Durable command UUID → `PROCESSING`, `COMPLETED` typed result, or `FAILED` safe code | Signed Device request; device/tenant-safe not-found behavior | Never creates a new mutation; same command stays pending until authoritative terminal result | Implemented | Integrate approved redeem retry ambiguity without changing existing semantics |
| `POST /v1/staff/devices/pairing/challenge` | Optional recovery of a still-valid claimed challenge | Pairing public ID → challenge/message/expiry | Unsigned and rate-limited | Pairing expired/invalid; never exposes server secrets | Generated client exists; normal flow does not depend on it | No product change unless pairing recovery invokes it |
| `POST /v1/staff/operations/reverse` | Optional Staff reversal when enabled by policy | Operation public ID and optional reason → authoritative reversal result | Signed Device request; current paired Location/device authority | Durable UUID idempotency and online-only; billing applies | Generated historical client only; no M3B Staff product flow | Defer: Production-v1 does not require a new reversal UI in M3C |
| `GET /v1/staff/operations/:operationPublicId` | Optional public operation-status lookup | Operation public ID → safe operation status/result | Signed Device request | Read-only and tenant/device safe | Generated historical client only; command recovery uses the required command route | Keep deferred; no reason to replace command recovery |
| `GET /health` | Optional deployment health signal | No request body → deployment health | Unsigned; never authorizes Staff operations | No mutation/idempotency | Environment diagnostics do not use it for loyalty authority | Keep optional; staging readiness may use external deployment evidence |

## Contract deltas requiring Mobile work

- **MOB-001:** Runtime Staff stamp serialization already omits `managerOverride`, but historical generated models still contain the old optional shape. The historical bundle remains untouched. M3C adds a wire-level prohibition test and removes current-authority UI/domain references.
- **MOB-002:** Current authority is `PURCHASE_THRESHOLD_NOT_MET`. `PURCHASE_AMOUNT_BELOW_MINIMUM` must not appear as a current runtime mapping.
- **MOB-003:** `OPERATION_BILLING_BLOCKED` is authoritative for resolve, stamp, redeem and reverse. Mobile must not change cached progress/reward state or queue work after denial.
- **MOB-004:** The current M3B controller locally blocks approval-required rewards. Production-v1 instead requires an initial signed redeem, secure retention of its exact semantic intent, server-issued approval public ID, same-command retry after a Merchant Web decision, and fresh transport signing for every transmission.

## Executable-source findings

- `StaffOperationsController` exposes only Device-signed Staff routes and parses strict request schemas.
- The Backend issue-stamp schema still accepts the historical optional `managerOverride`, but runtime explicitly refuses to treat a redeem approval as stamp authorization. Production Mobile must omit the field entirely; no Backend contract rewrite is made here.
- The Backend redeem fingerprint excludes `managerApprovalPublicId` and binds command, organization, customer, Membership, credential digest, program/version, entitlement/reward policy, Staff member, originating device, paired Location and note. Mobile never calculates this fingerprint.
- First approval-required redeem returns HTTP 409 with safe details containing `approvalRequest.publicId`, `status`, `expiresAt`, `operationType: REDEEM`, and `retryWithSameIdempotencyKey: true`.
- A successful approved retry must use the original device, command UUID and semantic payload, while each signed HTTP transmission receives a fresh request ID, timestamp, nonce and signature.
- `StaffDeviceSignatureGuard` and refresh runtime return distinct authority-loss codes: `STAFF_USER_DEACTIVATED`, `STAFF_MEMBERSHIP_INACTIVE`, `STAFF_DEVICE_REVOKED`, and `STAFF_LOCATION_ASSIGNMENT_INVALID`.
- The session service rejects refresh after expiry. The documented default session lifetime is 30 days and there is no Staff idle-expiry policy.
- Resolve exposes stamp visual state plus content digest only. It exposes no renderable asset URL or payload.

## Explicitly forbidden Mobile dependencies

The Mobile source contains no runtime call to the Merchant-cookie Location-assignment or operation-approval routes. It must continue to avoid all `/v1/organizations/:organizationId/...` staff-assignment and approval decision endpoints. Mobile does not approve, reject, list, fingerprint, self-assign, switch Location, or authenticate as a Merchant browser.

## Security and product invariants

- No Staff login is introduced. Authentication remains pairing + Mobile Ed25519 identity + opaque Device session + signed envelopes.
- No offline loyalty mutation or client-side loyalty authority is introduced.
- No optimistic stamp/redeem UI is introduced; only confirmed results/status recovery/fresh resolve update the customer projection.
- The main grid remains exactly `FILLED` and `EMPTY`. Reward readiness and approval state remain outside the grid.
- Approval public ID and the retained QR payload are protected local operation material: never shown, copied, logged, placed in route parameters, or stored in plain preferences.

## Authority gap

`MERCHANT_ARTWORK_RENDERING_EXTERNAL_DEPENDENCY`: Production-v1 resolve supplies `filled/empty.state` and optional SHA-256 `contentDigest`, but no renderable bytes or asset URL. Mobile preserves its contract-valid FILLED/EMPTY fallback. Owner: Backend/Web contract; no endpoint is invented.
