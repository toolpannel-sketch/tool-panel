import crypto from "node:crypto";
import { and, desc, eq, gt, inArray, like, or, sql } from "drizzle-orm";
import { alias } from "drizzle-orm/mysql-core";

import { auditLogs, deviceBindings, licenses, referrals, systemAnnouncements, telegramAccountScopes, telegramChannels, telegramKeyMappings, telegramTickets, users } from "../drizzle/schema";
import { getDb } from "./db";
import { ENV } from "./_core/env";

export const API_ERROR_CODES = [
  "invalid_key",
  "key_banned",
  "key_expired",
  "device_limit_reached",
  "device_already_bound",
] as const;

export const CANONICAL_LICENSE_STATUSES = ["active", "expired", "revoked", "unused"] as const;
export type CanonicalLicenseStatus = (typeof CANONICAL_LICENSE_STATUSES)[number];
export type ValidationStatus = "not_registered" | "invalid" | "expired" | "device_mismatch" | "device_max_reached" | "valid";
export type ValidationResponse = { success: boolean; status: ValidationStatus; message: string; expiresAt?: string };
export const LICENSE_DURATION_UNITS = ["minutes", "hours", "days", "weeks", "months"] as const;
export type LicenseDurationUnit = (typeof LICENSE_DURATION_UNITS)[number];
export const RECENT_AUDIT_LOG_LIMIT = 15;
export const USERNAME_CHANGE_COOLDOWN_MS = 72 * 60 * 60 * 1000;
export const USERNAME_PATTERN = /^[A-Za-z0-9](?:[A-Za-z0-9 _.-]{1,30}[A-Za-z0-9])?$/;
export const GENERATED_LICENSE_KEY_MAX_LENGTH = 50;
export const ANNOUNCEMENT_MESSAGE_MAX_LENGTH = 300;
export const ANNOUNCEMENT_TITLE_MAX_LENGTH = 80;
export type AnnouncementDisplayMode = "every_login" | "once_per_day";
export type AnnouncementTextSize = "small" | "normal" | "large" | "festival_large";

export function normalizeAnnouncementText(value: string, maxLength: number) {
  const normalized = value.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/g, "").trim();
  if (normalized.length > maxLength) throw new Error(`Announcement text cannot exceed ${maxLength} characters`);
  return normalized;
}

function announcementTime(value: Date | string | null) {
  return value == null ? null : new Date(value).getTime();
}

export function isAnnouncementActive(announcement: { enabled: boolean; message: string; startAt: Date | string | null; endAt: Date | string | null }, now = new Date()) {
  const start = announcementTime(announcement.startAt);
  const end = announcementTime(announcement.endAt);
  return announcement.enabled && announcement.message.length > 0 && (!start || start <= now.getTime()) && (!end || end >= now.getTime());
}

export function toAnnouncementPayload(announcement: typeof systemAnnouncements.$inferSelect | null, now = new Date()) {
  if (!announcement || !isAnnouncementActive(announcement, now)) return { active: false as const };
  return { active: true as const, id: announcement.id, version: announcement.version, title: announcement.title, message: announcement.message, displayMode: announcement.displayMode, textSize: announcement.textSize, endAt: announcement.endAt == null ? null : new Date(announcement.endAt).toISOString() };
}

export async function getSystemAnnouncement() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return (await db.select().from(systemAnnouncements).where(eq(systemAnnouncements.id, 1)).limit(1))[0] ?? null;
}

export async function getActiveSystemAnnouncement(now = new Date()) {
  return toAnnouncementPayload(await getSystemAnnouncement(), now);
}

export async function updateSystemAnnouncement(input: { enabled: boolean; title: string; message: string; startAt: Date | null; endAt: Date | null; displayMode: AnnouncementDisplayMode; textSize: AnnouncementTextSize }, actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const title = normalizeAnnouncementText(input.title, ANNOUNCEMENT_TITLE_MAX_LENGTH) || "SYSTEM ANNOUNCEMENT";
  const message = normalizeAnnouncementText(input.message, ANNOUNCEMENT_MESSAGE_MAX_LENGTH);
  if (input.startAt && input.endAt && input.startAt.getTime() > input.endAt.getTime()) throw new Error("Announcement start must be before its end");
  const current = await getSystemAnnouncement();
  const values = { enabled: input.enabled, title, message, startAt: input.startAt, endAt: input.endAt, displayMode: input.displayMode, textSize: input.textSize, updatedByUserId: actorUserId, ...(current ? { version: current.version + 1 } : {}) };
  if (current) await db.update(systemAnnouncements).set(values).where(eq(systemAnnouncements.id, 1));
  else await db.insert(systemAnnouncements).values({ id: 1, ...values });
  await recordAudit(actorUserId, input.enabled ? "announcement_enabled_or_updated" : "announcement_disabled", "system_announcement", 1, undefined, `version=${current ? current.version + 1 : 1};displayMode=${input.displayMode};textSize=${input.textSize}`);
  return getSystemAnnouncement();
}

export function normalizeUsername(value: string) {
  const username = value.trim().replace(/\s+/g, " ");
  if (username.length < 3 || username.length > 32 || !USERNAME_PATTERN.test(username)) {
    throw new Error("Username must be 3–32 characters and may contain letters, numbers, spaces, dots, hyphens, or underscores");
  }
  return username;
}

