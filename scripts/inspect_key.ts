import 'dotenv/config';
import { getDb } from '../server/db';
import { licenses, deviceBindings } from '../drizzle/schema';
import { eq, like } from 'drizzle-orm';

async function main() {
  const db = await getDb();
  if (!db) {
    console.log("No DB connection");
    return;
  }
  const keyRows = await db.select().from(licenses).where(like(licenses.keyValue, '%4DX4BWXUMLYKJ0GRXMPRDXGX%'));
  console.log("KEY ROWS:", JSON.stringify(keyRows, null, 2));

  if (keyRows.length > 0) {
    const bindings = await db.select().from(deviceBindings).where(eq(deviceBindings.licenseKeyId, keyRows[0].id));
    console.log("BINDINGS:", JSON.stringify(bindings, null, 2));
  }
}

main().catch(console.error);
