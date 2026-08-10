import { createServer } from "node:http";
import { randomUUID, timingSafeEqual } from "node:crypto";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const backendRoot = process.env.WAFLO_W4_BACKEND_ROOT;
if (backendRoot) process.loadEnvFile(resolve(backendRoot, ".env"));
const controlSecret = process.env.WAFLO_CONTRACT_CONTROL_SECRET;
const apiPort = Number.parseInt(process.env.WAFLO_CONTRACT_API_PORT ?? "", 10);
const controlPort = Number.parseInt(process.env.WAFLO_CONTRACT_CONTROL_PORT ?? "", 10);

if (!backendRoot || !controlSecret || !Number.isInteger(apiPort) || !Number.isInteger(controlPort)) {
  throw new Error("W4 contract fixture configuration is incomplete.");
}
if (process.env.NODE_ENV !== "development") {
  throw new Error("The W4 contract fixture is development-only.");
}
if (process.env.WAFLO_CONTRACT_ALLOW_LOCAL_DATABASE_MUTATION !== "EPHEMERAL_TEST_DATA_ONLY") {
  throw new Error("Explicit local ephemeral-data authorization is required.");
}

const databaseUrl = new URL(process.env.DATABASE_URL ?? "");
if (!["localhost", "127.0.0.1", "::1"].includes(databaseUrl.hostname)) {
  throw new Error("The W4 contract fixture only permits a local development database.");
}
const isolatedDatabaseName = process.env.WAFLO_TEST_DATABASE_NAME ?? "";
if (!/^waflo_test_[a-z0-9_]+$/.test(isolatedDatabaseName)) {
  throw new Error("The W4 contract fixture requires an isolated test database.");
}
if (decodeURIComponent(databaseUrl.pathname.slice(1)) !== isolatedDatabaseName) {
  throw new Error("The W4 contract fixture database does not match its isolation scope.");
}

const source = (path) => pathToFileURL(resolve(backendRoot, path)).href;
process.stdout.write("W4_CONTRACT_FIXTURE_BOOT source=verified\n");
const [
  { createApiApplication },
  { PrismaService },
  { CustomerSecurityService },
  { createPairingToken },
] =
  await Promise.all([
    import(source("apps/api/dist/app.js")),
    import(source("apps/api/dist/database/prisma.service.js")),
    import(source("apps/api/dist/customer/customer-security.service.js")),
    import(source("packages/staff-device-security/dist/index.js")),
  ]);

process.stdout.write("W4_CONTRACT_FIXTURE_BOOT imports=ready\n");
const app = await createApiApplication({ logger: false });
process.stdout.write("W4_CONTRACT_FIXTURE_BOOT application=ready\n");
const prisma = app.get(PrismaService).client;
const customerSecurity = app.get(CustomerSecurityService);
const trackedPairings = new Set();
const trackedInstallations = new Set();
const trackedMemberships = new Set();
const trackedCustomers = new Set();
let closed = false;

const ORGANIZATION_ID = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa";
const COOKIE_PROGRAM_ID = "c0000000-0000-4000-8000-000000000001";
const COOKIE_VERSION_ID = "c1000000-0000-4000-8000-000000000001";
const PURCHASE_PROGRAM_ID = "e0000000-0000-4000-8000-000000000001";
const PURCHASE_VERSION_ID = "e1000000-0000-4000-8000-000000000001";

await app.listen(apiPort, "127.0.0.1");
process.stdout.write("W4_CONTRACT_FIXTURE_BOOT api=listening\n");

function safeEqual(left, right) {
  const a = Buffer.from(left ?? "", "utf8");
  const b = Buffer.from(right ?? "", "utf8");
  return a.length === b.length && timingSafeEqual(a, b);
}

async function readJson(request) {
  const chunks = [];
  let length = 0;
  for await (const chunk of request) {
    length += chunk.length;
    if (length > 16_384) throw new Error("Control request is too large.");
    chunks.push(chunk);
  }
  if (chunks.length === 0) return {};
  const value = JSON.parse(Buffer.concat(chunks).toString("utf8"));
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Control request must be an object.");
  }
  return value;
}

function send(response, status, value) {
  const body = JSON.stringify(value);
  response.writeHead(status, {
    "content-type": "application/json",
    "cache-control": "no-store",
    "content-length": Buffer.byteLength(body),
  });
  response.end(body);
}