export function usernameToKeyPrefix(username: string | null | undefined) {
  const normalized = (username ?? "")
    .trim()
    .toUpperCase()
    .replace(/\s+/g, "-")
    .replace(/[^A-Z0-9-]/g, "")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 24);
  return normalized || undefined;
}

export function getUsernameChangeAvailability(usernameChangedAt: Date | null | undefined, now = new Date()) {
  if (!usernameChangedAt) return { available: true, nextAllowedAt: null, remainingMs: 0 };
  const nextAllowedAt = new Date(usernameChangedAt.getTime() + USERNAME_CHANGE_COOLDOWN_MS);
  const remainingMs = Math.max(0, nextAllowedAt.getTime() - now.getTime());
  return { available: remainingMs === 0, nextAllowedAt, remainingMs };
}

export function durationToMinutes(amount: number, unit: LicenseDurationUnit) {
  const multipliers: Record<LicenseDurationUnit, number> = { minutes: 1, hours: 60, days: 1440, weeks: 10080, months: 43200 };
  return amount * multipliers[unit];
}

const VALIDATION_MESSAGES: Record<ValidationStatus, string> = {
  not_registered: "License key is not registered.",
  invalid: "License key has been revoked.",
  expired: "License key has expired.",
  device_mismatch: "License key is bound to a different device.",
  device_max_reached: "Maximum device limit reached for this license.",
  valid: "License is valid for this device.",
};

function validationResponse(status: ValidationStatus): ValidationResponse {
  return { success: status === "valid", status, message: VALIDATION_MESSAGES[status] };
}

export function getApiSharedSecret() {
  return crypto.createHash("sha256").update(`${ENV.cookieSecret}:lua-license-api`).digest("hex");
}

export function normalizeKeyPrefix(prefix: string | undefined) {
  const normalized = (prefix?.trim() || "LUA").replace(/[^A-Za-z0-9_-]/g, "-").replace(/[-_]+/g, "-").replace(/^-+|-+$/g, "").toUpperCase();
  if (!normalized || normalized.length > 24) throw new Error("Custom key name must contain 1–24 letters or numbers");
  return normalized;
}

export function hasUnexpiredCustomPrefixConflict(keys: Array<{ keyValue: string; expiresAt: Date | null; status?: CanonicalLicenseStatus }>, prefix: string, now = new Date()) {
  const safePrefix = normalizeKeyPrefix(prefix);
  return keys.some(key => key.keyValue.startsWith(`${safePrefix}-`) && key.status !== "revoked" && (!key.expiresAt || key.expiresAt.getTime() > now.getTime()));
}

export function hasUnexpiredExactKeyConflict(keys: Array<{ keyValue: string; expiresAt: Date | null; status?: CanonicalLicenseStatus }>, keyName: string, now = new Date()) {
  const safeKeyName = normalizeKeyPrefix(keyName);
  return keys.some(key => key.keyValue === safeKeyName && key.status !== "revoked" && (!key.expiresAt || key.expiresAt.getTime() > now.getTime()));
}

export function isReferralUsable(referral: { status: "active" | "redeemed" | "revoked"; expiresAt: Date }, now = new Date()) {
  return referral.status === "active" && referral.expiresAt.getTime() > now.getTime();
}

export function isReferralDeletable(referral: { status: "active" | "redeemed" | "revoked"; expiresAt: Date }, now = new Date()) {
  return referral.status !== "active" || referral.expiresAt.getTime() <= now.getTime();
}

export function generateLicenseKey(prefix = "LUA") {
  const safePrefix = normalizeKeyPrefix(prefix);
  const randomSuffix = crypto.randomBytes(18).toString("base64url").replace(/[-_]/g, "X").toUpperCase();
  const availablePrefixLength = GENERATED_LICENSE_KEY_MAX_LENGTH - randomSuffix.length - 1;
  return `${safePrefix.slice(0, availablePrefixLength)}-${randomSuffix}`;
}

export function generateExactLicenseKey(keyName: string) {
  return normalizeKeyPrefix(keyName);
}

export function hashDevice(deviceId: string) {
  return crypto.createHash("sha256").update(`${getApiSharedSecret()}:${deviceId.trim()}`).digest("hex");
}

export type LicenseActor = { id: number; isOwner: boolean };

export function canAccessLicense(actor: LicenseActor, createdByUserId: number | null) {
  return actor.isOwner || createdByUserId === actor.id;
}

function effectiveStatus(status: CanonicalLicenseStatus, expiresAt: Date | null, now = new Date()): CanonicalLicenseStatus {
  return status !== "revoked" && (status === "expired" || Boolean(expiresAt && expiresAt.getTime() <= now.getTime())) ? "expired" : status;
}

export function indexBindingCounts(rows: Array<{ licenseKeyId: number; count: number | string }>) {
  return new Map(rows.map(row => [row.licenseKeyId, Number(row.count)]));
}

async function getBindingCounts(db: NonNullable<Awaited<ReturnType<typeof getDb>>>, licenseIds?: number[]) {
  const rows = await db.select({ licenseKeyId: deviceBindings.licenseKeyId, count: sql<number>`count(*)` })
    .from(deviceBindings)
    .where(licenseIds?.length ? sql`${deviceBindings.licenseKeyId} in (${sql.join(licenseIds.map(id => sql`${id}`), sql`, `)})` : undefined)
    .groupBy(deviceBindings.licenseKeyId);
  return indexBindingCounts(rows);
}

