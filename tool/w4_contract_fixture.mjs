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

const source = (path) => pathToFileURL(resolve(backendRoot, path)).href;
process.stdout.write("W4_CONTRACT_FIXTURE_BOOT source=verified\n");
const [{ createApiApplication }, { PrismaService }, { createPairingToken }] =
  await Promise.all([
    import(source("apps/api/dist/app.js")),
    import(source("apps/api/dist/database/prisma.service.js")),
    import(source("packages/staff-device-security/dist/index.js")),
  ]);

process.stdout.write("W4_CONTRACT_FIXTURE_BOOT imports=ready\n");
const app = await createApiApplication({ logger: false });
process.stdout.write("W4_CONTRACT_FIXTURE_BOOT application=ready\n");
const prisma = app.get(PrismaService).client;
const trackedPairings = new Set();
const trackedInstallations = new Set();
let closed = false;

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
  for (const publicId of trackedPairings) {
    const pairing = await prisma.devicePairingSession.findUnique({ where: { publicId } });
    if (pairing?.claimedInstallationId) trackedInstallations.add(pairing.claimedInstallationId);
  }
  if (trackedInstallations.size > 0) {
    await deleteInstallations(trackedInstallations);
  }
  if (trackedPairings.size > 0) {
    await prisma.devicePairingSession.deleteMany({
      where: { publicId: { in: [...trackedPairings] } },
    });
  }
  trackedInstallations.clear();
  trackedPairings.clear();
  return { status: "clean" };
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