async function seededActors() {
  const staff = await prisma.organizationMember.findFirst({
    where: {
      status: "ACTIVE",
      role: "STAFF",
      user: { normalizedEmail: "staff@waflo.local" },
      organization: { status: "ACTIVE" },
    },
  });
  if (!staff) throw new Error("Seeded staff@waflo.local member was not found.");
  const owner = await prisma.organizationMember.findFirst({
    where: {
      organizationId: staff.organizationId,
      status: "ACTIVE",
      role: "OWNER",
    },
  });
  if (!owner) throw new Error("Seeded organization owner was not found.");
  const candidateAssignments = await prisma.staffLocationAssignment.findMany({
    where: {
      organizationId: staff.organizationId,
      organizationMemberId: staff.id,
      active: true,
      revokedAt: null,
    },
    orderBy: { createdAt: "asc" },
  });
  const activeLocations = await prisma.location.findMany({
    where: {
      id: { in: candidateAssignments.map((assignment) => assignment.locationId) },
      status: "ACTIVE",
      archivedAt: null,
    },
    select: { id: true },
  });
  const activeIds = new Set(activeLocations.map((location) => location.id));
  const assignments = candidateAssignments.filter((assignment) =>
    activeIds.has(assignment.locationId),
  );
  if (assignments.length === 0) throw new Error("Seeded staff has no active Location.");
  return { staff, owner, assignments };
}

async function createPairing() {
  const { staff, owner, assignments } = await seededActors();
  const pairingPublicId = randomUUID();
  const pairing = createPairingToken({
    publicId: pairingPublicId,
    environmentId: "development",
  });
  await prisma.devicePairingSession.create({
    data: {
      publicId: pairingPublicId,
      organizationId: staff.organizationId,
      intendedStaffMemberId: staff.id,
      pairingTokenHash: pairing.tokenHash,
      requestedLocationAssignments: assignments.map((assignment) => ({
        locationId: assignment.locationId,
        earningAllowed: assignment.earningAllowed,
        redemptionAllowed: assignment.redemptionAllowed,
      })),
      deviceLabelSuggestion: "M1 ephemeral contract device",
      createdByUserId: owner.userId,
      expiresAt: new Date(Date.now() + 10 * 60_000),
    },
  });
  trackedPairings.add(pairingPublicId);
  return { pairingQr: pairing.token };
}

async function createMembership(body) {
  const purchaseProgram = body.program === "purchase";
  if (!purchaseProgram && body.program !== "cookie") {
    throw new Error("Membership fixture program must be cookie or purchase.");
  }
  const customerId = randomUUID();
  const membershipId = randomUUID();
  const membershipPublicId = `mem_${randomUUID().replaceAll("-", "")}`;
  const credential = customerSecurity.createCredential(1);
  await prisma.$transaction(async (transaction) => {
    await transaction.customer.create({
      data: {
        id: customerId,
        organizationId: ORGANIZATION_ID,
        displayName: "W4 mobile M2 synthetic fixture",
        preferredLocale: "EN",
      },
    });
    await transaction.membership.create({
      data: {
        id: membershipId,
        organizationId: ORGANIZATION_ID,
        customerId,
        programId: purchaseProgram ? PURCHASE_PROGRAM_ID : COOKIE_PROGRAM_ID,
        enrollmentProgramVersionId: purchaseProgram
          ? PURCHASE_VERSION_ID
          : COOKIE_VERSION_ID,
        publicMembershipId: membershipPublicId,
      },
    });
    await transaction.membershipProgressProjection.create({
      data: {
        membershipId,
        organizationId: ORGANIZATION_ID,
        currentCycleStampCount: 0,
        completedCycleCount: 0,
        currentCycleNumber: 1,
        rewardReady: false,
        projectionVersion: 0,
        lastLedgerSequence: 0,
      },
    });
    await transaction.membershipCredential.create({
      data: {
        organizationId: ORGANIZATION_ID,
        membershipId,
        credentialVersion: 1,
        publicCredentialId: credential.publicCredentialId,
        secretVersion: credential.secretVersion,
        secretHash: credential.secretHash,
        status: "ACTIVE",
      },
    });
  });
  trackedCustomers.add(customerId);
  trackedMemberships.add(membershipId);
  return { membershipQr: credential.payload, membershipPublicId };
}

