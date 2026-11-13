import crypto from "node:crypto";
import { and, desc, eq, gt, isNull, or } from "drizzle-orm";
import {
  licenses,
  referrals,
  telegramAccountScopes,
  telegramChannels,
  telegramKeyMappings,
  telegramSettings,
  telegramTickets,
  deviceBindings,
  users,
} from "../drizzle/schema";
import { getDb } from "./db";
import { hashDevice } from "./license";

type TelegramActor = { id: number; role: "super_owner" | "owner" | "admin" };

export const TELEGRAM_TICKET_TTL_MS = 60_000;
export const TELEGRAM_CHANNEL_MAX_LENGTH = 256;

function extensionEnabledValue(row: { enabled: boolean } | undefined) {
  return Boolean(row?.enabled);
}

async function getSettings() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return (await db.select().from(telegramSettings).where(eq(telegramSettings.id, 1)).limit(1))[0] ?? null;
}

export async function isTelegramEnabled() {
  return extensionEnabledValue(await getSettings());
}

export function normalizeTelegramChannelUrl(value: string) {
  const raw = value.trim();
  if (raw.length === 0 || raw.length > TELEGRAM_CHANNEL_MAX_LENGTH) throw new Error("Telegram channel URL is required and must be 256 characters or fewer");
  let url: URL;
  try {
    url = new URL(raw);
  } catch {
    throw new Error("Enter a valid Telegram HTTPS channel URL");
  }
  if (url.protocol !== "https:" || !["t.me", "telegram.me"].includes(url.hostname.toLowerCase())) {
    throw new Error("Only HTTPS Telegram channel URLs are allowed");
  }
  if (url.search || url.hash) {
    throw new Error("Telegram channel URL must not contain a query or fragment");
  }
  const privateInvitePath = /^\/(?:\+([A-Za-z0-9_-]+)|joinchat\/([A-Za-z0-9_-]+))$/i;
  if (privateInvitePath.test(url.pathname)) {
    return raw;
  }
  if (url.pathname.startsWith("/+") || /^\/joinchat(?:\/|$)/i.test(url.pathname)) {
    throw new Error("Telegram private invite link must contain a valid invite hash");
  }
  if (!/^\/[A-Za-z0-9_][A-Za-z0-9_/-]*$/.test(url.pathname)) {
    throw new Error("Telegram channel URL must contain a supported public or private invite path");
  }
  return `https://${url.hostname.toLowerCase()}${url.pathname.replace(/\/+$/, "")}`;
}

async function getActor(actorId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const user = (await db.select({ id: users.id, role: users.role }).from(users).where(eq(users.id, actorId)).limit(1))[0];
  if (!user) throw new Error("User not found");
  return user;
}

async function canManageAccount(actor: TelegramActor, targetUserId: number) {
  if (actor.role === "super_owner" || actor.id === targetUserId) return true;
  if (actor.role !== "owner") return false;
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const referral = (await db.select({ id: referrals.id }).from(referrals).where(and(eq(referrals.createdByUserId, actor.id), eq(referrals.redeemedByUserId, targetUserId), eq(referrals.role, "admin"), eq(referrals.status, "redeemed"))).limit(1))[0];
  return Boolean(referral);
}

export async function updateTelegramSettings(input: { enabled: boolean }, actorUserId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const current = await getSettings();
  if (current) await db.update(telegramSettings).set({ enabled: input.enabled, updatedByUserId: actorUserId }).where(eq(telegramSettings.id, 1));
  else await db.insert(telegramSettings).values({ id: 1, enabled: input.enabled, updatedByUserId: actorUserId });
  return getSettings();
}

export async function getTelegramSettings() {
  return getSettings();
}

export async function getTelegramChannel(userId: number) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return (await db.select().from(telegramChannels).where(eq(telegramChannels.userId, userId)).limit(1))[0] ?? null;
}

export function getTelegramSetupStateForActor(role: TelegramActor["role"], channel?: { enabled?: boolean | null; channelUrl?: string | null } | null) {
  const eligible = role === "super_owner" || role === "owner" || role === "admin";
  const hasSavedChannel = Boolean(channel?.enabled && channel.channelUrl);
  return { eligible, hasSavedChannel, needsSetup: eligible && !hasSavedChannel };
}

export async function getTelegramSetupState(userId: number) {
  const actor = await getActor(userId);
  const channel = await getTelegramChannel(userId);
  return getTelegramSetupStateForActor(actor.role, channel);
}

