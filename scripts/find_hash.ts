import 'dotenv/config';
import { getDb } from '../server/db';
import { deviceBindings, licenses } from '../drizzle/schema';
import { eq } from 'drizzle-orm';

async function main() {
  const db = await getDb();
  if (!db) return;
  const hash = 'eb5b1d8640dec45d7106a2e078365825be4fd2cb259c4ed6c4778aaef82b0f45';
  const rows = await db.select().from(deviceBindings).where(eq(deviceBindings.deviceHash, hash));
  console.log("All bindings with this hash:", JSON.stringify(rows, null, 2));
}

main().catch(console.error);