export async function listKeys(actor: LicenseActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const rows = await db.select({
    id: licenses.id,
    keyValue: licenses.keyValue,
    status: licenses.status,
    expiresAt: licenses.expiresAt,
    activatedAt: licenses.activatedAt,
    durationMinutes: licenses.durationMinutes,
    maxDevices: licenses.maxDevices,
    boundDeviceId: licenses.boundDeviceId,
    createdAt: licenses.createdAt,
    updatedAt: licenses.updatedAt,
  }).from(licenses).where(actor.isOwner ? undefined : eq(licenses.createdByUserId, actor.id)).orderBy(desc(licenses.createdAt));
  const counts = await getBindingCounts(db, rows.map(row => row.id));
  return rows.map(row => ({
    ...row,
    status: effectiveStatus(row.status, row.expiresAt),
    activationState: row.activatedAt ? "activated" : "not_activated",
    durationMinutes: row.durationMinutes == null ? null : Number(row.durationMinutes),
    maxDevices: Number(row.maxDevices),
    usedDevices: counts.get(row.id) ?? 0,
  }));
}

export async function getStats(actor: LicenseActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const now = new Date();
  const keyScope = actor.isOwner ? undefined : eq(licenses.createdByUserId, actor.id);
  const activeScope = actor.isOwner
    ? and(eq(licenses.status, "active"), gt(licenses.expiresAt, now))
    : and(eq(licenses.status, "active"), gt(licenses.expiresAt, now), eq(licenses.createdByUserId, actor.id));
  const revokedScope = actor.isOwner ? eq(licenses.status, "revoked") : and(eq(licenses.status, "revoked"), eq(licenses.createdByUserId, actor.id));
  const bindingScope = actor.isOwner ? undefined : eq(licenses.createdByUserId, actor.id);
  const [total, active, revoked, bindings] = await Promise.all([
    db.select({ value: sql<number>`count(*)` }).from(licenses).where(keyScope),
    db.select({ value: sql<number>`count(*)` }).from(licenses).where(activeScope),
    db.select({ value: sql<number>`count(*)` }).from(licenses).where(revokedScope),
    db.select({ value: sql<number>`count(*)` }).from(deviceBindings).innerJoin(licenses, eq(deviceBindings.licenseKeyId, licenses.id)).where(bindingScope),
  ]);
  return {
    totalKeys: Number(total[0]?.value ?? 0),
    activeKeys: Number(active[0]?.value ?? 0),
    revokedKeys: Number(revoked[0]?.value ?? 0),
    totalDeviceBindings: Number(bindings[0]?.value ?? 0),
  };
}

export function maskKey(key: string) {
  const [prefix, suffix = ""] = key.split(/-(.+)/);
  return `${prefix}-****${suffix.slice(-4)}`;
}

export const MAX_LICENSE_DEVICES = 10_000;

export function isValidMaximumDevices(value: number) {
  return Number.isInteger(value) && value >= 1 && value <= MAX_LICENSE_DEVICES;
}

async function recordAudit(actorUserId: number | null, action: string, entityType: string, entityId?: number, keyPreview?: string, details?: string) {
  const db = await getDb();
  if (!db) return;
  await db.insert(auditLogs).values({ actorUserId, action, entityType, entityId, keyPreview: keyPreview ? maskKey(keyPreview) : undefined, details });
}

export async function generateKey(durationMinutes: number, createdByUserId: number, customPrefix?: string, maxDevices = 1, creatorUsername?: string | null, useExactCustomKey = false) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  if (!Number.isInteger(durationMinutes) || durationMinutes < 1 || durationMinutes > 5256000) throw new Error("License duration must be between 1 minute and 10 years");
  if (!isValidMaximumDevices(maxDevices)) throw new Error(`Maximum devices must be between 1 and ${MAX_LICENSE_DEVICES}`);
  if (useExactCustomKey && !customPrefix?.trim()) throw new Error("Enter a custom key name for exact-name mode");
  const safePrefix = customPrefix?.trim() ? normalizeKeyPrefix(customPrefix) : usernameToKeyPrefix(creatorUsername) ?? "LUA";
  if (customPrefix?.trim()) {
    const existing = await db.select({ keyValue: licenses.keyValue, expiresAt: licenses.expiresAt, status: licenses.status }).from(licenses).where(useExactCustomKey ? eq(licenses.keyValue, safePrefix) : like(licenses.keyValue, `${safePrefix}-%`)).limit(1);
    const hasConflict = useExactCustomKey ? hasUnexpiredExactKeyConflict(existing, safePrefix) : hasUnexpiredCustomPrefixConflict(existing, safePrefix);
    if (hasConflict) throw new Error(`Custom key name ${safePrefix} already exists until its key expires, is revoked, or is deleted`);
  }
  const keyValue = useExactCustomKey ? generateExactLicenseKey(safePrefix) : generateLicenseKey(safePrefix);
  const inserted = await db.insert(licenses).values({ keyValue, expiresAt: null, activatedAt: null, durationMinutes, createdByUserId, status: "unused", maxDevices });
  await recordAudit(createdByUserId, "key_created", "license", Number(inserted[0].insertId), keyValue, `durationMinutes=${durationMinutes};activation=pending;maxDevices=${maxDevices}`);
  return { keyValue, expiresAt: null, activatedAt: null, durationMinutes, maxDevices };
}

