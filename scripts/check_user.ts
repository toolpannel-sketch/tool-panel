import 'dotenv/config';
import { getDb } from '../server/db';
import { users } from '../drizzle/schema';
import { eq } from 'drizzle-orm';

async function main() {
  const db = await getDb();
  if (!db) return;
  const userRows = await db.select().from(users).where(eq(users.id, 1));
  console.log("USER 1:", JSON.stringify(userRows, null, 2));
}

main().catch(console.error);
