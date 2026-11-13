import { describe, expect, it } from "vitest";
import { isMaintenanceActive, normalizeMaintenanceText, toMaintenancePayload } from "./maintenance";

const now = new Date("2026-08-20T12:00:00.000Z");

describe("isolated server maintenance state", () => {
  it("preserves Unicode and emoji while safely removing control characters and enforcing the 300-character message limit", () => {
    expect(normalizeMaintenanceText("🔧 Server\u0000 Under Maintenance\n\nPlease wait… ⏳", 300)).toBe("🔧 Server Under Maintenance\n\nPlease wait… ⏳");
    const unicodeMessage = "अ".repeat(300);
    expect(normalizeMaintenanceText(unicodeMessage, 300)).toBe(unicodeMessage);
    expect(() => normalizeMaintenanceText("x".repeat(301), 300)).toThrow("300");
    expect(() => normalizeMaintenanceText("अ".repeat(301), 300)).toThrow("300");
  });

  it("evaluates enabled UTC schedule windows without participating in validation decisions", () => {
    const base = { enabled: true, message: "Please wait", startAt: new Date("2026-08-20T11:00:00.000Z"), endAt: new Date("2026-08-20T13:00:00.000Z") };
    expect(isMaintenanceActive(base, now)).toBe(true);
    expect(isMaintenanceActive({ ...base, startAt: new Date("2026-08-20T12:01:00.000Z") }, now)).toBe(false);
    expect(isMaintenanceActive({ ...base, endAt: new Date("2026-08-20T11:59:59.000Z") }, now)).toBe(false);
  });

  it("returns only an active presentation payload with the exact configured title and message", () => {
    const active = toMaintenancePayload({ id: 1, version: 4, enabled: true, title: "🔧 Server Under Maintenance", message: "Please wait... ⏳", startAt: new Date("2026-08-20T11:00:00.000Z"), endAt: new Date("2026-08-20T13:00:00.000Z"), updatedByUserId: 7, createdAt: now, updatedAt: now }, now);
    expect(active).toMatchObject({ active: true, version: 4, title: "🔧 Server Under Maintenance", message: "Please wait... ⏳" });
    expect(toMaintenancePayload({ id: 1, version: 4, enabled: false, title: "Title", message: "Message", startAt: null, endAt: null, updatedByUserId: 7, createdAt: now, updatedAt: now }, now)).toEqual({ active: false });
  });
});