async function assertKeyAccess(id: number, actor: LicenseActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const row = (await db.select().from(licenses).where(eq(licenses.id, id)).limit(1))[0];
  if (!row) throw new Error("License key not found");
  if (!canAccessLicense(actor, row.createdByUserId)) throw new Error("You can only manage keys you created");
  return { db, row };
}

export async function updateLicense(id: number, values: { status: CanonicalLicenseStatus; expiresAt?: Date; maxDevices: number }, actor: LicenseActor) {
  const { db, row } = await assertKeyAccess(id, actor);
  const boundCount = Number((await db.select({ value: sql<number>`count(*)` }).from(deviceBindings).where(eq(deviceBindings.licenseKeyId, id)))[0]?.value ?? 0);
  if (!isValidMaximumDevices(values.maxDevices)) throw new Error(`Maximum devices must be between 1 and ${MAX_LICENSE_DEVICES}`);
  if (values.maxDevices < boundCount) throw new Error(`Maximum devices cannot be below the ${boundCount} currently bound device${boundCount === 1 ? "" : "s"}`);
  await db.update(licenses).set({ status: values.status, ...(values.expiresAt ? { expiresAt: values.expiresAt } : {}), maxDevices: values.maxDevices }).where(eq(licenses.id, id));
  await recordAudit(actor.id, "key_updated", "license", id, row.keyValue, `status=${values.status};expires=${values.expiresAt ? values.expiresAt.toISOString() : "unchanged"};maxDevices=${values.maxDevices}`);
  return { success: true };
}

export async function setKeyStatus(id: number, status: CanonicalLicenseStatus, actor: LicenseActor) {
  const { db, row } = await assertKeyAccess(id, actor);
  await db.update(licenses).set({ status }).where(eq(licenses.id, id));
  await recordAudit(actor.id, status === "revoked" ? "key_revoked" : "key_status_updated", "license", id, row.keyValue, `status=${status}`);
  return { success: true };
}

export async function deleteKey(id: number, actor: LicenseActor) {
  if (!actor.isOwner) throw new Error("Only the owner can delete license keys");
  const { db, row } = await assertKeyAccess(id, actor);
  await db.delete(deviceBindings).where(eq(deviceBindings.licenseKeyId, id));
  await db.delete(licenses).where(eq(licenses.id, id));
  await recordAudit(actor.id, "key_deleted", "license", id, row.keyValue);
  return { success: true };
}

export async function createReferral(role: "admin" | "owner", durationDays: number, createdByUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const expiresAt = new Date(Date.now() + durationDays * 86400000);
  const code = `REF-${crypto.randomBytes(18).toString("base64url").toUpperCase()}`;
  const inserted = await db.insert(referrals).values({ code, role, createdByUserId, expiresAt });
  await recordAudit(createdByUserId, "referral_created", "referral", Number(inserted[0].insertId), undefined, `role=${role};expires=${expiresAt.toISOString()}`);
  return { code, role, expiresAt };
}

export async function listReferrals(actor?: { id: number; role?: string }) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  if (actor && actor.role !== "super_owner") {
    return db.select().from(referrals).where(eq(referrals.createdByUserId, actor.id)).orderBy(desc(referrals.createdAt));
  }
  return db.select().from(referrals).orderBy(desc(referrals.createdAt));
}

export async function revokeReferral(id: number, actor: { id: number; role?: string } | number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const referral = (await db.select().from(referrals).where(eq(referrals.id, id)).limit(1))[0];
  if (!referral) throw new Error("Referral not found");
  const actorId = typeof actor === "number" ? actor : actor.id;
  const isSuper = typeof actor === "object" && actor.role === "super_owner";
  if (!isSuper && referral.createdByUserId !== actorId) {
    throw new Error("You can only revoke referrals created by your account");
  }
  if (referral.status !== "active") throw new Error("Only active referrals can be revoked");
  await db.update(referrals).set({ status: "revoked" }).where(eq(referrals.id, id));
  await recordAudit(actorId, "referral_revoked", "referral", id, undefined, `expires=${referral.expiresAt.toISOString()}`);
  return { success: true };
}

export async function deleteReferral(id: number, actor: { id: number; role?: string } | number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const referral = (await db.select().from(referrals).where(eq(referrals.id, id)).limit(1))[0];
  if (!referral) throw new Error("Referral not found");
  const actorId = typeof actor === "number" ? actor : actor.id;
  const isSuper = typeof actor === "object" && actor.role === "super_owner";
  if (!isSuper && referral.createdByUserId !== actorId) {
    throw new Error("You can only delete referrals created by your account");
  }
  if (!isReferralDeletable(referral)) throw new Error("Only revoked, redeemed, or expired referrals can be deleted");
  await db.delete(referrals).where(eq(referrals.id, id));
  await recordAudit(actorId, "referral_deleted", "referral", id, undefined, `status=${referral.status};expires=${referral.expiresAt.toISOString()}`);
  return { success: true };
}

