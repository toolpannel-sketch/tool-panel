import { TRPCError } from "@trpc/server";
import { z } from "zod";
import { eq } from "drizzle-orm";
import crypto from "node:crypto";
import { router, publicProcedure, protectedProcedure, adminProcedure, ownerProcedure, superOwnerProcedure } from "./_core/trpc";
import { ENV } from "./_core/env";
import { COOKIE_NAME, ONE_YEAR_MS } from "@shared/const";
import { getSessionCookieOptions } from "./_core/cookies";
import { sdk } from "./_core/sdk";
import { systemRouter } from "./_core/systemRouter";
import { getDb } from "./db";
import { users, referrals, auditLogs } from "../drizzle/schema";
import { changeUsername, createReferral, deleteAllKeys, deleteAllReferrals, deleteKey, deleteReferral, deleteUser, durationToMinutes, generateKey, getActiveSystemAnnouncement, getAllKeysOverview, getApiSharedSecret, getBindings, getReferralOverview, getSeasonControlCounts, getStats, getSystemAnnouncement, getUsernameChangeAvailability, LICENSE_DURATION_UNITS, listAuditLogs, listKeys, listReferrals, listUsers, MAX_LICENSE_DEVICES, promoteConfiguredSuperOwner, redeemReferral, removeOwnerAccess, resetLicenseKey, revokeReferral, setAdminAccess, setKeyStatus, setUsername, unbindDevice, updateLicense, updateSystemAnnouncement } from "./license";
import { getServerMaintenance, updateServerMaintenance } from "./maintenance";
import { createTelegramScope, getTelegramChannel, getTelegramSettings, getTelegramSetupState, listTelegramChannels, listTelegramScopeCandidates, mapTelegramLicense, saveTelegramChannel, updateTelegramSettings } from "./telegram";

export const maximumDevicesInput = z.number().int().min(1).max(MAX_LICENSE_DEVICES);

