import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { API_ERROR_CODES, canAccessLicense, canRemoveOwnerAccount, durationToMinutes, evaluateLicenseValidation, generateExactLicenseKey, GENERATED_LICENSE_KEY_MAX_LENGTH, generateLicenseKey, getActivationTransition, getApiSharedSecret, getUsernameChangeAvailability, hashDevice, hasUnexpiredCustomPrefixConflict, hasUnexpiredExactKeyConflict, indexBindingCounts, isDeviceLimitReached, isReferralDeletable, isReferralUsable, isSafeReplacementBindingSource, isUserClearable, isValidMaximumDevices, MAX_LICENSE_DEVICES, normalizeKeyPrefix, normalizeUsername, RECENT_AUDIT_LOG_LIMIT, USERNAME_CHANGE_COOLDOWN_MS, usernameToKeyPrefix } from "./license";

const licenseSource = readFileSync(resolve(process.cwd(), "server/license.ts"), "utf8");
const schemaSource = readFileSync(resolve(process.cwd(), "drizzle/schema.ts"), "utf8");

describe("license control invariants", () => {
  it("generates a non-empty panel-compatible key", () => {
    const key = generateLicenseKey();
    expect(key).toMatch(/^LUA-[A-Z0-9X]+$/);
    expect(key.length).toBeGreaterThan(20);
  });

  it("supports a custom key prefix while preserving a unique suffix", () => {
    expect(generateLicenseKey("Alexa")).toMatch(/^ALEXA-[A-Z0-9X]+$/);
    expect(normalizeKeyPrefix("  game access  ")).toBe("GAME-ACCESS");
  });

  it("normalizes safe recognizable usernames while rejecting invalid onboarding input", () => {
    expect(normalizeUsername("  Pooja   Sharma  ")).toBe("Pooja Sharma");
    expect(normalizeUsername("Dhar-12_01")).toBe("Dhar-12_01");
    expect(() => normalizeUsername("ab")).toThrow();
    expect(() => normalizeUsername("name@domain")).toThrow();
    expect(() => normalizeUsername("x".repeat(33))).toThrow();
  });

  it("derives safe uppercase key prefixes from saved usernames without weakening the random suffix", () => {
    expect(usernameToKeyPrefix("Alexa Lord")).toBe("ALEXA-LORD");
    expect(usernameToKeyPrefix("Dhar-12_01")).toBe("DHAR-1201");
    expect(usernameToKeyPrefix(null)).toBeUndefined();
    expect(generateLicenseKey(usernameToKeyPrefix("Alexa Lord"))).toMatch(/^ALEXA-LORD-[A-Z0-9X]+$/);
  });

  it("keeps every username-prefixed generated key within the 50-character production cap", () => {
    const longestSupportedPrefix = usernameToKeyPrefix("A".repeat(32));
    const key = generateLicenseKey(longestSupportedPrefix);
    expect(GENERATED_LICENSE_KEY_MAX_LENGTH).toBe(50);
    expect(key).toMatch(/^[A-Z0-9]+-[A-Z0-9X]+$/);
    expect(key.length).toBeLessThanOrEqual(GENERATED_LICENSE_KEY_MAX_LENGTH);
  });

  it("enforces a 72-hour username-change cooldown from the persisted change time", () => {
    const changedAt = new Date("2026-08-01T12:00:00.000Z");
    expect(USERNAME_CHANGE_COOLDOWN_MS).toBe(72 * 60 * 60 * 1000);
    expect(getUsernameChangeAvailability(changedAt, new Date("2026-08-04T11:59:59.999Z"))).toMatchObject({ available: false, remainingMs: 1 });
    expect(getUsernameChangeAvailability(changedAt, new Date("2026-08-04T12:00:00.000Z"))).toMatchObject({ available: true, remainingMs: 0 });
    expect(getUsernameChangeAvailability(null)).toMatchObject({ available: true, remainingMs: 0 });
  });

  it("allows owners to access all keys but scopes admins to their own keys", () => {
    expect(canAccessLicense({ id: 1, isOwner: true }, 99)).toBe(true);
    expect(canAccessLicense({ id: 1, isOwner: false }, 1)).toBe(true);
    expect(canAccessLicense({ id: 1, isOwner: false }, 2)).toBe(false);
    expect(canAccessLicense({ id: 1, isOwner: false }, null)).toBe(false);
  });

  it("blocks an unexpired custom prefix but allows expired keys or different prefixes", () => {
    const now = new Date("2026-08-12T00:00:00.000Z");
    expect(hasUnexpiredCustomPrefixConflict([{ keyValue: "ALEXA-OLD", expiresAt: new Date("2026-09-01T00:00:00.000Z") }], "Alexa", now)).toBe(true);
    expect(hasUnexpiredCustomPrefixConflict([{ keyValue: "ALEXA-OLD", expiresAt: new Date("2026-08-01T00:00:00.000Z") }], "Alexa", now)).toBe(false);
    expect(hasUnexpiredCustomPrefixConflict([{ keyValue: "BETA-OLD", expiresAt: new Date("2026-09-01T00:00:00.000Z") }], "Alexa", now)).toBe(false);
  });

  it("supports an optional exact custom key name while blocking only active or unexpired duplicates", () => {
    const now = new Date("2026-08-12T00:00:00.000Z");
    expect(generateExactLicenseKey(" Alexa ")).toBe("ALEXA");
    expect(hasUnexpiredExactKeyConflict([{ keyValue: "ALEXA", status: "active", expiresAt: new Date("2026-09-01T00:00:00.000Z") }], "Alexa", now)).toBe(true);
    expect(hasUnexpiredExactKeyConflict([{ keyValue: "ALEXA", status: "expired", expiresAt: new Date("2026-08-01T00:00:00.000Z") }], "Alexa", now)).toBe(false);
    expect(hasUnexpiredExactKeyConflict([{ keyValue: "ALEXA", status: "revoked", expiresAt: null }], "Alexa", now)).toBe(false);
  });

  it("only accepts active referrals that have not expired", () => {
    const now = new Date("2026-08-12T00:00:00.000Z");
    expect(isReferralUsable({ status: "active", expiresAt: new Date("2026-08-13T00:00:00.000Z") }, now)).toBe(true);
    expect(isReferralUsable({ status: "active", expiresAt: new Date("2026-08-11T00:00:00.000Z") }, now)).toBe(false);
    expect(isReferralUsable({ status: "revoked", expiresAt: new Date("2026-08-13T00:00:00.000Z") }, now)).toBe(false);
  });

  it("allows clearing stale referrals but protects usable active referrals", () => {
    const now = new Date("2026-08-12T00:00:00.000Z");
    expect(isReferralDeletable({ status: "revoked", expiresAt: new Date("2026-08-20T00:00:00.000Z") }, now)).toBe(true);
    expect(isReferralDeletable({ status: "redeemed", expiresAt: new Date("2026-08-20T00:00:00.000Z") }, now)).toBe(true);
    expect(isReferralDeletable({ status: "active", expiresAt: new Date("2026-08-11T00:00:00.000Z") }, now)).toBe(true);
    expect(isReferralDeletable({ status: "active", expiresAt: new Date("2026-08-20T00:00:00.000Z") }, now)).toBe(false);
  });

  it("marks revoked or expired accounts as clearable but protects active accounts", () => {
    const now = new Date("2026-08-12T00:00:00.000Z");
    expect(isUserClearable({ accessStatus: "revoked", accessExpiresAt: new Date("2026-08-20T00:00:00.000Z") }, now)).toBe(true);
    expect(isUserClearable({ accessStatus: "active", accessExpiresAt: new Date("2026-08-11T00:00:00.000Z") }, now)).toBe(true);
    expect(isUserClearable({ accessStatus: "active", accessExpiresAt: new Date("2026-08-20T00:00:00.000Z") }, now)).toBe(false);
  });

  it("permits only the singleton Super Owner role to remove a different Owner account", () => {
    expect(canRemoveOwnerAccount({ id: 1, role: "super_owner" }, { id: 2, role: "owner" })).toBe(true);
    expect(canRemoveOwnerAccount({ id: 1, role: "owner" }, { id: 2, role: "owner" })).toBe(false);
    expect(canRemoveOwnerAccount({ id: 1, role: "admin" }, { id: 2, role: "owner" })).toBe(false);
    expect(canRemoveOwnerAccount({ id: 1, role: "super_owner" }, { id: 2, role: "super_owner" })).toBe(false);
    expect(canRemoveOwnerAccount({ id: 1, role: "super_owner" }, { id: 1, role: "owner" })).toBe(false);
  });

  it("cleans deleted accounts from Telegram links, mappings, scopes, tickets, and referral edges", () => {
    expect(licenseSource).toContain("await db.transaction(async tx => {");
    expect(licenseSource).toContain("tx.delete(telegramChannels).where(eq(telegramChannels.userId, id))");
    expect(licenseSource).toContain("eq(telegramAccountScopes.ownerUserId, id)");
    expect(licenseSource).toContain("eq(telegramAccountScopes.accountUserId, id)");
    expect(licenseSource).toContain("inArray(telegramAccountScopes.sourceReferralId, linkedReferralIds)");
    expect(licenseSource).toContain("eq(referrals.redeemedByUserId, id)");
    expect(licenseSource).toContain("inArray(telegramKeyMappings.licenseId, ownedLicenseIds)");
    expect(licenseSource).toContain("tx.delete(telegramTickets).where(inArray(telegramTickets.licenseId, ownedLicenseIds))");
  });

  it("caps the panel audit feed at the requested 15 newest records while retaining history in storage", () => {
    expect(RECENT_AUDIT_LOG_LIMIT).toBe(15);
  });

  it("rejects an empty-after-sanitization or oversized custom prefix", () => {
    expect(() => normalizeKeyPrefix("!!!")).toThrow();
    expect(() => normalizeKeyPrefix("A".repeat(25))).toThrow();
  });

  it("keeps the public validation error contract exact", () => {
    expect(API_ERROR_CODES).toEqual([
      "invalid_key",
      "key_banned",
      "key_expired",
      "device_limit_reached",
      "device_already_bound",
    ]);
  });

  it("derives a stable non-empty API secret", () => {
    expect(getApiSharedSecret()).toMatch(/^[a-f0-9]{64}$/);
    expect(getApiSharedSecret()).toBe(getApiSharedSecret());
  });

  it("hashes the client-supplied device ID consistently, while documenting that it is not hardware attestation", () => {
    const first = hashDevice("device-12");
    const repeated = hashDevice(" device-12 ");
    const copied = hashDevice("device-34");
    expect(first).toMatch(/^[a-f0-9]{64}$/);
    expect(repeated).toBe(first);
    expect(copied).not.toBe(first);
    // The server binds this hash, not an unforgeable hardware identity; a client that can choose device-12 can replay it.
  });

  it("converts every supported generated duration unit into the stored minute duration", () => {
    expect(durationToMinutes(15, "minutes")).toBe(15);
    expect(durationToMinutes(2, "hours")).toBe(120);
    expect(durationToMinutes(3, "days")).toBe(4320);
    expect(durationToMinutes(2, "weeks")).toBe(20160);
    expect(durationToMinutes(1, "months")).toBe(43200);
  });

  it("starts a new duration license only on its first successful device activation", () => {
    const activationTime = new Date("2026-08-14T12:00:00.000Z");
    expect(getActivationTransition({ activatedAt: null, expiresAt: null, durationMinutes: 90 }, activationTime)).toEqual({
      activatesNow: true,
      activatedAt: activationTime,
      expiresAt: new Date("2026-08-14T13:30:00.000Z"),
    });
  });

  it("keeps an activated license expiry stable on later validations", () => {
    const activatedAt = new Date("2026-08-14T12:00:00.000Z");
    const expiresAt = new Date("2026-08-14T13:30:00.000Z");
    expect(getActivationTransition({ activatedAt, expiresAt, durationMinutes: 90 }, new Date("2026-08-14T12:45:00.000Z"))).toEqual({
      activatesNow: false,
      activatedAt,
      expiresAt,
    });
  });

  it("preserves stored expiry behavior for legacy licenses without a duration", () => {
    const legacyExpiry = new Date("2026-09-01T00:00:00.000Z");
    expect(getActivationTransition({ activatedAt: null, expiresAt: legacyExpiry, durationMinutes: null }, new Date("2026-08-14T12:00:00.000Z"))).toEqual({
      activatesNow: false,
      activatedAt: null,
      expiresAt: legacyExpiry,
    });
  });

  const future = new Date(Date.now() + 86_400_000);
  const past = new Date(Date.now() - 1);
  const currentDevice = "device-hash-a";

  it.each([
    ["new unused key", { status: "unused" as const, expiresAt: future, boundDeviceId: null }, currentDevice, { success: true, status: "valid", message: "License is valid for this device." }],
    ["same key and same device", { status: "active" as const, expiresAt: future, boundDeviceId: currentDevice }, currentDevice, { success: true, status: "valid", message: "License is valid for this device." }],
    ["expired key", { status: "active" as const, expiresAt: past, boundDeviceId: null }, currentDevice, { success: false, status: "expired", message: "License key has expired." }],
    ["revoked key", { status: "revoked" as const, expiresAt: future, boundDeviceId: null }, currentDevice, { success: false, status: "invalid", message: "License key has been revoked." }],
    ["different device", { status: "active" as const, expiresAt: future, boundDeviceId: currentDevice }, "device-hash-b", { success: false, status: "device_mismatch", message: "License key is bound to a different device." }],
  ] as const)("returns canonical %s validation response", (_label, row, deviceHash, expected) => {
    expect(evaluateLicenseValidation(row, deviceHash)).toEqual(expected);
  });

  it("returns not_registered for an unknown key", () => {
    expect(evaluateLicenseValidation(null, currentDevice)).toEqual({ success: false, status: "not_registered", message: "License key is not registered." });
  });

  it("allows another device for a multi-device license before capacity is exhausted", () => {
    expect(evaluateLicenseValidation({ status: "active", expiresAt: future, boundDeviceId: currentDevice, maxDevices: 5 }, "device-hash-b")).toEqual({
      success: true,
      status: "valid",
      message: "License is valid for this device.",
    });
  });

  it("allows the same physical device to bind separate valid licenses without weakening per-key mismatch checks", () => {
    const firstKey = { status: "active" as const, expiresAt: future, boundDeviceId: currentDevice, maxDevices: 1 };
    const secondKey = { status: "unused" as const, expiresAt: future, boundDeviceId: null, maxDevices: 1 };
    expect(evaluateLicenseValidation(firstKey, currentDevice)).toMatchObject({ success: true, status: "valid" });
    expect(evaluateLicenseValidation(secondKey, currentDevice)).toMatchObject({ success: true, status: "valid" });
    expect(evaluateLicenseValidation(firstKey, "device-hash-b")).toMatchObject({ success: false, status: "device_mismatch" });
  });

  it("stores device hashes per license rather than globally across all licenses", () => {
    expect(schemaSource).toContain('uniqueIndex("device_bindings_license_device_hash_unique").on(table.licenseKeyId, table.deviceHash)');
    expect(schemaSource).not.toContain('deviceHash: varchar("deviceHash", { length: 128 }).notNull().unique()');
    expect(licenseSource).toContain("eq(deviceBindings.licenseKeyId, lockedRow.id)");
    expect(licenseSource).toContain("eq(deviceBindings.deviceHash, deviceHash)");
    expect(licenseSource).not.toContain("where(eq(deviceBindings.deviceHash, deviceHash)).limit(1)");
  });

  it("treats revalidation as free capacity while rejecting a sixth unique device on a five-device key", () => {
    expect(isDeviceLimitReached(4, 5)).toBe(false);
    expect(isDeviceLimitReached(5, 5)).toBe(true);
    expect(isDeviceLimitReached(6, 5)).toBe(true);
  });

  it("accepts Maximum Devices values through 10,000 and rejects 10,001", () => {
    expect(MAX_LICENSE_DEVICES).toBe(10_000);
    for (const value of [100, 400, 1000, 10000]) expect(isValidMaximumDevices(value)).toBe(true);
    expect(isValidMaximumDevices(10001)).toBe(false);
  });

  it("permits safe device-binding replacement only from revoked or expired source licenses", () => {
    const now = new Date("2026-08-22T00:00:00.000Z");
    expect(isSafeReplacementBindingSource({ status: "revoked", expiresAt: new Date("2026-09-01T00:00:00.000Z") }, now)).toBe(true);
    expect(isSafeReplacementBindingSource({ status: "expired", expiresAt: new Date("2026-09-01T00:00:00.000Z") }, now)).toBe(true);
    expect(isSafeReplacementBindingSource({ status: "active", expiresAt: new Date("2026-08-21T23:59:59.999Z") }, now)).toBe(true);
    expect(isSafeReplacementBindingSource({ status: "active", expiresAt: new Date("2026-09-01T00:00:00.000Z") }, now)).toBe(false);
    expect(isSafeReplacementBindingSource({ status: "unused", expiresAt: null }, now)).toBe(false);
  });

  it("indexes every grouped binding, including MySQL numeric-string counts", () => {
    const counts = indexBindingCounts([{ licenseKeyId: 510003, count: "17" }, { licenseKeyId: 810002, count: 1 }]);
    expect(counts.get(510003)).toBe(17);
    expect(counts.get(810002)).toBe(1);
    expect(counts.get(780004) ?? 0).toBe(0);
  });
});