export async function redeemReferral(code: string, userId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const referral = (await db.select().from(referrals).where(and(eq(referrals.code, code.trim().toUpperCase()), eq(referrals.status, "active"), gt(referrals.expiresAt, new Date()))).limit(1))[0];
  if (!referral || !isReferralUsable(referral)) throw new Error("Referral is invalid, expired, already used, or revoked");
  await db.update(users).set({ role: referral.role, accessStatus: "active", accessExpiresAt: referral.expiresAt }).where(eq(users.id, userId));
  await db.update(referrals).set({ status: "redeemed", redeemedByUserId: userId, redeemedAt: new Date() }).where(eq(referrals.id, referral.id));
  await recordAudit(userId, "referral_redeemed", "referral", referral.id, undefined, `role=${referral.role};expires=${referral.expiresAt.toISOString()}`);
  const redeemedUser = (await db.select({ username: users.username }).from(users).where(eq(users.id, userId)).limit(1))[0];
  return { success: true, role: referral.role, expiresAt: referral.expiresAt, needsUsername: !redeemedUser?.username };
}

export async function listAuditLogs() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return db.select({ id: auditLogs.id, actorUserId: auditLogs.actorUserId, action: auditLogs.action, entityType: auditLogs.entityType, entityId: auditLogs.entityId, keyPreview: auditLogs.keyPreview, details: auditLogs.details, createdAt: auditLogs.createdAt, actorName: sql<string | null>`coalesce(${users.username}, ${users.name}, ${users.email})` }).from(auditLogs).leftJoin(users, eq(auditLogs.actorUserId, users.id)).orderBy(desc(auditLogs.createdAt)).limit(RECENT_AUDIT_LOG_LIMIT);
}

export async function getSeasonControlCounts() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const [keyRows, referralRows] = await Promise.all([
    db.select({ value: sql<number>`count(*)` }).from(licenses),
    db.select({ value: sql<number>`count(*)` }).from(referrals),
  ]);
  return { keys: Number(keyRows[0]?.value ?? 0), referrals: Number(referralRows[0]?.value ?? 0) };
}

export async function deleteAllKeys(actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return db.transaction(async tx => {
    const count = Number((await tx.select({ value: sql<number>`count(*)` }).from(licenses))[0]?.value ?? 0);
    await tx.delete(deviceBindings);
    await tx.delete(licenses);
    await tx.insert(auditLogs).values({ actorUserId, action: "all_keys_deleted", entityType: "season", details: `deletedCount=${count}` });
    return { success: true, deletedCount: count };
  });
}

export async function deleteAllReferrals(actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return db.transaction(async tx => {
    const count = Number((await tx.select({ value: sql<number>`count(*)` }).from(referrals))[0]?.value ?? 0);
    await tx.delete(referrals);
    await tx.insert(auditLogs).values({ actorUserId, action: "all_referrals_deleted", entityType: "season", details: `deletedCount=${count}` });
    return { success: true, deletedCount: count };
  });
}

export async function getReferralOverview() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const rows = await db.select({
    userId: users.id,
    username: users.username,
    name: users.name,
    email: users.email,
    role: users.role,
    total: sql<number>`count(${referrals.id})`,
    active: sql<number>`sum(case when ${referrals.status} = 'active' then 1 else 0 end)`,
    redeemed: sql<number>`sum(case when ${referrals.status} = 'redeemed' then 1 else 0 end)`,
    revoked: sql<number>`sum(case when ${referrals.status} = 'revoked' then 1 else 0 end)`,
  }).from(users)
    .leftJoin(referrals, eq(referrals.createdByUserId, users.id))
    .groupBy(users.id, users.username, users.name, users.email, users.role)
    .orderBy(desc(sql<number>`count(${referrals.id})`), users.username);
  return rows.map(row => ({
    ...row,
    creatorName: row.username || row.name || row.email || `User ${row.userId}`,
    total: Number(row.total ?? 0),
    active: Number(row.active ?? 0),
    redeemed: Number(row.redeemed ?? 0),
    revoked: Number(row.revoked ?? 0),
  }));
}

export async function getAllKeysOverview() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const rows = await db.select({
    id: licenses.id,
    keyValue: licenses.keyValue,
    status: licenses.status,
    expiresAt: licenses.expiresAt,
    activatedAt: licenses.activatedAt,
    durationMinutes: licenses.durationMinutes,
    maxDevices: licenses.maxDevices,
    boundDeviceId: licenses.boundDeviceId,
    createdAt: licenses.createdAt,
    creatorUserId: users.id,
    creatorUsername: users.username,
    creatorName: users.name,
    creatorEmail: users.email,
    creatorRole: users.role,
  }).from(licenses).leftJoin(users, eq(licenses.createdByUserId, users.id)).orderBy(desc(licenses.createdAt));
  const counts = await getBindingCounts(db, rows.map(row => row.id));
  return rows.map(row => ({
    ...row,
    status: effectiveStatus(row.status, row.expiresAt),
    activationState: row.activatedAt ? "activated" : "not_activated",
    creatorDisplayName: row.creatorUsername || row.creatorName || row.creatorEmail || "Removed account / legacy key",
    durationMinutes: row.durationMinutes == null ? null : Number(row.durationMinutes),
    maxDevices: Number(row.maxDevices),
    usedDevices: counts.get(row.id) ?? 0,
  }));
}