export async function saveTelegramChannel(input: { userId: number; channelUrl: string; enabled: boolean }, actor: TelegramActor) {
  if (!(await canManageAccount(actor, input.userId))) throw new Error("You do not have Telegram permission for this account");
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const channelUrl = normalizeTelegramChannelUrl(input.channelUrl);
  const existing = await getTelegramChannel(input.userId);
  if (actor.role === "admin" && existing) throw new Error("Admins can create the first Telegram channel but cannot edit it later");
  if (existing) await db.update(telegramChannels).set({ channelUrl, enabled: input.enabled }).where(eq(telegramChannels.userId, input.userId));
  else await db.insert(telegramChannels).values({ userId: input.userId, channelUrl, enabled: input.enabled });
  return getTelegramChannel(input.userId);
}

export async function listTelegramChannels(actor: TelegramActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  if (actor.role === "super_owner") {
    return db.select({ channel: telegramChannels, username: users.username, role: users.role }).from(telegramChannels).leftJoin(users, eq(users.id, telegramChannels.userId)).orderBy(desc(telegramChannels.updatedAt));
  }
  if (actor.role === "admin") return (await getTelegramChannel(actor.id)) ? [{ channel: await getTelegramChannel(actor.id), username: null, role: "admin" as const }] : [];
  return db.select({ channel: telegramChannels, username: users.username, role: users.role }).from(telegramChannels).innerJoin(referrals, and(eq(referrals.redeemedByUserId, telegramChannels.userId), eq(referrals.createdByUserId, actor.id), eq(referrals.role, "admin"), eq(referrals.status, "redeemed"))).leftJoin(users, eq(users.id, telegramChannels.userId)).orderBy(desc(telegramChannels.updatedAt));
}

export async function createTelegramScope(input: { accountUserId: number; ownerUserId: number; sourceReferralId?: number | null; status: "active" | "review" }, actor: TelegramActor) {
  if (actor.role !== "super_owner") throw new Error("Only the Super Owner can confirm Telegram account scope");
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const account = (await db.select({ id: users.id, role: users.role }).from(users).where(eq(users.id, input.accountUserId)).limit(1))[0];
  const owner = (await db.select({ id: users.id, role: users.role }).from(users).where(eq(users.id, input.ownerUserId)).limit(1))[0];
  if (!account || !owner || account.role !== "admin" || !["owner", "super_owner"].includes(owner.role)) throw new Error("Telegram scope must connect an Admin to an Owner or Super Owner");
  const existing = (await db.select({ id: telegramAccountScopes.id }).from(telegramAccountScopes).where(eq(telegramAccountScopes.accountUserId, input.accountUserId)).limit(1))[0];
  if (existing) await db.update(telegramAccountScopes).set({ ownerUserId: input.ownerUserId, sourceReferralId: input.sourceReferralId ?? null, status: input.status }).where(eq(telegramAccountScopes.id, existing.id));
  else await db.insert(telegramAccountScopes).values({ ownerUserId: input.ownerUserId, accountUserId: input.accountUserId, sourceReferralId: input.sourceReferralId ?? null, status: input.status });
  return (await db.select().from(telegramAccountScopes).where(eq(telegramAccountScopes.accountUserId, input.accountUserId)).limit(1))[0];
}

export async function listTelegramScopeCandidates() {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  return db.select({ referralId: referrals.id, referralCreatorId: referrals.createdByUserId, accountUserId: referrals.redeemedByUserId, status: referrals.status, redeemedAt: referrals.redeemedAt, accountUsername: users.username }).from(referrals).leftJoin(users, eq(users.id, referrals.redeemedByUserId)).where(and(eq(referrals.role, "admin"), or(eq(referrals.status, "redeemed"), isNull(referrals.redeemedByUserId)))).orderBy(desc(referrals.redeemedAt));
}

export async function mapTelegramLicense(input: { licenseId: number; accountUserId: number }, actor: TelegramActor) {
  const db = await getDb();
  if (!db) throw new Error("Database unavailable");
  const license = (await db.select({ id: licenses.id, createdByUserId: licenses.createdByUserId }).from(licenses).where(eq(licenses.id, input.licenseId)).limit(1))[0];
  if (!license) throw new Error("License key not found");
  if (license.createdByUserId !== input.accountUserId && actor.role !== "super_owner") throw new Error("A Telegram mapping must use the key creator unless confirmed by the Super Owner");
  if (!(await canManageAccount(actor, input.accountUserId)) && actor.role !== "super_owner") throw new Error("You do not have Telegram permission for this account");
  const existing = (await db.select({ id: telegramKeyMappings.id }).from(telegramKeyMappings).where(eq(telegramKeyMappings.licenseId, input.licenseId)).limit(1))[0];
  if (existing) await db.update(telegramKeyMappings).set({ accountUserId: input.accountUserId }).where(eq(telegramKeyMappings.id, existing.id));
  else await db.insert(telegramKeyMappings).values({ licenseId: input.licenseId, accountUserId: input.accountUserId });
  return (await db.select().from(telegramKeyMappings).where(eq(telegramKeyMappings.licenseId, input.licenseId)).limit(1))[0];
}

