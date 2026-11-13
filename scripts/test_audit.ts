import 'dotenv/config';
import { getDb } from '../server/db';
import { auditLogs } from '../drizzle/schema';
import { desc } from 'drizzle-orm';

async function main() {
  const db = await getDb();
  if (!db) return;
  const logs = await db.select().from(auditLogs).orderBy(desc(auditLogs.createdAt)).limit(10);
  console.log("AUDIT LOGS:", JSON.stringify(logs, null, 2));
}

main().catch(console.error);