export async function getAllReferralsDetailed() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const creatorUser = alias(users, "creatorUser");
  const redeemerUser = alias(users, "redeemerUser");
  const rows = await db.select({
    id: referrals.id,
    code: referrals.code,
    role: referrals.role,
    status: referrals.status,
    expiresAt: referrals.expiresAt,
    redeemedAt: referrals.redeemedAt,
    createdAt: referrals.createdAt,
    creatorUserId: referrals.createdByUserId,
    creatorUsername: creatorUser.username,
    creatorRole: creatorUser.role,
    redeemerUserId: referrals.redeemedByUserId,
    redeemerUsername: redeemerUser.username,
  }).from(referrals)
    .leftJoin(creatorUser, eq(referrals.createdByUserId, creatorUser.id))
    .leftJoin(redeemerUser, eq(referrals.redeemedByUserId, redeemerUser.id))
    .orderBy(desc(referrals.createdAt));

  return rows.map(r => ({
    ...r,
    creatorDisplayName: r.creatorUsername || (r.creatorUserId ? `User #${r.creatorUserId}` : "System"),
    redeemerDisplayName: r.redeemerUsername || (r.redeemerUserId ? `User #${r.redeemerUserId}` : null),
  }));
}

export async function getBindings(keyId: number, actor: LicenseActor) {
  await assertKeyAccess(keyId, actor);
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return db.select().from(deviceBindings).where(eq(deviceBindings.licenseKeyId, keyId)).orderBy(desc(deviceBindings.firstSeenAt));
}

export async function unbindDevice(bindingId: number, actor: LicenseActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const binding = (await db.select().from(deviceBindings).where(eq(deviceBindings.id, bindingId)).limit(1))[0];
  if (!binding) throw new Error("Device binding not found");
  const { row } = await assertKeyAccess(binding.licenseKeyId, actor);
  await db.transaction(async tx => {
    await tx.delete(deviceBindings).where(eq(deviceBindings.id, bindingId));
    const nextBinding = (await tx.select({ deviceHash: deviceBindings.deviceHash }).from(deviceBindings).where(eq(deviceBindings.licenseKeyId, binding.licenseKeyId)).limit(1))[0];
    await tx.update(licenses).set({
      boundDeviceId: nextBinding?.deviceHash ?? null,
      status: nextBinding ? row.status : "unused",
    }).where(eq(licenses.id, binding.licenseKeyId));
  });
  await recordAudit(actor.id, "device_unbound", "binding", bindingId, undefined, `licenseId=${binding.licenseKeyId}`);
  return { success: true };
}

export function generateOperatorUid(role: string): string {
  const rolePrefix = role === "super_owner" ? "SUP" : role === "owner" ? "OWN" : "ADM";
  const rand = crypto.randomBytes(3).toString("hex").toUpperCase();
  return `UID-${rolePrefix}-${rand}`;
}

export function getOrDeriveOperatorUid(user: { operatorUid?: string | null; role: string; openId?: string | null; id: number }): string {
  if (user.operatorUid && user.operatorUid.trim().length > 0) {
    return user.operatorUid;
  }
  const rolePrefix = user.role === "super_owner" ? "SUP" : user.role === "owner" ? "OWN" : "ADM";
  const seed = user.openId || `user-${user.id}`;
  const hash = crypto.createHash("sha256").update(seed).digest("hex").slice(0, 6).toUpperCase();
  return `UID-${rolePrefix}-${hash}`;
}

export async function listUsers() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const now = new Date();
  const rows = await db.select({
    id: users.id,
    openId: users.openId,
    username: users.username,
    name: users.name,
    email: users.email,
    role: users.role,
    accessStatus: users.accessStatus,
    accessExpiresAt: users.accessExpiresAt,
    lastSignedIn: users.lastSignedIn,
    createdAt: users.createdAt,
    operatorUid: users.operatorUid,
  }).from(users).orderBy(desc(users.lastSignedIn));

  return rows.map(u => {
    const isExpired = Boolean(u.accessExpiresAt && u.accessExpiresAt.getTime() <= now.getTime());
    const isRevoked = u.accessStatus !== "active";
    const isUidActive = !isExpired && !isRevoked;
    return {
      ...u,
      operatorUid: getOrDeriveOperatorUid(u),
      isUidActive,
      isExpired,
      isRevoked,
    };
  });
}

export async function changeUsername(userId: number, requestedUsername: string) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const username = normalizeUsername(requestedUsername);
  const current = (await db.select({ username: users.username, usernameChangedAt: users.usernameChangedAt }).from(users).where(eq(users.id, userId)).limit(1))[0];
  if (!current) throw new Error("User not found");
  if (current.username === username) {
    const availability = getUsernameChangeAvailability(current.usernameChangedAt);
    return { success: true, username, nextAllowedAt: availability.nextAllowedAt };
  }
  const availability = getUsernameChangeAvailability(current.usernameChangedAt);
  if (!availability.available) throw new Error(`Username can be changed again after ${availability.nextAllowedAt?.toISOString()}`);
  const existing = (await db.select({ id: users.id }).from(users).where(eq(users.username, username)).limit(1))[0];
  if (existing && existing.id !== userId) throw new Error("That username is already in use");
  const changedAt = new Date();
  await db.update(users).set({ username, usernameChangedAt: changedAt }).where(eq(users.id, userId));
  await recordAudit(userId, current.username ? "username_changed" : "username_set", "user", userId, undefined, `username=${username}`);
  return { success: true, username, nextAllowedAt: new Date(changedAt.getTime() + USERNAME_CHANGE_COOLDOWN_MS) };
}

