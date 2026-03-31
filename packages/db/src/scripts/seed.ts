import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { pool } from "../client.js";

async function run() {
  const client = await pool.connect();
  try {
    const absolutePath = join(process.cwd(), "migrations", "003_seed.sql");
    const sql = await readFile(absolutePath, "utf8");
    await client.query(sql);
    console.log("Seed completed successfully.");
  } finally {
    client.release();
    await pool.end();
  }
}

run().catch((error) => {
  console.error("Seed failed:", error);
  process.exit(1);
});
