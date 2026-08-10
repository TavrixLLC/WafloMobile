# Real W4 runtime compatibility matrix

Status: pre-repair failure matrix complete. No compatibility repair described
below had been applied when this matrix was recorded.

Baseline:

- Mobile verification SHA: `03e5a6fc9e3039d8ad18b9b271ea1e18e64bd7f7`
- Backend pairing-repair SHA: `dbd20acafc3d7687866256e8e950a5b978ba4e29`
- Historical M2 bundle SHA-256:
  `3e2c57f136bcfc4a270b51fd85ffd0e8e96832c8e12ba85dedecb17457d645ae`
- Flutter execution: 26 executed, 10 passed, 16 failed
- Backend execution: 16 executed, 16 passed
- Sanitized response capture:
  `raw-test-output/runtime-compatibility-wire-audit.txt`

The capture records actual HTTP method, path, status, and serialized response.
QR values, tokens, signatures, challenges, nonces, public keys, display names,
request IDs, and machine-local paths are redacted. A diagnostic request capture
that serialized synthetic fixture QR values was deleted immediately and is not a
handoff artifact.

## Contract and implementation boundaries

- Declared M1 contract: `contracts/w4/openapi.m1.json`,
  `contracts/w4/schemas/m1.schema.json`, and
  `contracts/w4/stable-error-codes.json`.
- Declared M2 contract: `contracts/w4/m2/openapi.m2.json`,
  `contracts/w4/m2/m2.schema.json`, fixtures in `contracts/w4/m2/`, and
  `contracts/w4/m2/stable-error-codes.m2.json`.
- Generated Mobile models: `lib/core/api/generated/` and
  `lib/core/api/generated_m2/`.
- Mobile runtime consumers:
  `lib/features/device_session/data/signed_device_api.dart`,
  `lib/features/membership_resolution/data/loyalty_operations_api.dart`, and
  `lib/features/pairing/data/generated_pairing_api.dart`.
- Backend runtime sources:
  `apps/api/src/security/guards.ts`,
  `apps/api/src/common/request-context.ts`,
  `apps/api/src/staff-devices/staff-device.controller.ts`,
  `apps/api/src/loyalty/staff-operations.controller.ts`,
  `apps/api/src/loyalty/loyalty-operation.service.ts`,
  `packages/contracts/src/w4.ts`, and
  `packages/staff-device-security/src/index.ts`.

## Failure matrix