export const setUsername = changeUsername;

export function isUserClearable(user: { accessStatus: "pending" | "active" | "revoked"; accessExpiresAt: Date | null }, now = new Date()) {
  return user.accessStatus === "revoked" || Boolean(user.accessExpiresAt && user.accessExpiresAt.getTime() <= now.getTime());
}

export async function setAdminAccess(id: number, accessStatus: "active" | "revoked", actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  await db.update(users).set({ role: "admin", accessStatus }).where(eq(users.id, id));
  await recordAudit(actorUserId, accessStatus === "active" ? "user_access_restored" : "user_access_revoked", "user", id, undefined, `targetUserId=${id}`);
  return { success: true };
}

export function canRemoveOwnerAccount(actor: { id: number; role: "super_owner" | "owner" | "admin" }, target: { id: number; role: "super_owner" | "owner" | "admin" }) {
  return actor.role === "super_owner" && target.role === "owner" && actor.id !== target.id;
}

export async function promoteConfiguredSuperOwner(openId: string) {
  if (openId !== ENV.ownerOpenId) return;
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  await db.transaction(async tx => {
    await tx.update(users).set({ role: "owner" }).where(eq(users.role, "super_owner"));
    await tx.update(users).set({ role: "super_owner", accessStatus: "active" }).where(eq(users.openId, ENV.ownerOpenId));
  });
}

export async function removeOwnerAccess(id: number, actor: { id: number; role: "super_owner" | "owner" | "admin" }) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const target = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
  if (!target) throw new Error("User not found");
  if (!canRemoveOwnerAccount(actor, target)) throw new Error("Only the Super Owner can remove another Owner account");
  await db.update(users).set({ role: "admin", accessStatus: "revoked", accessExpiresAt: null }).where(eq(users.id, id));
  await recordAudit(actor.id, "owner_access_removed", "user", id, undefined, `targetUserId=${id};previousRole=owner`);
  return { success: true };
}

export async function deleteUser(id: number, actorUserId: number, actorOpenId: string, bypassStatusCheck = false) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const target = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
  if (!target) throw new Error("User not found");
  if (target.openId === actorOpenId) throw new Error("You cannot delete your own owner account");
  if (target.role === "super_owner" && target.openId === ENV.ownerOpenId) throw new Error("Cannot delete configured Super Owner");
  if (!bypassStatusCheck && !isUserClearable(target)) throw new Error("Only revoked or expired accounts can be cleared");
  await db.transaction(async tx => {
    // Capture the user's license IDs before detaching them so all dependent
    // Telegram presentation records can be removed in the same transaction.
    const ownedLicenses = await tx.select({ id: licenses.id }).from(licenses).where(eq(licenses.createdByUserId, id));
    const ownedLicenseIds = ownedLicenses.map(license => license.id);
    const linkedReferrals = await tx.select({ id: referrals.id }).from(referrals).where(or(eq(referrals.createdByUserId, id), eq(referrals.redeemedByUserId, id)));
    const linkedReferralIds = linkedReferrals.map(referral => referral.id);

    await tx.delete(telegramChannels).where(eq(telegramChannels.userId, id));
    await tx.delete(telegramAccountScopes).where(
      linkedReferralIds.length > 0
        ? or(eq(telegramAccountScopes.ownerUserId, id), eq(telegramAccountScopes.accountUserId, id), inArray(telegramAccountScopes.sourceReferralId, linkedReferralIds))
        : or(eq(telegramAccountScopes.ownerUserId, id), eq(telegramAccountScopes.accountUserId, id)),
    );
    await tx.delete(referrals).where(or(eq(referrals.createdByUserId, id), eq(referrals.redeemedByUserId, id)));
    await tx.delete(telegramKeyMappings).where(
      ownedLicenseIds.length > 0
        ? or(eq(telegramKeyMappings.accountUserId, id), inArray(telegramKeyMappings.licenseId, ownedLicenseIds))
        : eq(telegramKeyMappings.accountUserId, id),
    );
    if (ownedLicenseIds.length > 0) {
      await tx.delete(telegramTickets).where(inArray(telegramTickets.licenseId, ownedLicenseIds));
    }
    await tx.update(licenses).set({ createdByUserId: null }).where(eq(licenses.createdByUserId, id));
    await tx.delete(users).where(eq(users.id, id));
  });
  await recordAudit(actorUserId, "user_deleted", "user", id, undefined, `targetUserId=${id};openId=${target.openId}`);
  return { success: true };
}

export function evaluateCanonicalValidation(
  row: { status: CanonicalLicenseStatus; expiresAt: Date | null; boundDeviceId: string | null; maxDevices?: number },
  deviceHash: string,
  now = new Date(),
): ValidationResponse {
  if (row.status === "revoked") return validationResponse("invalid");
  if (row.status === "expired" || Boolean(row.expiresAt && row.expiresAt.getTime() <= now.getTime())) return validationResponse("expired");
  if (row.boundDeviceId && row.boundDeviceId !== deviceHash && (row.maxDevices ?? 1) <= 1) return validationResponse("device_mismatch");
  return validationResponse("valid");
}

export function evaluateLicenseValidation(
  row: { status: CanonicalLicenseStatus; expiresAt: Date | null; boundDeviceId: string | null; maxDevices?: number } | null,
  deviceHash: string,
  now = new Date(),
): ValidationResponse {
  if (!row) return validationResponse("not_registered");
  return evaluateCanonicalValidation(row, deviceHash, now);
}

