import { boolean, int, mysqlEnum, mysqlTable, text, timestamp, uniqueIndex, varchar } from "drizzle-orm/mysql-core";

export const users = mysqlTable("users", {
  id: int("id").autoincrement().primaryKey(),
  openId: varchar("openId", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  username: varchar("username", { length: 32 }).unique(),
  usernameChangedAt: timestamp("usernameChangedAt"),
  loginMethod: varchar("loginMethod", { length: 64 }),
  passwordHash: varchar("passwordHash", { length: 255 }),
  role: mysqlEnum("role", ["super_owner", "owner", "admin"]).default("admin").notNull(),
  accessStatus: mysqlEnum("accessStatus", ["pending", "active", "revoked"]).default("pending").notNull(),
  accessExpiresAt: timestamp("accessExpiresAt"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  lastSignedIn: timestamp("lastSignedIn").defaultNow().notNull(),
  operatorUid: varchar("operatorUid", { length: 32 }),
});

/**
 * Canonical server-authoritative license registry.
 * `boundDeviceId` stores a keyed SHA-256 hash, never the raw client device ID.
 */
export const licenses = mysqlTable("licenses", {
  id: int("id").autoincrement().primaryKey(),
  keyValue: varchar("license_key", { length: 128 }).notNull().unique(),
  status: mysqlEnum("status", ["active", "expired", "revoked", "unused"]).default("unused").notNull(),
  // Existing keys retain their stored expiry. Newly created activation-duration keys
  // receive an expiry only after their first successful device binding.
  expiresAt: timestamp("expires_at"),
  activatedAt: timestamp("activated_at"),
  durationMinutes: int("duration_minutes"),
  maxDevices: int("max_devices").notNull().default(1),
  boundDeviceId: varchar("bound_device_id", { length: 128 }),
  createdByUserId: int("created_by_user_id"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

/**
 * Legacy registry retained only for a non-destructive, one-time data migration.
 * Application code reads and writes exclusively through `licenses`.
 */
export const legacyLicenseKeys = mysqlTable("license_keys", {
  id: int("id").autoincrement().primaryKey(),
  keyValue: varchar("keyValue", { length: 128 }).notNull().unique(),
  status: mysqlEnum("status", ["active", "banned"]).default("active").notNull(),
  expiresAt: timestamp("expiresAt").notNull(),
  maxDevices: int("maxDevices").notNull().default(1),
  createdByUserId: int("createdByUserId"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export const referrals = mysqlTable("referrals", {
  id: int("id").autoincrement().primaryKey(),
  code: varchar("code", { length: 96 }).notNull().unique(),
  role: mysqlEnum("role", ["owner", "admin"]).notNull(),
  createdByUserId: int("createdByUserId").notNull(),
  redeemedByUserId: int("redeemedByUserId"),
  status: mysqlEnum("status", ["active", "redeemed", "revoked"]).default("active").notNull(),
  expiresAt: timestamp("expiresAt").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  redeemedAt: timestamp("redeemedAt"),
});

export const auditLogs = mysqlTable("audit_logs", {
  id: int("id").autoincrement().primaryKey(),
  actorUserId: int("actorUserId"),
  action: varchar("action", { length: 64 }).notNull(),
  entityType: varchar("entityType", { length: 32 }).notNull(),
  entityId: int("entityId"),
  keyPreview: varchar("keyPreview", { length: 64 }),
  details: text("details"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

/**
 * Server-authoritative list of per-license hashed device bindings. `boundDeviceId` remains
 * the first bound device for backwards compatibility; this table enforces maxDevices.
 */
export const deviceBindings = mysqlTable("device_bindings", {
  id: int("id").autoincrement().primaryKey(),
  licenseKeyId: int("licenseKeyId").notNull(),
  deviceHash: varchar("deviceHash", { length: 128 }).notNull(),
  firstSeenAt: timestamp("firstSeenAt").defaultNow().notNull(),
  lastSeenAt: timestamp("lastSeenAt").defaultNow().onUpdateNow().notNull(),
}, table => [
  uniqueIndex("device_bindings_license_device_hash_unique").on(table.licenseKeyId, table.deviceHash),
]);

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;
export type License = typeof licenses.$inferSelect;
export type DeviceBinding = typeof deviceBindings.$inferSelect;

/**
 * Singleton, presentation-only announcement controlled by the Super Owner.
 * `id = 1` is the only supported row; no license decision reads this table.
 */
export const systemAnnouncements = mysqlTable("system_announcements", {
  id: int("id").primaryKey(),
  version: int("version").notNull().default(1),
  enabled: boolean("enabled").notNull().default(false),
  title: varchar("title", { length: 80 }).notNull().default("SYSTEM ANNOUNCEMENT"),
  message: varchar("message", { length: 300 }).notNull().default(""),
  startAt: timestamp("start_at"),
  endAt: timestamp("end_at"),
  displayMode: mysqlEnum("display_mode", ["every_login", "once_per_day"]).notNull().default("every_login"),
  textSize: mysqlEnum("text_size", ["small", "normal", "large", "festival_large"]).notNull().default("normal"),
  updatedByUserId: int("updated_by_user_id"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export type SystemAnnouncement = typeof systemAnnouncements.$inferSelect;

/**
 * Singleton operational hold controlled only by the existing Super Owner gate.
 * This state is intentionally separate from System Announcement and never participates
 * in license validation or device-binding decisions.
 */
export const serverMaintenance = mysqlTable("server_maintenance", {
  id: int("id").primaryKey(),
  version: int("version").notNull().default(1),
  enabled: boolean("enabled").notNull().default(false),
  title: varchar("title", { length: 80 }).notNull().default("SERVER MAINTENANCE"),
  message: varchar("message", { length: 300 }).notNull().default(""),
  startAt: timestamp("start_at"),
  endAt: timestamp("end_at"),
  updatedByUserId: int("updated_by_user_id"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export type ServerMaintenance = typeof serverMaintenance.$inferSelect;

/**
 * Fully isolated, removable Telegram extension tables.
 * These tables are presentation/navigation metadata only and are never read by license validation.
 */
export const telegramSettings = mysqlTable("telegram_settings", {
  id: int("id").primaryKey(),
  enabled: boolean("enabled").notNull().default(false),
  updatedByUserId: int("updated_by_user_id"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export const telegramChannels = mysqlTable("telegram_channels", {
  id: int("id").autoincrement().primaryKey(),
  userId: int("user_id").notNull().unique(),
  channelUrl: varchar("channel_url", { length: 256 }).notNull(),
  enabled: boolean("enabled").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export const telegramAccountScopes = mysqlTable("telegram_account_scopes", {
  id: int("id").autoincrement().primaryKey(),
  ownerUserId: int("owner_user_id").notNull(),
  accountUserId: int("account_user_id").notNull().unique(),
  sourceReferralId: int("source_referral_id"),
  status: mysqlEnum("status", ["active", "review"]).notNull().default("active"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export const telegramKeyMappings = mysqlTable("telegram_key_mappings", {
  id: int("id").autoincrement().primaryKey(),
  licenseId: int("license_id").notNull().unique(),
  accountUserId: int("account_user_id").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow().notNull(),
});

export const telegramTickets = mysqlTable("telegram_tickets", {
  id: int("id").autoincrement().primaryKey(),
  tokenHash: varchar("token_hash", { length: 128 }).notNull().unique(),
  licenseId: int("license_id").notNull(),
  deviceHash: varchar("device_hash", { length: 128 }).notNull(),
  expiresAt: timestamp("expires_at").notNull(),
  redeemedAt: timestamp("redeemed_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export type TelegramChannel = typeof telegramChannels.$inferSelect;
export type TelegramAccountScope = typeof telegramAccountScopes.$inferSelect;
export type TelegramKeyMapping = typeof telegramKeyMappings.$inferSelect;
export type TelegramSettings = typeof telegramSettings.$inferSelect;
export type TelegramTicket = typeof telegramTickets.$inferSelect;