function hashTicket(token: string) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

export async function issueTelegramTicket(key: string, deviceId: string) {
  if (!(await isTelegramEnabled())) return { enabled: false as const, ticket: null, resolution: "telegram_disabled" as const };
  const normalizedKey = key.trim().toUpperCase();
  const normalizedDevice = deviceId.trim();
  if (!normalizedKey || normalizedKey.length > 128 || !normalizedDevice || normalizedDevice.length > 256) return { enabled: true as const, ticket: null, resolution: "invalid_request" as const };
  const db = await getDb();
  if (!db) return { enabled: true as const, ticket: null, resolution: "service_unavailable" as const };
  const now = new Date();
  const license = (await db.select({ id: licenses.id, createdByUserId: licenses.createdByUserId }).from(licenses).where(and(eq(licenses.keyValue, normalizedKey), or(eq(licenses.status, "active"), eq(licenses.status, "unused")), or(isNull(licenses.expiresAt), gt(licenses.expiresAt, now)))).limit(1))[0];
  if (!license?.createdByUserId) return { enabled: true as const, ticket: null, resolution: "license_unavailable" as const };
  const binding = (await db.select({ id: deviceBindings.id }).from(deviceBindings).where(and(eq(deviceBindings.licenseKeyId, license.id), eq(deviceBindings.deviceHash, hashDevice(normalizedDevice)))).limit(1))[0];
  if (!binding) return { enabled: true as const, ticket: null, resolution: "device_not_bound" as const };
  const channel = await getTelegramChannel(license.createdByUserId);
  if (!channel) return { enabled: true as const, ticket: null, resolution: "creator_channel_missing" as const };
  if (!channel.enabled) return { enabled: true as const, ticket: null, resolution: "creator_channel_disabled" as const };
  const token = crypto.randomBytes(32).toString("base64url");
  await db.insert(telegramTickets).values({ tokenHash: hashTicket(token), licenseId: license.id, deviceHash: hashDevice(normalizedDevice), expiresAt: new Date(Date.now() + TELEGRAM_TICKET_TTL_MS) });
  return { enabled: true as const, ticket: token, resolution: "ticket_issued" as const };
}

export async function redeemTelegramTicket(token: string, deviceId: string) {
  if (!(await isTelegramEnabled())) return { enabled: false as const, channelUrl: null, resolution: "telegram_disabled" as const };
  const normalizedDevice = deviceId.trim();
  if (!/^[A-Za-z0-9_-]{20,128}$/.test(token) || !normalizedDevice || normalizedDevice.length > 256) return { enabled: true as const, channelUrl: null, resolution: "invalid_request" as const };
  const db = await getDb();
  if (!db) return { enabled: true as const, channelUrl: null, resolution: "service_unavailable" as const };
  const now = new Date();
  return db.transaction(async tx => {
    const ticket = (await tx.select().from(telegramTickets).where(and(eq(telegramTickets.tokenHash, hashTicket(token)), isNull(telegramTickets.redeemedAt), gt(telegramTickets.expiresAt, now))).limit(1))[0];
    if (!ticket || ticket.deviceHash !== hashDevice(normalizedDevice)) return { enabled: true as const, channelUrl: null, resolution: "ticket_unavailable" as const };
    const [redeemResult] = await tx.update(telegramTickets).set({ redeemedAt: now }).where(and(eq(telegramTickets.id, ticket.id), isNull(telegramTickets.redeemedAt), eq(telegramTickets.deviceHash, ticket.deviceHash)));
    if (redeemResult.affectedRows !== 1) return { enabled: true as const, channelUrl: null, resolution: "ticket_unavailable" as const };
    const license = (await tx.select({ createdByUserId: licenses.createdByUserId }).from(licenses).where(eq(licenses.id, ticket.licenseId)).limit(1))[0];
    if (!license?.createdByUserId) return { enabled: true as const, channelUrl: null, resolution: "creator_channel_missing" as const };
    const channel = (await tx.select({ channelUrl: telegramChannels.channelUrl, enabled: telegramChannels.enabled }).from(telegramChannels).where(eq(telegramChannels.userId, license.createdByUserId)).limit(1))[0];
    if (!channel) return { enabled: true as const, channelUrl: null, resolution: "creator_channel_missing" as const };
    if (!channel.enabled) return { enabled: true as const, channelUrl: null, resolution: "creator_channel_disabled" as const };
    return { enabled: true as const, channelUrl: channel.channelUrl, resolution: "channel_resolved" as const };
  });
}