export function isDeviceLimitReached(boundDeviceCount: number, maxDevices: number) {
  return boundDeviceCount >= maxDevices;
}

export function isSafeReplacementBindingSource(
  row: { status: CanonicalLicenseStatus; expiresAt: Date | null },
  now = new Date(),
) {
  return row.status === "revoked" || row.status === "expired" || Boolean(row.expiresAt && row.expiresAt.getTime() <= now.getTime());
}

export function getActivationTransition(
  row: { activatedAt: Date | null; expiresAt: Date | null; durationMinutes: number | null },
  now = new Date(),
) {
  const activatesNow = !row.activatedAt && !row.expiresAt && row.durationMinutes != null;
  const activatedAt = activatesNow ? now : row.activatedAt;
  const expiresAt = activatesNow ? new Date(now.getTime() + Number(row.durationMinutes) * 60000) : row.expiresAt;
  return { activatesNow, activatedAt, expiresAt };
}

export async function validateCanonicalLicense(key: string, deviceId: string): Promise<ValidationResponse> {
  const db = await getDb();
  if (!db) return { success: false, status: "invalid", message: "Validation service is temporarily unavailable." };
  const normalizedKey = key.trim().toUpperCase();
  const deviceHash = hashDevice(deviceId);

  const result = await db.transaction(async tx => {
    const reject = (status: ValidationStatus) => ({ response: validationResponse(status), replacementSourceLicenseId: null as number | null });
    const row = (await tx.select().from(licenses).where(eq(licenses.keyValue, normalizedKey)).limit(1))[0];
    if (!row) return reject("not_registered");

    // Lock the parent row before evaluating expiry, counting bindings, or starting
    // a duration clock. This makes first activation exactly-once under concurrency.
    await tx.execute(sql`select ${licenses.id} from ${licenses} where ${licenses.id} = ${row.id} for update`);
    const lockedRow = (await tx.select().from(licenses).where(eq(licenses.id, row.id)).limit(1))[0];
    const now = new Date();
    const decision = evaluateLicenseValidation(lockedRow, deviceHash, now);
    if (!decision.success) {
      if (decision.status === "expired" && lockedRow.status !== "expired") await tx.update(licenses).set({ status: "expired" }).where(eq(licenses.id, lockedRow.id));
      return { response: decision, replacementSourceLicenseId: null };
    }

    // A device is intentionally unique only within one license. This permits one
    // physical device to use multiple distinct valid keys while preserving each
    // key's own max-device limit and anti-cloning decision.
    const existingBinding = (await tx.select().from(deviceBindings).where(and(
      eq(deviceBindings.licenseKeyId, lockedRow.id),
      eq(deviceBindings.deviceHash, deviceHash),
    )).limit(1))[0];

    if (!existingBinding) {
      const bindingCount = Number((await tx.select({ value: sql<number>`count(*)` }).from(deviceBindings).where(eq(deviceBindings.licenseKeyId, lockedRow.id)))[0]?.value ?? 0);
      if (isDeviceLimitReached(bindingCount, lockedRow.maxDevices)) return reject("device_max_reached");
      await tx.insert(deviceBindings).values({ licenseKeyId: lockedRow.id, deviceHash });
    }

    const activation = getActivationTransition(lockedRow);
    if (!lockedRow.boundDeviceId) {
      await tx.update(licenses).set({
        boundDeviceId: deviceHash,
        status: "active",
        ...(activation.activatesNow ? { activatedAt: activation.activatedAt, expiresAt: activation.expiresAt } : {}),
      }).where(eq(licenses.id, lockedRow.id));
    } else {
      await tx.update(licenses).set({
        status: "active",
        ...(activation.activatesNow ? { activatedAt: activation.activatedAt, expiresAt: activation.expiresAt } : {}),
      }).where(eq(licenses.id, lockedRow.id));
      if (existingBinding) await tx.update(deviceBindings).set({ lastSeenAt: new Date() }).where(eq(deviceBindings.id, existingBinding.id));
    }
    return {
      response: { ...decision, ...(activation.expiresAt ? { expiresAt: activation.expiresAt.toISOString() } : {}) },
      replacementSourceLicenseId: null as number | null,
    };
  });

  if (result.response.success) {
    await recordAudit(null, "device_bound", "license", undefined, normalizedKey, "server-authoritative validation accepted");
  }
  return result.response;
}

export async function validateLicense(key: string, deviceId: string) {
  const result = await validateCanonicalLicense(key, deviceId);
  if (result.success) {
    const db = await getDb();
    const row = db ? (await db.select({ expiresAt: licenses.expiresAt }).from(licenses).where(eq(licenses.keyValue, key.trim().toUpperCase())).limit(1))[0] : undefined;
    return { ok: true as const, expiresAt: row?.expiresAt?.toISOString() };
  }
  const errors: Record<Exclude<ValidationStatus, "valid">, (typeof API_ERROR_CODES)[number]> = {
    not_registered: "invalid_key",
    invalid: "key_banned",
    expired: "key_expired",
    device_mismatch: "device_already_bound",
    device_max_reached: "device_limit_reached",
  };
  return { ok: false as const, error: errors[result.status as Exclude<ValidationStatus, "valid">] };
}
