import type { Express, Request, Response, NextFunction } from "express";
import crypto from "crypto";
import { eq } from "drizzle-orm";
import { users, referrals, auditLogs, type User } from "../drizzle/schema";
import { getDb } from "./db";
import { sdk } from "./_core/sdk";
import { ONE_YEAR_MS } from "@shared/const";
import { ENV } from "./_core/env";
import {
  generateKey,
  listKeys,
  setKeyStatus,
  unbindDevice,
  getBindings,
  deleteKey,
  listReferrals,
  createReferral,
  revokeReferral,
  deleteReferral,
  deleteUser,
  getStats,
  getSeasonControlCounts,
  getReferralOverview,
  getAllKeysOverview,
  getAllReferralsDetailed,
  deleteAllKeys,
  deleteAllReferrals,
  durationToMinutes,
  generateOperatorUid,
  getOrDeriveOperatorUid,
  listUsers,
  getActiveSystemAnnouncement,
  getSystemAnnouncement,
  updateSystemAnnouncement,
  type LicenseDurationUnit,
  LICENSE_DURATION_UNITS,
} from "./license";
import { getServerMaintenance, updateServerMaintenance, getActiveServerMaintenance } from "./maintenance";
import {
  getTelegramSettings,
  updateTelegramSettings,
  getTelegramChannel,
  getTelegramSetupState,
  saveTelegramChannel,
  listTelegramChannels,
} from "./telegram";

export interface AuthenticatedAppRequest extends Request {
  user?: User;
  isOwner?: boolean;
  isSuperOwner?: boolean;
}

function hasActiveAccess(user: User, now = new Date()): boolean {
  if (user.accessStatus !== "active") return false;
  if (user.accessExpiresAt && user.accessExpiresAt.getTime() <= now.getTime()) return false;
  return true;
}

async function requireAppAuth(req: AuthenticatedAppRequest, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    let token = "";
    if (typeof authHeader === "string" && authHeader.startsWith("Bearer ")) {
      token = authHeader.slice(7).trim();
    }

    if (!token) {
      return res.status(401).json({ success: false, message: "Authorization token required" });
    }

    const session = await sdk.verifySession(token);
    if (!session || !session.openId) {
      return res.status(401).json({ success: false, message: "Session expired or invalid" });
    }

    const db = await getDb();
    if (!db) {
      return res.status(500).json({ success: false, message: "Database unavailable" });
    }

    const [user] = await db.select().from(users).where(eq(users.openId, session.openId)).limit(1);
    if (!user) {
      return res.status(401).json({ success: false, message: "User account not found" });
    }

    if (!hasActiveAccess(user)) {
      return res.status(403).json({
        success: false,
        expired: true,
        message: "Your account access has expired or been revoked. Please renew your referral.",
      });
    }

    const isSuperOwner = user.role === "super_owner" && user.openId === ENV.ownerOpenId;
    const isOwner = isSuperOwner || user.role === "owner" || user.openId === ENV.ownerOpenId;

    req.user = user;
    req.isOwner = isOwner;
    req.isSuperOwner = isSuperOwner;
    next();
  } catch (error) {
    return res.status(401).json({ success: false, message: "Authentication failed" });
  }
}

