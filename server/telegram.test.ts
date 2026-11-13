import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import {
  normalizeTelegramChannelUrl,
  TELEGRAM_CHANNEL_MAX_LENGTH,
  TELEGRAM_TICKET_TTL_MS,
  getTelegramSetupStateForActor,
} from "./telegram";

const telegramSource = readFileSync(resolve(process.cwd(), "server/telegram.ts"), "utf8");
const ticketIssuanceSource = telegramSource.slice(telegramSource.indexOf("export async function issueTelegramTicket"), telegramSource.indexOf("export async function redeemTelegramTicket"));
const ticketRedemptionSource = telegramSource.slice(telegramSource.indexOf("export async function redeemTelegramTicket"));
const luaSource = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-Merged.lua"), "utf8");
const telegramUiSource = readFileSync(resolve(process.cwd(), "client/src/components/TelegramExtensionCard.tsx"), "utf8");
const homeSource = readFileSync(resolve(process.cwd(), "client/src/pages/Home.tsx"), "utf8");

describe("isolated Telegram extension", () => {
  it("accepts supported HTTPS public channel URLs", () => {
    expect(normalizeTelegramChannelUrl(" https://t.me/ALEXA_LORD/ ")).toBe("https://t.me/ALEXA_LORD");
    expect(normalizeTelegramChannelUrl("https://telegram.me/channel_name")).toBe("https://telegram.me/channel_name");
  });

  it("accepts private invite links and preserves them exactly after validation", () => {
    const plusInvite = "https://t.me/+AbC_123-xy";
    const joinchatInvite = "https://t.me/joinchat/AbC_123-xy";
    expect(normalizeTelegramChannelUrl(plusInvite)).toBe(plusInvite);
    expect(normalizeTelegramChannelUrl(joinchatInvite)).toBe(joinchatInvite);
  });

  it("rejects unsafe, unsupported, or malformed channel URLs", () => {
    for (const value of [
      "http://t.me/channel",
      "https://example.com/channel",
      "javascript:alert(1)",
      "https://t.me/channel?redirect=https://example.com",
      "https://t.me/channel#fragment",
      "https://t.me/",
      "https://t.me/channel name",
      "https://t.me/+invite?redirect=elsewhere",
      "https://t.me/joinchat/",
      "https://t.me/+invite/extra",
      "data:text/html,telegram",
      "file:///tmp/channel",
    ]) {
      expect(() => normalizeTelegramChannelUrl(value)).toThrow();
    }
  });

  it("enforces the isolated channel length limit", () => {
    expect(() => normalizeTelegramChannelUrl(`https://t.me/${"a".repeat(TELEGRAM_CHANNEL_MAX_LENGTH)}`)).toThrow();
  });

  it("uses a short-lived ticket lifetime", () => {
    expect(TELEGRAM_TICKET_TTL_MS).toBe(60_000);
  });

  it("does not accept emoji-only channel paths as account identifiers", () => {
    expect(() => normalizeTelegramChannelUrl("https://t.me/🇮🇳")).toThrow();
  });

  it("resolves all creator-owned keys through the creator's current enabled account channel without a per-key mapping", () => {
    expect(ticketIssuanceSource).toContain("getTelegramChannel(license.createdByUserId)");
    expect(ticketIssuanceSource).not.toContain("telegramKeyMappings");
    expect(ticketRedemptionSource).toContain("eq(telegramChannels.userId, license.createdByUserId)");
    expect(ticketRedemptionSource).not.toContain("telegramKeyMappings");
    expect(telegramSource).toContain('resolution: "creator_channel_missing" as const');
    expect(telegramSource).toContain('resolution: "creator_channel_disabled" as const');
  });

  it("shows the server-backed setup prompt only until a channel is saved", () => {
    expect(getTelegramSetupStateForActor("owner", null)).toEqual({ eligible: true, hasSavedChannel: false, needsSetup: true });
    expect(getTelegramSetupStateForActor("admin", { enabled: false, channelUrl: "https://t.me/old" })).toEqual({ eligible: true, hasSavedChannel: false, needsSetup: true });
    expect(getTelegramSetupStateForActor("admin", { enabled: true, channelUrl: "https://t.me/valid" })).toEqual({ eligible: true, hasSavedChannel: true, needsSetup: false });
    expect(getTelegramSetupStateForActor("super_owner", null)).toEqual({ eligible: true, hasSavedChannel: false, needsSetup: true });
  });

  it("keeps ticket redemption short-lived, single-use, and device-bound", () => {
    expect(telegramSource).toContain("isNull(telegramTickets.redeemedAt)");
    expect(telegramSource).toContain("eq(telegramTickets.deviceHash, ticket.deviceHash)");
    expect(telegramSource).toContain("redeemResult.affectedRows !== 1");
  });

  it("keeps private links as stored creator-account values and never resolves them", () => {
    expect(telegramSource).toContain("return { enabled: true as const, channelUrl: channel.channelUrl, resolution: \"channel_resolved\" as const };");
    expect(telegramSource).not.toMatch(/resolve.*telegram|telegram.*resolve/i);
    expect(ticketIssuanceSource).toMatch(/createdByUserId.*channel|channel.*createdByUserId/);
  });

  it("provides Super Owner and referral-scoped Owner per-account edit controls without changing scoped permissions", () => {
    expect(telegramUiSource).toContain("EDIT LINK");
    expect(telegramUiSource).toContain("userId: item.channel.userId");
    expect(telegramUiSource).toContain("editingUserId === item.channel.userId");
    expect(telegramUiSource).toContain("item.channel.channelUrl");
    expect(telegramSource).toContain("if (!(await canManageAccount(actor, input.userId)))");
    expect(telegramSource).toContain("actor.role === \"super_owner\"");
  });

  it("shows an existing-user setup popup and accepts both public and private link guidance", () => {
    expect(telegramUiSource).toContain("ADD TELEGRAM LINK");
    expect(telegramUiSource).toContain("setSetupDialogOpen(true)");
    expect(telegramUiSource).toContain("setupState.data?.needsSetup");
    expect(telegramUiSource).toContain("Public Channel Link or Private Invite Link");
    expect(telegramUiSource).toContain("https://t.me/+invite_hash");
    expect(telegramUiSource).toContain("setSetupDialogOpen(false)");
  });

  it("restores setup visibility for active named Admins and Owners while preserving Admin first-save-only behavior", () => {
    expect(homeSource).toContain("<TelegramExtensionCard isSuperOwner={isSuperOwner} isOwner={isOwner} isAdmin={identity.data?.role === \"admin\"} isActive={isActive} />");
    expect(homeSource).toContain("isActive && identity.data?.username");
    expect(telegramUiSource).toContain("const canEditOwnChannel = isSuperOwner || isOwner || (isAdmin && !channel.data);");
    expect(telegramSource).toContain("if (actor.role === \"admin\" && existing) throw new Error(\"Admins can create the first Telegram channel but cannot edit it later\")");
  });

  it("limits Owner edits to Admins redeemed from that Owner's own referral and leaves Super Owner global control intact", () => {
    expect(telegramSource).toContain("eq(referrals.createdByUserId, actor.id)");
    expect(telegramSource).toContain("eq(referrals.redeemedByUserId, targetUserId)");
    expect(telegramSource).toContain("eq(referrals.role, \"admin\")");
    expect(telegramSource).toContain("eq(referrals.status, \"redeemed\")");
    expect(telegramSource).toContain("if (actor.role === \"super_owner\" || actor.id === targetUserId) return true;");
    expect(telegramUiSource).toContain("Admins you referred");
  });

  it("keeps Telegram behavior behind the announcement OK path and preserves Cancel", () => {
    expect(luaSource).toMatch(/announcement/i);
    expect(luaSource).toMatch(/telegram/i);
    expect(luaSource).toMatch(/cancel/i);
    expect(luaSource).toMatch(/open|WebSDK|URL/);
    expect(telegramSource).toContain('if (!(await isTelegramEnabled())) return { enabled: false as const, ticket: null, resolution: "telegram_disabled" as const };');
  });

  it("writes only allowlisted non-secret creator-channel diagnostic states on Android", () => {
    expect(luaSource).toContain("TICKET_CREATOR_CHANNEL_MISSING = true");
    expect(luaSource).toContain("TICKET_CREATOR_CHANNEL_DISABLED = true");
    expect(luaSource).toContain("REDEEM_CREATOR_CHANNEL_MISSING = true");
    expect(luaSource).toContain("REDEEM_CREATOR_CHANNEL_DISABLED = true");
    expect(luaSource).toContain('response.resolution == "creator_channel_missing"');
    expect(luaSource).toContain('response.resolution == "creator_channel_disabled"');
  });
});