export const appRouter = router({
  system: systemRouter,
  auth: router({
    me: publicProcedure.query(opts => opts.ctx.user),
    logout: publicProcedure.mutation(({ ctx }) => {
      const cookieOptions = getSessionCookieOptions(ctx.req);
      ctx.res.clearCookie(COOKIE_NAME, { ...cookieOptions, maxAge: -1 });
      return { success: true } as const;
    }),
    login: publicProcedure
      .input(z.object({ username: z.string().min(1), password: z.string().min(1) }))
      .mutation(async ({ input, ctx }) => {
        const db = await getDb();
        if (!db) throw new TRPCError({ code: "INTERNAL_SERVER_ERROR", message: "Database not connected" });
        const [user] = await db.select().from(users).where(eq(users.username, input.username)).limit(1);
        if (!user || !user.passwordHash) {
          throw new TRPCError({ code: "UNAUTHORIZED", message: "Invalid username or password" });
        }
        const [salt, storedHash] = user.passwordHash.split(":");
        if (!salt || !storedHash) {
          throw new TRPCError({ code: "UNAUTHORIZED", message: "Invalid credentials configuration" });
        }
        const testHash = crypto.scryptSync(input.password, salt, 64).toString("hex");
        if (testHash !== storedHash) {
          throw new TRPCError({ code: "UNAUTHORIZED", message: "Invalid username or password" });
        }
        const sessionToken = await sdk.createSessionToken(user.openId, {
          name: user.name || user.username || "",
          expiresInMs: ONE_YEAR_MS,
        });
        const cookieOptions = getSessionCookieOptions(ctx.req);
        ctx.res.cookie(COOKIE_NAME, sessionToken, { ...cookieOptions, maxAge: ONE_YEAR_MS });
        return { success: true, user: { id: user.id, username: user.username, role: user.role }, token: sessionToken };
      }),
    register: publicProcedure
      .input(z.object({
        username: z.string().trim().min(3, "Username must be at least 3 characters").max(32),
        password: z.string().min(4, "Password must be at least 4 characters"),
        referralCode: z.string().trim().min(4, "Referral code required"),
      }))
      .mutation(async ({ input, ctx }) => {
        const db = await getDb();
        if (!db) throw new TRPCError({ code: "INTERNAL_SERVER_ERROR", message: "Database not connected" });

        const [existing] = await db.select().from(users).where(eq(users.username, input.username)).limit(1);
        if (existing) {
          throw new TRPCError({ code: "CONFLICT", message: "Username is already taken" });
        }

        const [referral] = await db.select().from(referrals).where(eq(referrals.code, input.referralCode)).limit(1);
        if (!referral) {
          throw new TRPCError({ code: "BAD_REQUEST", message: "Invalid referral code" });
        }
        if (referral.status !== "active") {
          throw new TRPCError({ code: "BAD_REQUEST", message: "Referral code has already been redeemed or revoked" });
        }
        if (new Date() > referral.expiresAt) {
          throw new TRPCError({ code: "BAD_REQUEST", message: "Referral code has expired" });
        }

        const salt = crypto.randomBytes(16).toString("hex");
        const hash = crypto.scryptSync(input.password, salt, 64).toString("hex");
        const passwordHash = `${salt}:${hash}`;
        const openId = `user-${crypto.randomUUID()}`;

        const now = new Date();
        const [insertResult] = await db.insert(users).values({
          openId,
          name: input.username,
          username: input.username,
          role: referral.role,
          accessStatus: "active",
          accessExpiresAt: referral.expiresAt,
          passwordHash,
          lastSignedIn: now,
          createdAt: now,
        });

        const newUserId = insertResult.insertId;

        await db.update(referrals).set({
          status: "redeemed",
          redeemedByUserId: newUserId,
          redeemedAt: now,
        }).where(eq(referrals.id, referral.id));

        await db.insert(auditLogs).values({
          actorUserId: newUserId,
          action: "redeem_referral",
          entityType: "user",
          entityId: newUserId,
          details: `Account registered via referral code ${input.referralCode} with role ${referral.role}`,
          createdAt: now,
        });

        const sessionToken = await sdk.createSessionToken(openId, {
          name: input.username,
          expiresInMs: ONE_YEAR_MS,
        });
        const cookieOptions = getSessionCookieOptions(ctx.req);
        ctx.res.cookie(COOKIE_NAME, sessionToken, { ...cookieOptions, maxAge: ONE_YEAR_MS });

        return { success: true, user: { id: newUserId, username: input.username, role: referral.role }, token: sessionToken };
      }),
  }),
  dashboard: router({
    identity: protectedProcedure.query(async ({ ctx }) => {
      await promoteConfiguredSuperOwner(ctx.user.openId);
      const isSuperOwner = ctx.user.openId === ENV.ownerOpenId || ctx.user.role === "super_owner";
      const usernameChange = getUsernameChangeAvailability(ctx.user.usernameChangedAt, new Date(), isSuperOwner);
      return { role: isSuperOwner ? "super_owner" as const : ctx.user.role, accessStatus: ctx.user.accessStatus, username: ctx.user.username, email: ctx.user.email, usernameChangedAt: ctx.user.usernameChangedAt, usernameChangeAvailable: usernameChange.available, usernameChangeAvailableAt: usernameChange.nextAllowedAt };
    }),
    overview: ownerProcedure.query(async ({ ctx }) => getStats({ id: ctx.user.id, isOwner: true })),
    keys: adminProcedure.query(async ({ ctx }) => listKeys({ id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    homeKeys: adminProcedure.query(async ({ ctx }) => listKeys({ id: ctx.user.id, isOwner: false })),
    users: ownerProcedure.query(async () => listUsers()),
    bindings: adminProcedure.input(z.object({ keyId: z.number().int().positive() })).query(async ({ input, ctx }) => getBindings(input.keyId, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    apiConfig: ownerProcedure.query(() => ({ sharedSecret: getApiSharedSecret() })),
    audit: ownerProcedure.query(() => listAuditLogs()),
  }),
  license: router({
    create: adminProcedure.input(z.object({
      durationAmount: z.number().int().min(1).max(5256000),
      durationUnit: z.enum(LICENSE_DURATION_UNITS),
      maxDevices: maximumDevicesInput,
      customPrefix: z.string().max(24).optional(),
      useExactCustomKey: z.boolean().optional(),
    }).superRefine((input, ctx) => {
      if (durationToMinutes(input.durationAmount, input.durationUnit) > 5256000) ctx.addIssue({ code: "custom", path: ["durationAmount"], message: "License duration cannot exceed 10 years" });
    })).mutation(({ input, ctx }) => {
      const durationMinutes = durationToMinutes(input.durationAmount, input.durationUnit);
      return generateKey(durationMinutes, ctx.user.id, input.customPrefix, input.maxDevices, ctx.user.username, input.useExactCustomKey);
    }),
    setStatus: adminProcedure.input(z.object({ id: z.number().int().positive(), status: z.enum(["active", "expired", "revoked", "unused"]) })).mutation(({ input, ctx }) => setKeyStatus(input.id, input.status, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    update: adminProcedure.input(z.object({ id: z.number().int().positive(), status: z.enum(["active", "expired", "revoked", "unused"]), expiresAt: z.coerce.date().optional(), maxDevices: maximumDevicesInput })).mutation(({ input, ctx }) => updateLicense(input.id, { status: input.status, expiresAt: input.expiresAt, maxDevices: input.maxDevices }, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    delete: adminProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => deleteKey(input.id, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    reset: adminProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => resetLicenseKey(input.id, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
    unbind: adminProcedure.input(z.object({ bindingId: z.number().int().positive() })).mutation(({ input, ctx }) => unbindDevice(input.bindingId, { id: ctx.user.id, isOwner: ctx.user.role === "super_owner" || ctx.user.role === "owner" || ctx.user.openId === ENV.ownerOpenId })),
  }),
  referrals: router({
    list: ownerProcedure.query(({ ctx }) => listReferrals({ id: ctx.user.id, role: ctx.user.role })),
    create: ownerProcedure.input(z.object({
      role: z.enum(["admin", "owner"]),
      durationDays: z.number().int().min(1).max(3650),
    })).mutation(({ input, ctx }) => {
      if (input.role === "owner" && ctx.user.role !== "super_owner") {
        throw new TRPCError({ code: "FORBIDDEN", message: "Only Super Owner can create Owner referrals" });
      }
      return createReferral(input.role, input.durationDays, ctx.user.id);
    }),
    revoke: ownerProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => revokeReferral(input.id, { id: ctx.user.id, role: ctx.user.role })),
    delete: ownerProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => deleteReferral(input.id, { id: ctx.user.id, role: ctx.user.role })),
    redeem: protectedProcedure.input(z.object({ code: z.string().min(4).max(96) })).mutation(({ input, ctx }) => redeemReferral(input.code, ctx.user.id)),
  }),
  users: router({
    setUsername: protectedProcedure.input(z.object({ username: z.string().trim().min(3).max(32).regex(/^[A-Za-z0-9](?:[A-Za-z0-9 _.-]{1,30}[A-Za-z0-9])?$/, "Use 3–32 letters, numbers, spaces, dots, hyphens, or underscores") })).mutation(({ input, ctx }) => {
      const isSuperOwner = ctx.user.openId === ENV.ownerOpenId || ctx.user.role === "super_owner";
      return setUsername(ctx.user.id, input.username, isSuperOwner);
    }),
    changeUsername: protectedProcedure.input(z.object({ username: z.string().trim().min(3).max(32).regex(/^[A-Za-z0-9](?:[A-Za-z0-9 _.-]{1,30}[A-Za-z0-9])?$/, "Use 3–32 letters, numbers, spaces, dots, hyphens, or underscores") })).mutation(({ input, ctx }) => {
      const isSuperOwner = ctx.user.openId === ENV.ownerOpenId || ctx.user.role === "super_owner";
      return changeUsername(ctx.user.id, input.username, isSuperOwner);
    }),
    setRole: ownerProcedure.input(z.object({ id: z.number().int().positive(), accessStatus: z.enum(["active", "revoked"]) })).mutation(async ({ input, ctx }) => {
      const db = await getDb();
      if (!db) throw new TRPCError({ code: "INTERNAL_SERVER_ERROR", message: "Database unavailable" });
      const target = (await db.select().from(users).where(eq(users.id, input.id)).limit(1))[0];
      if (!target) throw new TRPCError({ code: "NOT_FOUND", message: "User not found" });
      if (target.openId === ctx.user.openId) throw new TRPCError({ code: "BAD_REQUEST", message: "Owner role cannot be changed" });
      return setAdminAccess(input.id, input.accessStatus, ctx.user.id);
    }),
    delete: ownerProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => deleteUser(input.id, ctx.user.id, ctx.user.openId)),
    removeOwner: superOwnerProcedure.input(z.object({ id: z.number().int().positive() })).mutation(({ input, ctx }) => removeOwnerAccess(input.id, { id: ctx.user.id, role: "super_owner" })),
  }),
  telegram: router({
    settings: protectedProcedure.query(() => getTelegramSettings()),
    myChannel: protectedProcedure.query(({ ctx }) => getTelegramChannel(ctx.user.id)),
    setupState: protectedProcedure.query(({ ctx }) => getTelegramSetupState(ctx.user.id)),
    saveChannel: protectedProcedure.input(z.object({ userId: z.number().int().positive().optional(), channelUrl: z.string().max(256), enabled: z.boolean().default(true) })).mutation(({ input, ctx }) => saveTelegramChannel({ userId: input.userId ?? ctx.user.id, channelUrl: input.channelUrl, enabled: input.enabled }, { id: ctx.user.id, role: ctx.user.role })),
    channels: ownerProcedure.query(({ ctx }) => listTelegramChannels({ id: ctx.user.id, role: ctx.user.role })),
    updateSettings: superOwnerProcedure.input(z.object({ enabled: z.boolean() })).mutation(({ input, ctx }) => updateTelegramSettings(input, ctx.user.id)),
    scopeCandidates: superOwnerProcedure.query(() => listTelegramScopeCandidates()),
    setScope: superOwnerProcedure.input(z.object({ accountUserId: z.number().int().positive(), ownerUserId: z.number().int().positive(), sourceReferralId: z.number().int().positive().nullable().optional(), status: z.enum(["active", "review"]) })).mutation(({ input, ctx }) => createTelegramScope(input, { id: ctx.user.id, role: "super_owner" })),
    mapLicense: ownerProcedure.input(z.object({ licenseId: z.number().int().positive(), accountUserId: z.number().int().positive() })).mutation(({ input, ctx }) => mapTelegramLicense(input, { id: ctx.user.id, role: ctx.user.role })),
  }),
  superOwner: router({
    announcement: superOwnerProcedure.query(() => getSystemAnnouncement()),
    updateAnnouncement: superOwnerProcedure.input(z.object({
      enabled: z.boolean(),
      title: z.string().max(80),
      message: z.string().max(300),
      startAt: z.coerce.date().nullable(),
      endAt: z.coerce.date().nullable(),
      displayMode: z.enum(["every_login", "once_per_day"]),
      textSize: z.enum(["small", "normal", "large", "festival_large"]),
    })).mutation(({ input, ctx }) => updateSystemAnnouncement(input, ctx.user.id)),
    maintenance: superOwnerProcedure.query(() => getServerMaintenance()),
    updateMaintenance: superOwnerProcedure.input(z.object({
      enabled: z.boolean(),
      title: z.string().max(80),
      message: z.string().max(300),
      startAt: z.coerce.date().nullable(),
      endAt: z.coerce.date().nullable(),
    })).mutation(({ input, ctx }) => updateServerMaintenance(input, ctx.user.id)),
    seasonCounts: superOwnerProcedure.query(() => getSeasonControlCounts()),
    deleteAllKeys: superOwnerProcedure.mutation(({ ctx }) => deleteAllKeys(ctx.user.id)),
    deleteAllReferrals: superOwnerProcedure.mutation(({ ctx }) => deleteAllReferrals(ctx.user.id)),
    referralOverview: superOwnerProcedure.query(() => getReferralOverview()),
    allKeysOverview: superOwnerProcedure.query(() => getAllKeysOverview()),
    operators: superOwnerProcedure.query(() => listUsers()),
  }),
});

export type AppRouter = typeof appRouter;
