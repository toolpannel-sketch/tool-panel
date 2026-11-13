import { eq } from "drizzle-orm";

import { auditLogs, serverMaintenance } from "../drizzle/schema";
import { getDb } from "./db";

export const MAINTENANCE_MESSAGE_MAX_LENGTH = 300;
export const MAINTENANCE_TITLE_MAX_LENGTH = 80;

/**
 * Mirrors the existing announcement text safety rules without coupling the removable
 * maintenance module to announcement persistence or presentation behavior.
 */
export function normalizeMaintenanceText(value: string, maxLength: number) {
  const normalized = value.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "").trim();
  if (normalized.length > maxLength) throw new Error(`Maintenance text cannot exceed ${maxLength} characters`);
  return normalized;
}

function maintenanceTime(value: Date | string | null) {
  return value == null ? null : new Date(value).getTime();
}

export function isMaintenanceActive(maintenance: { enabled: boolean; message: string; startAt: Date | string | null; endAt: Date | string | null }, now = new Date()) {
  const start = maintenanceTime(maintenance.startAt);
  const end = maintenanceTime(maintenance.endAt);
  return maintenance.enabled && maintenance.message.length > 0 && (!start || start <= now.getTime()) && (!end || end >= now.getTime());
}

export function toMaintenancePayload(maintenance: typeof serverMaintenance.$inferSelect | null, now = new Date()) {
  if (!maintenance || !isMaintenanceActive(maintenance, now)) return { active: false as const };
  return {
    active: true as const,
    version: maintenance.version,
    title: maintenance.title,
    message: maintenance.message,
    endAt: maintenance.endAt == null ? null : new Date(maintenance.endAt).toISOString(),
  };
}

export async function getServerMaintenance() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return (await db.select().from(serverMaintenance).where(eq(serverMaintenance.id, 1)).limit(1))[0] ?? null;
}

export async function getActiveServerMaintenance(now = new Date()) {
  return toMaintenancePayload(await getServerMaintenance(), now);
}

export async function updateServerMaintenance(input: { enabled: boolean; title: string; message: string; startAt: Date | null; endAt: Date | null }, actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const title = normalizeMaintenanceText(input.title, MAINTENANCE_TITLE_MAX_LENGTH) || "SERVER MAINTENANCE";
  const message = normalizeMaintenanceText(input.message, MAINTENANCE_MESSAGE_MAX_LENGTH);
  if (input.enabled && message.length === 0) throw new Error("Maintenance message is required while maintenance is enabled");
  if (input.startAt && input.endAt && input.startAt.getTime() > input.endAt.getTime()) throw new Error("Maintenance start must be before its end");

  const current = await getServerMaintenance();
  const values = {
    enabled: input.enabled,
    title,
    message,
    startAt: input.startAt,
    endAt: input.endAt,
    updatedByUserId: actorUserId,
    ...(current ? { version: current.version + 1 } : {}),
  };
  if (current) await db.update(serverMaintenance).set(values).where(eq(serverMaintenance.id, 1));
  else await db.insert(serverMaintenance).values({ id: 1, ...values });

  await db.insert(auditLogs).values({
    actorUserId,
    action: input.enabled ? "maintenance_enabled_or_updated" : "maintenance_disabled",
    entityType: "server_maintenance",
    entityId: 1,
    details: `version=${current ? current.version + 1 : 1}`,
  });
  return getServerMaintenance();
}