async function trackedDevice(devicePublicId) {
  if (typeof devicePublicId !== "string") throw new Error("devicePublicId is required.");
  const device = await prisma.staffDevice.findUnique({ where: { publicId: devicePublicId } });
  if (!device) throw new Error("Temporary device was not found.");
  const pairing = await prisma.devicePairingSession.findFirst({
    where: {
      publicId: { in: [...trackedPairings] },
      claimedInstallationId: device.installationId,
    },
  });
  if (!pairing) throw new Error("Refusing to mutate a device outside this fixture run.");
  trackedInstallations.add(device.installationId);
  return device;
}

async function setState(body) {
  const device = await trackedDevice(body.devicePublicId);
  switch (body.state) {
    case "revoked":
      await prisma.staffDevice.update({
        where: { id: device.id },
        data: {
          status: "REVOKED",
          revokedAt: new Date(),
          revocationReason: "M1 ephemeral contract gate",
        },
      });
      break;
    case "compromised":
      await prisma.staffDevice.update({
        where: { id: device.id },
        data: {
          status: "COMPROMISED",
          revokedAt: new Date(),
          revocationReason: "M1 ephemeral contract gate",
        },
      });
      break;
    case "sessionExpired":
      await prisma.staffDeviceSession.updateMany({
        where: { staffDeviceId: device.id, revokedAt: null },
        data: { expiresAt: new Date(Date.now() - 1_000) },
      });
      break;
    case "updateRequired":
      await prisma.staffDevice.update({
        where: { id: device.id },
        data: { appVersion: "0.0.0" },
      });
      break;
    default:
      throw new Error("Unsupported temporary device state.");
  }
  return { status: "ok" };
}

async function createCommand(body) {
  const device = await trackedDevice(body.devicePublicId);
  const membership = await prisma.membership.findUnique({
    where: { publicMembershipId: body.membershipPublicId },
  });
  if (!membership || !trackedMemberships.has(membership.id)) {
    throw new Error("Refusing to create a command outside this fixture run.");
  }
  if (body.status !== "PROCESSING" && body.status !== "FAILED") {
    throw new Error("Command fixture status must be PROCESSING or FAILED.");
  }
  const location = await prisma.staffDeviceLocation.findFirst({
    where: { staffDeviceId: device.id, active: true },
    orderBy: { locationId: "asc" },
  });
  if (!location) throw new Error("Temporary device has no active Location.");
  const commandId = randomUUID();
  await prisma.loyaltyOperationCommand.create({
    data: {
      organizationId: device.organizationId,
      membershipId: membership.id,
      operationType: "ISSUE_STAMP",
      idempotencyKey: commandId,
      requestFingerprint: commandId.replaceAll("-", "").repeat(2),
      status: body.status,
      safeFailureCode:
        body.status === "FAILED" ? "PURCHASE_CURRENCY_MISMATCH" : null,
      actorMemberId: device.organizationMemberId,
      actorDeviceId: device.id,
      locationId: location.locationId,
      ...(body.status === "FAILED" ? { completedAt: new Date() } : {}),
    },
  });
  return { commandId };
}

async function deleteMembershipData(membershipIds, customerIds) {
  if (membershipIds.length === 0 && customerIds.length === 0) return;
  const membershipWhere = { membershipId: { in: membershipIds } };
  await prisma.$transaction(async (transaction) => {
    await transaction.operationalRiskSignal.deleteMany({ where: membershipWhere });
    await transaction.operationalAnalyticsFact.deleteMany({ where: membershipWhere });
    await transaction.managerApprovalChallenge.deleteMany({ where: membershipWhere });
    await transaction.rewardRedemption.deleteMany({ where: membershipWhere });
    await transaction.rewardExpiryCommand.deleteMany({ where: membershipWhere });
    await transaction.rewardEntitlement.deleteMany({ where: membershipWhere });
    await transaction.loyaltyLedgerEntry.deleteMany({ where: membershipWhere });
    await transaction.loyaltyOperationCommand.deleteMany({ where: membershipWhere });
    await transaction.projectionRebuildCommand.deleteMany({ where: membershipWhere });
    await transaction.publicWalletAsset.deleteMany({ where: membershipWhere });
    await transaction.walletCommand.deleteMany({ where: membershipWhere });
    await transaction.walletPassInstance.deleteMany({ where: membershipWhere });
    await transaction.membershipTransferEvent.deleteMany({ where: membershipWhere });
    await transaction.membershipTransferCommand.deleteMany({ where: membershipWhere });
    await transaction.membershipAccessSession.deleteMany({ where: membershipWhere });
    await transaction.customerConsent.deleteMany({ where: membershipWhere });
    await transaction.enrollmentCommand.deleteMany({ where: membershipWhere });
    await transaction.membershipCredential.deleteMany({ where: membershipWhere });
    await transaction.membershipProgressProjection.deleteMany({ where: membershipWhere });
    await transaction.membership.deleteMany({ where: { id: { in: membershipIds } } });
    await transaction.customer.deleteMany({ where: { id: { in: customerIds } } });
  });
}

