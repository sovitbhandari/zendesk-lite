import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";
import { databaseUrl } from "./config.js";

export const pool = new Pool({ connectionString: databaseUrl });
export const db = drizzle(pool);
