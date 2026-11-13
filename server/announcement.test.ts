import { describe, expect, it } from "vitest";
import {
  ANNOUNCEMENT_MESSAGE_MAX_LENGTH,
  ANNOUNCEMENT_TITLE_MAX_LENGTH,
  isAnnouncementActive,
  normalizeAnnouncementText,
  toAnnouncementPayload,
} from "./license";

describe("system announcement rules", () => {
  const base = {
    id: 1,
    version: 3,
    enabled: true,
    title: "🇮🇳 Independence Day",
    message: "Happy Independence Day to all users! 🎉",
    startAt: new Date("2026-08-15T00:00:00.000Z"),
    endAt: new Date("2026-08-16T00:00:00.000Z"),
    displayMode: "once_per_day" as const,
    textSize: "festival_large" as const,
  };

  it("accepts emoji and preserves the 300-character message limit", () => {
    expect(normalizeAnnouncementText(base.message, ANNOUNCEMENT_MESSAGE_MAX_LENGTH)).toContain("🎉");
    expect(() => normalizeAnnouncementText("x".repeat(ANNOUNCEMENT_MESSAGE_MAX_LENGTH + 1), ANNOUNCEMENT_MESSAGE_MAX_LENGTH)).toThrow();
    expect(() => normalizeAnnouncementText("x".repeat(ANNOUNCEMENT_TITLE_MAX_LENGTH + 1), ANNOUNCEMENT_TITLE_MAX_LENGTH)).toThrow();
  });

  it("activates only inside the inclusive schedule window", () => {
    expect(isAnnouncementActive(base, new Date("2026-08-15T00:00:00.000Z"))).toBe(true);
    expect(isAnnouncementActive(base, new Date("2026-08-16T00:00:00.000Z"))).toBe(true);
    expect(isAnnouncementActive(base, new Date("2026-08-16T00:00:00.001Z"))).toBe(false);
  });

  it("returns presentation metadata and no payload when inactive", () => {
    const active = toAnnouncementPayload(base, new Date("2026-08-15T12:00:00.000Z"));
    expect(active).toMatchObject({ active: true, version: 3, displayMode: "once_per_day", textSize: "festival_large" });
    expect(toAnnouncementPayload({ ...base, enabled: false }, new Date("2026-08-15T12:00:00.000Z"))).toEqual({ active: false });
  });
});