async function deleteInstallations(installations) {
  if (installations.size === 0) return;
  const devices = await prisma.staffDevice.findMany({
    where: { installationId: { in: [...installations] } },
    select: { id: true },
  });
  const deviceIds = devices.map((device) => device.id);
  await prisma.operationalRiskSignal.deleteMany({
    where: { staffDeviceId: { in: deviceIds } },
  });
  await prisma.deviceRequestNonce.deleteMany({
    where: { staffDeviceId: { in: deviceIds } },
  });
  await prisma.managerApprovalChallenge.deleteMany({
    where: { staffDeviceId: { in: deviceIds } },
  });
  await prisma.staffDeviceLocation.deleteMany({
    where: { staffDeviceId: { in: deviceIds } },
  });
  await prisma.staffDevice.deleteMany({
    where: { installationId: { in: [...installations] } },
  });
}

async function cleanupStaleFixtureData() {
  const staleCustomers = await prisma.customer.findMany({
    where: { displayName: "W4 mobile M2 synthetic fixture" },
    select: { id: true, memberships: { select: { id: true } } },
  });
  await deleteMembershipData(
    staleCustomers.flatMap((customer) => customer.memberships.map((membership) => membership.id)),
    staleCustomers.map((customer) => customer.id),
  );
  const stalePairings = await prisma.devicePairingSession.findMany({
    where: { deviceLabelSuggestion: "M1 ephemeral contract device" },
    select: { publicId: true, claimedInstallationId: true },
  });
  const staleDevices = await prisma.staffDevice.findMany({
    where: { displayName: "M1 ephemeral contract device" },
    select: { installationId: true },
  });
  const installations = new Set([
    ...stalePairings.flatMap((pairing) =>
      pairing.claimedInstallationId ? [pairing.claimedInstallationId] : [],
    ),
    ...staleDevices.map((device) => device.installationId),
  ]);
  await deleteInstallations(installations);
  await prisma.devicePairingSession.deleteMany({
    where: { publicId: { in: stalePairings.map((pairing) => pairing.publicId) } },
  });
}

async function cleanup() {
  // Loyalty history is append-only by database policy. The enclosing gate
  // force-drops this verified disposable database after the fixture exits.
  trackedInstallations.clear();
  trackedPairings.clear();
  trackedMemberships.clear();
  trackedCustomers.clear();
  return { status: "isolated_database_ready_for_drop" };
}

const control = createServer(async (request, response) => {
  try {
    if (!safeEqual(request.headers["x-waflo-contract-control"], controlSecret)) {
      send(response, 404, { error: "not_found" });
      return;
    }
    if (request.method === "POST" && request.url === "/fixture/create") {
      send(response, 200, await createPairing());
      return;
    }
    if (request.method === "POST" && request.url === "/fixture/membership") {
      send(response, 200, await createMembership(await readJson(request)));
      return;
    }
    if (request.method === "POST" && request.url === "/fixture/command") {
      send(response, 200, await createCommand(await readJson(request)));
      return;
    }
    if (request.method === "POST" && request.url === "/fixture/state") {
      send(response, 200, await setState(await readJson(request)));
      return;
    }
    if (request.method === "POST" && request.url === "/fixture/cleanup") {
      send(response, 200, await cleanup());
      return;
    }
    send(response, 404, { error: "not_found" });
  } catch (error) {
    send(response, 500, { error: "fixture_control_failed" });
    process.stderr.write(`W4 fixture control failure: ${error?.message ?? "unknown"}\n`);
  }
});

await cleanupStaleFixtureData();
await new Promise((resolveReady) => control.listen(controlPort, "127.0.0.1", resolveReady));
process.stdout.write(`W4_CONTRACT_FIXTURE_READY api=${apiPort} control=${controlPort}\n`);

async function close() {
  if (closed) return;
  closed = true;
  try {
    await cleanup();
  } finally {
    await new Promise((resolveClose) => control.close(resolveClose));
    await app.close();
  }
}

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => void close().finally(() => process.exit(0)));
}