| # | Failing scenario | Endpoint | Expected / actual status | Expected contract fields | Actual serialized wire payload | First exact mismatch | Downstream effect | Sources | Classification |
|---:|---|---|---|---|---|---|---|---|---|
| 04 | Device-context returns authoritative safe context | `GET /v1/staff/device-context` | `200 / 200` | M2 `StaffDeviceContextResult`: `organizationId`, `role`, `locationId`, `devicePublicId`, `deviceSessionId`, `platform`, `appVersion`, `minimumSupportedAppVersion`, `appVersionSupported=true`, `requestId`; outer `requestId` | `data` contains all declared fields and valid values; outer envelope also contains `requestId` | `data.requestId != envelope.requestId`. The inner value is the signed `x-waflo-request-id`; the envelope uses Fastify's independent `x-request-id`. | Mobile rejects an otherwise valid context as `DEVICE_CONTEXT_MISMATCH`; later tests do not reuse this call. | M2 schema `StaffDeviceContextResult`; Mobile `SignedDeviceApi.parseM2ContextResponse`; Backend `StaffDeviceSignedGuard`, `StaffDevicePairingController.context`, `EnvelopeInterceptor`, and Fastify `requestIdHeader` | `BACKEND_RUNTIME_VALUE_MISMATCH` |
| 07 | Revoked is a real backend state and clears session | `GET /v1/staff/device-context` | `401 / 401` | Error envelope with `code=STAFF_DEVICE_REVOKED`, safe message, request ID | `{"error":{"code":"STAFF_DEVICE_NOT_ACTIVE","message":"Staff device request could not be verified.","requestId":"[REDACTED]"}}` | Runtime collapses device status `REVOKED` to `STAFF_DEVICE_NOT_ACTIVE`. | The expected distinct failure assertion stops the scenario before the local-session cleanup assertion. | M1 stable error catalog; Mobile `SessionManager`/Real W4 test; Backend `assertDeviceOperational` and `StaffDeviceSignedGuard` | `BACKEND_ERROR_MAPPING_MISMATCH` |
| 08 | Compromised is distinct and clears session | `GET /v1/staff/device-context` | `401 / 401` | Error envelope with `code=STAFF_DEVICE_COMPROMISED`, safe message, request ID | `{"error":{"code":"STAFF_DEVICE_NOT_ACTIVE","message":"Staff device request could not be verified.","requestId":"[REDACTED]"}}` | Runtime collapses device status `COMPROMISED` to `STAFF_DEVICE_NOT_ACTIVE`. | The expected distinct failure assertion stops the scenario before the local-session cleanup assertion. | M1 stable error catalog; Mobile `SessionManager`/Real W4 test; Backend `assertDeviceOperational` and `StaffDeviceSignedGuard` | `BACKEND_ERROR_MAPPING_MISMATCH` |
| 09 | Expired session is distinct and clears credentials | `GET /v1/staff/device-context` | `401 / 401` | Error envelope with `code=STAFF_DEVICE_SESSION_EXPIRED`, safe message, request ID | `{"error":{"code":"STAFF_DEVICE_NOT_ACTIVE","message":"Staff device request could not be verified.","requestId":"[REDACTED]"}}` | Runtime collapses `sessionExpiresAt <= now` to `STAFF_DEVICE_NOT_ACTIVE`. | The expected distinct failure assertion stops the scenario before the local-session cleanup assertion. | M1 stable error catalog; Mobile `SessionManager`/Real W4 test; Backend `assertDeviceOperational` and `StaffDeviceSignedGuard` | `BACKEND_ERROR_MAPPING_MISMATCH` |
| 12 | Real M2 purchase membership resolves through Flutter | `POST /v1/staff/memberships/resolve` | `200 / 422` | Request: `qrPayload` only. Response: every required `MembershipResolveResult` field, including membership identity/status, customer/program labels, response `locale`, progress/goal/reward state, cycle/projection data, eligibility/limits, operational date/timezone, purchase requirement, two-state visuals, and rewards. | `{"error":{"code":"VALIDATION_FAILED","message":"Please check the submitted information.","details":{"fields":[{"path":"","message":"Unrecognized key: \"locale\""}]},"requestId":"[REDACTED]"}}` | The signed Mobile adapter adds request field `locale`; the authoritative request schema and generated `MembershipResolveRequest` forbid it. | Membership response parsing and all purchase-membership operation setup do not run. | M2 `MembershipResolveRequest`; generated Mobile request model; Mobile `SignedLoyaltyOperationsApi.resolveMembership`; Backend strict `membershipResolveSchema` and controller | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 13 | Lowercase purchase currency is normalized and accepted | `POST /v1/staff/operations/stamps` | `200 / 422` | Request: `qrPayload`, `amount`, optional purchase/reference/manager/time fields; `purchaseCurrency` is canonical `IQD`. Response: required `StampOperationResult` fields (`operationPublicId`, `commandId`, replay flag, before/new progress, goal, reward/cycle/projection state, unlocked rewards, request ID). | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Mobile correctly normalizes `iqd` to `IQD` but then adds forbidden request field `locale`; strict validation fails first. | No stamp, ledger entry, completed command, or `purchaseStamp` value exists. | M2 `StampRequest`; generated Mobile model; Mobile `SignedLoyaltyOperationsApi.issueStamps`; Backend strict `issueStampSchema` and controller | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 14 | Compatible stamp replay returns committed result | `POST /v1/staff/operations/stamps` | `200 / 422` | Same valid `StampRequest`; response is the committed `StampOperationResult` with `replayed=true` and matching operation/command IDs | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Forbidden `locale` fails before idempotency lookup. | Replay behavior is not exercised; additionally #13 created no committed command. | Same sources as #13 | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 15 | Conflicting stamp replay is rejected authoritatively | `POST /v1/staff/operations/stamps` | `409 / 422` | Error envelope with `code=OPERATION_IDEMPOTENCY_CONFLICT` and safe request ID | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Forbidden `locale` fails before fingerprint/idempotency conflict evaluation. | Conflict semantics are not exercised; #13 also created no command. | M2 `StampRequest` and stable errors; Mobile signed adapter; Backend strict schema and idempotency service | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 16 | Wrong purchase currency is a safe backend rejection | `POST /v1/staff/operations/stamps` | `422 / 422` | Error envelope with `code=PURCHASE_CURRENCY_MISMATCH` | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Forbidden `locale` fails before authoritative purchase-currency policy. | Currency-policy rejection is not exercised. | M2 `StampRequest` and stable errors; Mobile signed adapter; Backend strict schema and policy service | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 17 | COMPLETED command returns typed stamp result | `GET /v1/staff/operations/commands/{commandId}` | `200 / 404` | `OperationCommandStatusResult`: command/operation IDs, `operationType=ISSUE_STAMP`, `status=COMPLETED`, typed stamp `result`, null failure, created/completed timestamps | `{"error":{"code":"OPERATION_NOT_FOUND","message":"Operation not found.","requestId":"[REDACTED]"}}` | The lookup is valid, but #13 never created the command because its request was rejected for forbidden `locale`. | Typed result compatibility is not reached. PROCESSING and FAILED fixture commands pass independently in #18/#19. | M2 command-status schema and completed fixture; Mobile `CommandRecoveryResult`; Backend `commandStatus`; Real W4 scenario dependency on #13 | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 21 | Real M2 resolve accepts Arabic without changing authority | `POST /v1/staff/memberships/resolve` | `200 / 422` | Request remains `qrPayload` only; response contains authoritative response `locale` and full `MembershipResolveResult` | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | UI locale was incorrectly promoted to an undeclared request field. | Arabic-facing consumer validation does not receive an authoritative response. | Same sources as #12 | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 22 | Milestone reward is unlocked outside the stamp grid | First call: `POST /v1/staff/memberships/resolve` | `200 / 422` | Full membership result, followed by a valid stamp result at progress `4/8`, `rewardReady=false`, with one non-final unlocked reward outside the grid | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | The initial resolve contains forbidden `locale`. | The stamp request is never sent; milestone reward and two-state grid semantics are not exercised. | M2 resolve/stamp schemas and fixtures; Mobile signed adapter; Backend strict schemas and loyalty service | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 23 | Final reward reaches ready with all stamps filled | `POST /v1/staff/operations/stamps` | `200 / 422` | Stamp result at `8/8`, `rewardReady=true`, all main-grid states filled, one final unlocked reward outside the grid | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Stamp request contains forbidden `locale`. | `finalReadyStamp` is never initialized. | M2 stamp/final-ready fixtures and schema; Mobile signed adapter; Backend strict stamp schema and service | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 24 | Extra stamp is blocked while final reward is pending | `POST /v1/staff/operations/stamps` | `409 / 422` | Error envelope with `code=FINAL_REWARD_PENDING_REDEMPTION` | Same `VALIDATION_FAILED` envelope as #12 with `Unrecognized key: "locale"`. | Forbidden `locale` fails before reward-ready policy evaluation. | Pending-final-reward protection is not exercised; #23 also failed to create final-ready state. | M2 stamp schema/stable errors; Mobile signed adapter; Backend strict schema and loyalty policy | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 25 | Final redemption returns authoritative zero projection | `POST /v1/staff/operations/redeem` | `200 / no HTTP request` | `RedemptionOperationResult`: operation/command/redemption IDs, replay/reward status, `finalReward=true`, before/new progress, goal, `rewardReady=false`, `completedCycles=1`, projection version, request ID | No wire payload. Test fails locally with `LateInitializationError` before request construction. | `finalReadyStamp` was not initialized because #23 was rejected for forbidden `locale`. | Final redemption, append-only history, and immediate `0/goal` reset are not exercised. | M2 redeem/result schemas and final-reset fixture; Mobile redemption consumer; Real W4 dependency on #23 | `MOBILE_GENERATED_CLIENT_DEFECT` |
| 26 | Unsupported iOS semantic version returns HTTP 426 | `POST /v1/staff/devices/pairing/claim` | `426 / 422` | Claim request requires token, installation ID, key, platform, strict app version; optional `osVersion` and `model` must be absent when unknown. Error envelope: `code=STAFF_APP_VERSION_UNSUPPORTED`. | `{"error":{"code":"VALIDATION_FAILED","message":"Please check the submitted information.","details":{"fields":[{"path":"osVersion","message":"Invalid input: expected string, received null"},{"path":"model","message":"Invalid input: expected string, received null"}]},"requestId":"[REDACTED]"}}` | Generated JSON includes optional non-null fields as explicit JSON `null` instead of omitting them. | Pairing schema rejects the request before the authoritative semantic-version check can return 426. | M1 claim schema/OpenAPI; generated `DevicePairingClaimRequest` serializer; `tool/generate_w4_client.dart`; Backend strict `devicePairingClaimSchema` and `StaffDeviceService.claim` | `CONTRACT_GENERATOR_DEFECT` |

