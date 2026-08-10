import { createRequire } from "node:module";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const backendRoot = process.env.WAFLO_W4_BACKEND_ROOT;
const baseDatabaseUrl = process.env.WAFLO_W4_BASE_DATABASE_URL;
const [mode, databaseName] = process.argv.slice(2);

if (!backendRoot || !baseDatabaseUrl) {
  throw new Error("Isolated W4 database configuration is incomplete.");
}
if (!/^waflo_test_[a-z0-9_]+$/.test(databaseName ?? "") || databaseName.length > 63) {
  throw new Error("Refusing to manage an unsafe test database name.");
}
if (mode !== "create" && mode !== "drop") {
  throw new Error("Expected isolated database mode create or drop.");
}

const adminUrl = new URL(baseDatabaseUrl);
if (
  !["postgres:", "postgresql:"].includes(adminUrl.protocol) ||
  !["localhost", "127.0.0.1", "::1"].includes(adminUrl.hostname)
) {
  throw new Error("Isolated W4 databases require local PostgreSQL.");
}
adminUrl.searchParams.delete("schema");

const packageRequire = createRequire(
  pathToFileURL(resolve(backendRoot, "packages/database/package.json")),
);
const { Client } = packageRequire("pg");
const client = new Client({ connectionString: adminUrl.toString() });

await client.connect();
try {
  if (mode === "create") {
    await client.query(`CREATE DATABASE "${databaseName}" TEMPLATE template0 ENCODING 'UTF8'`);
  } else {
    await client.query(`DROP DATABASE IF EXISTS "${databaseName}" WITH (FORCE)`);
  }
} finally {
  await client.end();
}