export function registerAppApiRoutes(app: Express) {
  // 1. Mobile App Login
  app.post("/api/app/login", async (req: Request, res: Response) => {
    try {
      const { username, password } = req.body ?? {};
      if (!username || !password || typeof username !== "string" || typeof password !== "string") {
        return res.status(400).json({ success: false, message: "Username and password are required" });
      }

      const db = await getDb();
      if (!db) return res.status(500).json({ success: false, message: "Database not connected" });

      const [user] = await db.select().from(users).where(eq(users.username, username.trim())).limit(1);
      if (!user || !user.passwordHash) {
        return res.status(401).json({ success: false, message: "Invalid username or password" });
      }

      const [salt, storedHash] = user.passwordHash.split(":");
      if (!salt || !storedHash) {
        return res.status(401).json({ success: false, message: "Invalid credentials configuration" });
      }

      const testHash = crypto.scryptSync(password, salt, 64).toString("hex");
      if (testHash !== storedHash) {
        return res.status(401).json({ success: false, message: "Invalid username or password" });
      }

      if (!hasActiveAccess(user)) {
        return res.status(403).json({
          success: false,
          expired: true,
          message: "Your account access has expired or been revoked. Please renew your referral.",
        });
      }

      const sessionToken = await sdk.createSessionToken(user.openId, {
        name: user.name || user.username || "",
        expiresInMs: ONE_YEAR_MS,
      });

      const isSuperOwner = user.role === "super_owner" && user.openId === ENV.ownerOpenId;
      const isOwner = isSuperOwner || user.role === "owner" || user.openId === ENV.ownerOpenId;

      return res.status(200).json({
        success: true,
        token: sessionToken,
        user: {
          id: user.id,
          username: user.username,
          name: user.name,
          role: user.role,
          isOwner,
          isSuperOwner,
          accessStatus: user.accessStatus,
          accessExpiresAt: user.accessExpiresAt,
          lastSignedIn: user.lastSignedIn,
          operatorUid: getOrDeriveOperatorUid(user),
        },
      });
    } catch (err: any) {
      console.error("[App Login Error]", err);
      return res.status(500).json({ success: false, message: err?.message || "Login failed" });
    }
  });

  // 1b. Mobile App Register (Create Account using Referral Code)
  app.post("/api/app/register", async (req: Request, res: Response) => {
    try {
      const { username, password, referralCode } = req.body ?? {};
      if (!username || !password || !referralCode) {
        return res.status(400).json({ success: false, message: "Username, password and referral code are required" });
      }

      const cleanUsername = String(username).trim();
      const cleanPassword = String(password);
      const cleanCode = String(referralCode).trim();

      if (cleanUsername.length < 3 || cleanUsername.length > 32) {
        return res.status(400).json({ success: false, message: "Username must be 3-32 characters" });
      }
      if (cleanPassword.length < 4) {
        return res.status(400).json({ success: false, message: "Password must be at least 4 characters" });
      }

      const db = await getDb();
      if (!db) return res.status(500).json({ success: false, message: "Database not connected" });

      const [existing] = await db.select().from(users).where(eq(users.username, cleanUsername)).limit(1);
      if (existing) {
        return res.status(409).json({ success: false, message: "Username is already taken" });
      }

      const [referral] = await db.select().from(referrals).where(eq(referrals.code, cleanCode)).limit(1);
      if (!referral) {
        return res.status(400).json({ success: false, message: "Invalid referral code" });
      }
      if (referral.status !== "active") {
        return res.status(400).json({ success: false, message: "Referral code has already been redeemed or revoked" });
      }
      if (new Date() > referral.expiresAt) {
        return res.status(400).json({ success: false, message: "Referral code has expired" });
      }

      const salt = crypto.randomBytes(16).toString("hex");
      const hash = crypto.scryptSync(cleanPassword, salt, 64).toString("hex");
      const passwordHash = `${salt}:${hash}`;
      const openId = `user-${crypto.randomUUID()}`;

      const now = new Date();
      const operatorUid = generateOperatorUid(referral.role);
      const [insertResult] = await db.insert(users).values({
        openId,
        name: cleanUsername,
        username: cleanUsername,
        role: referral.role,
        accessStatus: "active",
        accessExpiresAt: referral.expiresAt,
        passwordHash,
        lastSignedIn: now,
        createdAt: now,
        operatorUid,
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
        details: `Account registered via mobile app referral code ${cleanCode} with role ${referral.role} [UID: ${operatorUid}]`,
        createdAt: now,
      });

      const sessionToken = await sdk.createSessionToken(openId, {
        name: cleanUsername,
        expiresInMs: ONE_YEAR_MS,
      });

      const isSuperOwner = false;
      const isOwner = referral.role === "owner" || openId === ENV.ownerOpenId;

      return res.status(200).json({
        success: true,
        token: sessionToken,
        user: {
          id: newUserId,
          username: cleanUsername,
          role: referral.role,
          isOwner,
          isSuperOwner,
          accessStatus: "active",
          accessExpiresAt: referral.expiresAt,
          operatorUid,
        },
      });
    } catch (err: any) {
      console.error("[App Register Error]", err);
      return res.status(500).json({ success: false, message: err?.message || "Registration failed" });
    }
  });

  // 2. Mobile App Session Verification (Splash Screen on Every Launch)
  app.get("/api/app/verify-session", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    const user = req.user!;
    return res.status(200).json({
      success: true,
      valid: true,
      user: {
        id: user.id,
        username: user.username,
        name: user.name,
        role: user.role,
        isOwner: req.isOwner,
        isSuperOwner: req.isSuperOwner,
        accessStatus: user.accessStatus,
        accessExpiresAt: user.accessExpiresAt,
        operatorUid: getOrDeriveOperatorUid(user),
      },
    });
  });

  // 3. Dashboard Telemetry / Stats
  app.get("/api/app/dashboard", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const stats = req.isOwner ? await getStats({ id: user.id, isOwner: true }) : null;
      const announcement = { active: false };
      const maintenance = { active: false };

      return res.status(200).json({
        success: true,
        stats,
        announcement,
        maintenance,
        user: {
          id: user.id,
          username: user.username,
          role: user.role,
          isOwner: req.isOwner,
          isSuperOwner: req.isSuperOwner,
          accessExpiresAt: user.accessExpiresAt,
        },
      });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load dashboard" });
    }
  });

  // 4. List Keys (Role-Isolated: Admin sees their own, Owner sees their own, Super Owner can see all or own)
  app.get("/api/app/keys", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const scopeAll = Boolean(req.query.all === "true" && req.isSuperOwner);
      const keys = await listKeys({
        id: user.id,
        isOwner: scopeAll,
      });

      return res.status(200).json({ success: true, keys });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to list keys" });
    }
  });

  // 5. Generate Key
  app.post("/api/app/keys/generate", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const {
        durationAmount,
        durationUnit,
        maxDevices,
        customPrefix,
        useExactCustomKey,
      } = req.body ?? {};

      const numAmount = parseInt(durationAmount, 10);
      const numDevices = parseInt(maxDevices, 10);

      if (Number.isNaN(numAmount) || numAmount < 1 || numAmount > 5256000) {
        return res.status(400).json({ success: false, message: "Invalid duration amount (1-5256000)" });
      }

      if (!LICENSE_DURATION_UNITS.includes(durationUnit)) {
        return res.status(400).json({ success: false, message: "Invalid duration unit" });
      }

      if (Number.isNaN(numDevices) || numDevices < 1 || numDevices > 10000) {
        return res.status(400).json({ success: false, message: "Invalid maximum devices (1-10000)" });
      }

      const durationMinutes = durationToMinutes(numAmount, durationUnit as LicenseDurationUnit);
      const key = await generateKey(
        durationMinutes,
        user.id,
        typeof customPrefix === "string" && customPrefix.trim() ? customPrefix.trim() : undefined,
        numDevices,
        user.username,
        Boolean(useExactCustomKey)
      );

      return res.status(200).json({ success: true, key });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to generate key" });
    }
  });

  // 6. Set Key Status (Active / Revoked)
  app.post("/api/app/keys/status", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const { id, status } = req.body ?? {};
      const keyId = parseInt(id, 10);

      if (Number.isNaN(keyId) || keyId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid key id" });
      }

      if (status !== "active" && status !== "revoked") {
        return res.status(400).json({ success: false, message: "Invalid status ('active' or 'revoked')" });
      }

      const result = await setKeyStatus(keyId, status, {
        id: user.id,
        isOwner: Boolean(req.isOwner),
      });

      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to update key status" });
    }
  });

  // 7. Get Bound Devices for a Key
  app.get("/api/app/keys/:keyId/bindings", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const keyId = parseInt(req.params.keyId, 10);

      if (Number.isNaN(keyId) || keyId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid key id" });
      }

      const bindings = await getBindings(keyId, {
        id: user.id,
        isOwner: Boolean(req.isOwner),
      });

      return res.status(200).json({ success: true, bindings });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to get bindings" });
    }
  });

  // 8. Unbind Device
  app.post("/api/app/keys/unbind", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const { bindingId } = req.body ?? {};
      const numBindingId = parseInt(bindingId, 10);

      if (Number.isNaN(numBindingId) || numBindingId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid binding id" });
      }

      const result = await unbindDevice(numBindingId, {
        id: user.id,
        isOwner: Boolean(req.isOwner),
      });

      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to unbind device" });
    }
  });

  // 9. Delete Key
  app.post("/api/app/keys/delete", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const user = req.user!;
      const { id } = req.body ?? {};
      const keyId = parseInt(id, 10);

      if (Number.isNaN(keyId) || keyId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid key id" });
      }

      const result = await deleteKey(keyId, {
        id: user.id,
        isOwner: Boolean(req.isOwner),
      });

      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to delete key" });
    }
  });

  // 10. List Referrals (Owner / Super Owner only)
  app.get("/api/app/referrals", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isOwner) {
        return res.status(403).json({ success: false, message: "Owner access required" });
      }

      const user = req.user!;
      const referrals = await listReferrals({ id: user.id, role: user.role });
      return res.status(200).json({ success: true, referrals });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to list referrals" });
    }
  });

  // 11. Create Referral (Owner creates admin referrals; only Super Owner can create owner referrals)
  app.post("/api/app/referrals/create", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isOwner) {
        return res.status(403).json({ success: false, message: "Owner access required" });
      }

      const user = req.user!;
      const { role, durationDays } = req.body ?? {};

      if (role !== "admin" && role !== "owner") {
        return res.status(400).json({ success: false, message: "Invalid referral role ('admin' or 'owner')" });
      }

      if (role === "owner" && !req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Only Super Owner can create Owner referrals" });
      }

      const numDays = parseInt(durationDays, 10);
      if (Number.isNaN(numDays) || numDays < 1 || numDays > 3650) {
        return res.status(400).json({ success: false, message: "Duration must be between 1 and 3650 days" });
      }

      const referral = await createReferral(role, numDays, user.id);
      return res.status(200).json({ success: true, referral });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to create referral" });
    }
  });

  // 12. Revoke Referral
  app.post("/api/app/referrals/revoke", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isOwner) {
        return res.status(403).json({ success: false, message: "Owner access required" });
      }

      const user = req.user!;
      const { id } = req.body ?? {};
      const referralId = parseInt(id, 10);

      if (Number.isNaN(referralId) || referralId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid referral id" });
      }

      const result = await revokeReferral(referralId, { id: user.id, role: user.role });
      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to revoke referral" });
    }
  });

  // 13. Delete Referral
  app.post("/api/app/referrals/delete", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isOwner) {
        return res.status(403).json({ success: false, message: "Owner access required" });
      }

      const user = req.user!;
      const { id } = req.body ?? {};
      const referralId = parseInt(id, 10);

      if (Number.isNaN(referralId) || referralId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid referral id" });
      }

      const result = await deleteReferral(referralId, { id: user.id, role: user.role });
      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to delete referral" });
    }
  });

  // 14. Super Owner Global Overview
  app.get("/api/app/super-owner/overview", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }

      const [counts, referralOverview, allKeysOverview, allReferralsDetailed, operators] = await Promise.all([
        getSeasonControlCounts(),
        getReferralOverview(),
        getAllKeysOverview(),
        getAllReferralsDetailed(),
        listUsers(),
      ]);

      return res.status(200).json({
        success: true,
        counts,
        referralOverview,
        allKeysOverview,
        allReferralsDetailed,
        operators,
      });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load super owner overview" });
    }
  });

  // 14b. Super Owner Operator Registry (UIDs)
  app.get("/api/app/super-owner/operators", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }

      const operators = await listUsers();
      return res.status(200).json({
        success: true,
        operators,
      });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load operators" });
    }
  });

  // 14c. Super Owner Delete Operator (Permanently removes account and invalidates UID)
  app.post("/api/app/super-owner/operators/delete", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }

      const { userId } = req.body ?? {};
      const numUserId = parseInt(userId, 10);
      if (Number.isNaN(numUserId) || numUserId <= 0) {
        return res.status(400).json({ success: false, message: "Invalid operator id" });
      }

      await deleteUser(numUserId, req.user!.id, req.user!.openId, true);
      return res.status(200).json({ success: true, message: "Operator account and UID deleted successfully" });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to delete operator" });
    }
  });

  // 15. Super Owner Wipe All Keys
  app.post("/api/app/super-owner/wipe-keys", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }

      const result = await deleteAllKeys(req.user!.id);
      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to wipe keys" });
    }
  });

  // 16. Super Owner Wipe All Referrals
  app.post("/api/app/super-owner/wipe-referrals", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }

      const result = await deleteAllReferrals(req.user!.id);
      return res.status(200).json(result);
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to wipe referrals" });
    }
  });

  // 17. Super Owner - Get Announcement
  app.get("/api/app/super-owner/announcement", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }
      const announcement = await getSystemAnnouncement();
      return res.status(200).json({ success: true, announcement });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load announcement" });
    }
  });

  // 18. Super Owner - Update Announcement
  app.post("/api/app/super-owner/announcement", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }
      const { enabled, title, message, displayMode, textSize, startAt, endAt } = req.body ?? {};
      const startDate = startAt ? new Date(startAt) : null;
      const endDate = endAt ? new Date(endAt) : null;

      const updated = await updateSystemAnnouncement({
        enabled: Boolean(enabled),
        title: title || "SYSTEM ANNOUNCEMENT",
        message: message || "",
        startAt: startDate,
        endAt: endDate,
        displayMode: displayMode || "every_login",
        textSize: textSize || "normal",
      }, req.user!.id);
      return res.status(200).json({ success: true, announcement: updated });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to update announcement" });
    }
  });

  // 19. Super Owner - Get Maintenance
  app.get("/api/app/super-owner/maintenance", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }
      const maintenance = await getServerMaintenance();
      return res.status(200).json({ success: true, maintenance });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load maintenance" });
    }
  });

  // 20. Super Owner - Update Maintenance
  app.post("/api/app/super-owner/maintenance", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }
      const { enabled, title, message, startAt, endAt } = req.body ?? {};
      const startDate = startAt ? new Date(startAt) : null;
      const endDate = endAt ? new Date(endAt) : null;

      const updated = await updateServerMaintenance({
        enabled: Boolean(enabled),
        title: title || "SERVER MAINTENANCE",
        message: message || "System is undergoing maintenance",
        startAt: startDate,
        endAt: endDate,
      }, req.user!.id);
      return res.status(200).json({ success: true, maintenance: updated });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to update maintenance" });
    }
  });

  // 21. Telegram - Get Info (Settings, My Channel, Channels if Owner)
  app.get("/api/app/telegram/info", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const actorRole = req.isSuperOwner ? "super_owner" : (req.isOwner ? "owner" : "admin");
      const actor = { id: req.user!.id, role: actorRole as "super_owner" | "owner" | "admin" };

      const settings = await getTelegramSettings();
      const myChannel = await getTelegramChannel(req.user!.id);
      const setupState = await getTelegramSetupState(req.user!.id);
      const channels = (req.isSuperOwner || req.isOwner) ? await listTelegramChannels(actor) : [];

      return res.status(200).json({
        success: true,
        settings: {
          enabled: Boolean(settings?.enabled),
        },
        myChannel: myChannel ? {
          id: myChannel.id,
          userId: myChannel.userId,
          channelUrl: myChannel.channelUrl,
          enabled: myChannel.enabled,
        } : null,
        setupState,
        channels: channels.map(c => ({
          channel: c.channel,
          username: c.username,
          role: c.role,
        })),
      });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to load Telegram info" });
    }
  });

  // 22. Telegram - Save Channel
  app.post("/api/app/telegram/save", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      const { channelUrl, enabled, userId } = req.body ?? {};
      if (!channelUrl || typeof channelUrl !== "string") {
        return res.status(400).json({ success: false, message: "Valid Telegram channel URL is required" });
      }

      const actorRole = req.isSuperOwner ? "super_owner" : (req.isOwner ? "owner" : "admin");
      const actor = { id: req.user!.id, role: actorRole as "super_owner" | "owner" | "admin" };

      const targetUserId = (req.isSuperOwner || req.isOwner) && userId ? Number(userId) : req.user!.id;

      const saved = await saveTelegramChannel({
        userId: targetUserId,
        channelUrl: channelUrl.trim(),
        enabled: enabled !== false,
      }, actor);

      return res.status(200).json({ success: true, channel: saved });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to save Telegram channel" });
    }
  });

  // 23. Telegram - Update Extension Master Switch (Super Owner only)
  app.post("/api/app/telegram/settings", requireAppAuth, async (req: AuthenticatedAppRequest, res: Response) => {
    try {
      if (!req.isSuperOwner) {
        return res.status(403).json({ success: false, message: "Super Owner access required" });
      }
      const { enabled } = req.body ?? {};
      const updated = await updateTelegramSettings({ enabled: Boolean(enabled) }, req.user!.id);
      return res.status(200).json({ success: true, settings: updated });
    } catch (err: any) {
      return res.status(500).json({ success: false, message: err?.message || "Failed to update Telegram settings" });
    }
  });
}
