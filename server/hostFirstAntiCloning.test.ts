import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const source = readFileSync(resolve(process.cwd(), "BRPlayerCharacterBase-Merged.lua"), "utf8");
const resolver = source.slice(source.indexOf("local function normalize_device_identity"), source.indexOf("local function read_saved_key_for_popup"));

describe("Option A host-first anti-cloning resolver", () => {
  it("preserves an existing legacy local binding before selecting a fresh host identity", () => {
    expect(resolver).toContain('local existing = normalize_device_identity(read_file(DEVICE_FILE))');
    expect(resolver).toContain("if existing then return existing end");
    expect(resolver.indexOf("if existing then return existing end")).toBeLessThan(resolver.indexOf("local host_identity = get_host_phone_device_id()"));
  });

  it("uses the Android-proven Client phone identity before generic providers or random fallback for fresh enrollment", () => {
    expect(resolver).toContain("return client.GetPhoneDeviceID");
    expect(resolver).toContain("local call_ok, value = pcall(candidate)");
    expect(resolver).toContain("local host_identity = get_host_phone_device_id()");
    expect(resolver.indexOf("local host_identity = get_host_phone_device_id()")).toBeLessThan(resolver.indexOf('local provider = rawget(_G, "getPersistentDeviceId")'));
    expect(resolver.indexOf('local provider = rawget(_G, "getPersistentDeviceId")')).toBeLessThan(resolver.indexOf("math.randomseed("));
  });

  it("keeps host identity in memory and preserves protected production boundaries", () => {
    expect(resolver).not.toContain("write_file(DEVICE_FILE, host_identity)");
    expect(resolver).not.toContain("print(host_identity)");
    expect(resolver).not.toContain("write_status(host_identity)");
    expect(source).toContain('API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(source).toContain('local STATUS_FILE = KEY_DIR .. "/.license_status"');
    expect(source).toContain("gate_server_maintenance(json, response, key, on_authorized)");
  });
});