## Shared root-cause clusters

1. Device-context correlation drift affects #04 only. Backend request context
   preserves the signed request ID inside `data` but wraps the response with a
   different Fastify request ID.
2. Device lifecycle error collapse affects #07-#09. One security helper maps
   revoked, compromised, member-inactive, revoked-session, and expired-session
   conditions to one generic code even though the M1 catalog declares distinct
   safe states.
3. Out-of-contract Mobile `locale` emission directly affects #12-#16,
   #21-#24 and causes the dependent failures in #17 and #25. The declared M2
   request schemas and their generated Mobile models do not contain `locale`;
   `locale` is an authoritative response field only.
4. Optional-field null emission affects #26. The declared M1 fields are
   optional but non-null; the generated serializer emits them as null.

The four clusters are independent. No contract schema/version or historical
bundle change is indicated by the evidence.

## Post-repair cascade matrix (recorded before further repair)

After the four pre-repair clusters were corrected, the exact gate executed all
26 Flutter scenarios: 24 passed and two failed. Teardown also failed. These
three outcomes were audited before any additional repair.

| Scenario | Endpoint | Expected / actual status | Expected contract fields | Actual serialized wire payload | First exact mismatch | Downstream effect | Sources | Classification |
|---|---|---|---|---|---|---|---|---|
| 14 compatible stamp replay | `POST /v1/staff/operations/stamps` | `200 / 200` | Outer success envelope has its current transport `requestId`; nested `StampOperationResult.requestId` is a nullable bounded string and has no declared equality constraint | Valid replay result with `replayed=true`; nested `requestId` is the original committed mutation request ID, while outer `requestId` is the newly signed replay request ID | Hand-maintained Mobile domain validation requires the two independent IDs to be equal, although the schema does not | Mobile throws `M2ContractViolation(REQUEST_ID_MISMATCH)` after accepting the wire shape | M2 `StampOperationResult`; `stamp-success.fixture.json`; signed-retry handoff; Mobile `StampOperationResult.fromJson`; Backend idempotent replay/result payload | `MOBILE_GENERATED_CLIENT_DEFECT` (the allowed taxonomy's closest Mobile-consumer category) |
| 17 COMPLETED command recovery | `GET /v1/staff/operations/commands/{commandId}` | `200 / 200` | Outer envelope has the lookup request ID; nested typed result retains its declared nullable operation request ID | Valid `COMPLETED` status and typed stamp result; nested `requestId` is the original mutation request ID, while outer `requestId` is the current lookup request ID | The same undeclared Mobile equality assertion is applied to the nested result | Mobile rejects an otherwise valid authoritative completed result; PROCESSING and FAILED remain valid | M2 `OperationCommandStatusResult` and `operation-completed.fixture.json`; Mobile `CommandRecoveryResult`/`StampOperationResult`; Backend `commandStatus`/stored result | `MOBILE_GENERATED_CLIENT_DEFECT` (the allowed taxonomy's closest Mobile-consumer category) |
| Gate teardown | `POST /fixture/cleanup` (verification control endpoint, not product API) | `200 / 500` | Verification fixture must clean its ephemeral data without weakening the append-only ledger | `{"error":"fixture_control_failed"}`; fixture stderr reports database guard `WAFLO_LEDGER_APPEND_ONLY` | Mobile verification fixture calls `loyaltyLedgerEntry.deleteMany()` in the dedicated database even though the migration intentionally forbids ledger deletion | Test process reports teardown failure and leaves fixture rows in the dedicated base database | Mobile `tool/w4_contract_fixture.mjs`; backend append-only migration; Mobile Real W4 wrapper | `MOBILE_VERIFICATION_TOOL_DEFECT` |

The nested operation request ID is stable committed-result metadata. The outer
envelope request ID identifies the current signed HTTP exchange. The signed
request handoff explicitly requires a new request ID for each network retry, so
equality is not an authoritative contract invariant. The teardown defect is
independent and must be repaired by using a disposable database, not by
disabling or bypassing the append-only guard.

## Final compatibility table

| Failing scenario(s) | Root cause | Classification | Authoritative expected behavior | Old runtime behavior | Repaired behavior | Source files changed | Regression | Commit |
|---|---|---|---|---|---|---|---|---|
| Pairing challenge and downstream #02-#26 | Challenge service omitted a required field | `BACKEND_RUNTIME_OMISSION` | HTTP challenge data includes canonical `signatureAlgorithm: Ed25519` | HTTP 200 omitted the field | Wire includes `Ed25519`; signed pairing completes | Backend `staff-device.service.ts`, HTTP test | Signed Staff HTTP 6/6 and Flutter #01-#03 | `dbd20acafc3d7687866256e8e950a5b978ba4e29` |
| #04 device context | Two backend request-ID sources diverged | `BACKEND_RUNTIME_VALUE_MISMATCH` | Context data and envelope correlate to the signed request | Inner signed ID differed from Fastify envelope ID | Signed request ID is retained in backend request context and envelope | Backend `guards.ts`, HTTP test | Real HTTP context assertion; Flutter #04 | `79a5ff7b224fbd0a1cf76a4d5eeb4e697b023435` |
| #07-#09 lifecycle errors | Security helper collapsed distinct safe states | `BACKEND_ERROR_MAPPING_MISMATCH` | Revoked, compromised, and expired return their declared stable codes | All returned `STAFF_DEVICE_NOT_ACTIVE` | Each state returns its declared safe code without internal leakage | Backend staff-device security package, guard, HTTP test | Real revoked/compromised/expired HTTP routes; Flutter #07-#09 | `966454633519bff3d9aed277ce0bcf36f17d3d60` |
| #12-#17, #21-#25 | Hand-maintained Mobile adapter emitted undeclared `locale` | `MOBILE_GENERATED_CLIENT_DEFECT` | Strict M2 request bodies contain only declared request fields; locale stays response-authoritative | Backend rejected each request at schema validation | Resolve/stamp/redeem omit locale; currency still normalizes to uppercase | Mobile `loyalty_operations_api.dart`, request-body test | Focused API test plus Flutter #12-#25 | `e5479264a95bb73bb1e731d1c99feb36e696d969` |
| #26 HTTP 426 | Generator emitted absent optional non-null fields as JSON null | `CONTRACT_GENERATOR_DEFECT` | Unknown optional pairing metadata is omitted | Claim returned 422 before semantic-version policy | Serializer omits `osVersion`/`model`; backend returns 426 `STAFF_APP_VERSION_UNSUPPORTED` | Mobile generator, generated claim model/serializer, generator regression | Generator drift and focused unit; Flutter #26 | `e0e095576305c06e46371249e4c01c07d99f9048` |
| #14 replay and #17 completed recovery | Mobile imposed an equality invariant absent from the result schema | `MOBILE_GENERATED_CLIENT_DEFECT` (closest allowed Mobile-consumer category) | Committed operation request ID may differ from a new replay/lookup envelope ID | Mobile rejected valid 200 responses with `REQUEST_ID_MISMATCH` | Both IDs remain validated; current response ID is retained without false rejection | Mobile stamp/redemption domain parsers and domain test | Focused replay/recovery/redemption test; Flutter #14/#17 | `0baa56f12130b15f56f5548646fc3f52a606a4fa` |
| Teardown | Verification fixture tried to delete append-only ledger history in the base DB | `MOBILE_VERIFICATION_TOOL_DEFECT` | Real gate uses disposable local DB and leaves ledger guard intact | Cleanup returned 500 `WAFLO_LEDGER_APPEND_ONLY` | Gate creates/migrates/seeds/uses/force-drops one scoped `waflo_test_*` database | Mobile Real W4 runner, fixture, isolated DB helper | Flutter teardown passes; zero temporary DBs | `6902c23c98304db162be99b4dc53f21c8236a419` |

Final exact execution: Flutter 26/26, backend 16/16, total 42/42. The
historical contract schema, contract version, and bundle bytes did not change.
