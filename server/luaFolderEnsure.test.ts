import { readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const projectRoot = path.resolve(import.meta.dirname, "..");
const mergedLoader = readFileSync(path.join(projectRoot, "BRPlayerCharacterBase-Merged.lua"), "utf8");

describe("approved LuaLicense folder ensure preflight", () => {
  it("uses only the Android-proven exact full-path Client writer and a fixed non-secret marker", () => {
    expect(mergedLoader).toContain('local FOLDER_ENSURE_FILE = KEY_DIR .. "/.lua_license_folder_ready"');
    expect(mergedLoader).toContain('local FOLDER_ENSURE_MARKER = "LUA_LICENSE_FOLDER_READY_V1"');
    expect(mergedLoader).toContain("return client.WriteFileAtPath");
    expect(mergedLoader).toContain("pcall(writer, FOLDER_ENSURE_FILE, FOLDER_ENSURE_MARKER)");
    expect(mergedLoader).toContain("local marker = read_file(FOLDER_ENSURE_FILE)");
    expect(mergedLoader).toContain("return marker == FOLDER_ENSURE_MARKER");
    expect(mergedLoader).not.toContain("CreateDirectory");
    expect(mergedLoader).not.toContain("MakeDirectory");
    expect(mergedLoader).not.toContain("DirectoryExists");
    expect(mergedLoader).not.toContain("os.execute");
    expect(mergedLoader).not.toContain("lfs.");
  });

  it("runs before the first status write and fails without invoking the status writer", () => {
    const ensureCall = mergedLoader.indexOf("if ensure_lua_license_folder() ~= true then");
    const firstStatusWrite = mergedLoader.indexOf('pcall(write_status, "LOADER_STARTED")');
    const storageStopStart = mergedLoader.indexOf("local function stop_folder_initialization()");
    const ensureStart = mergedLoader.indexOf("local function ensure_lua_license_folder()");
    const statusWriterStart = mergedLoader.indexOf("write_status = function(message)");

    expect(ensureCall).toBeGreaterThan(-1);
    expect(firstStatusWrite).toBeGreaterThan(ensureCall);
    expect(storageStopStart).toBeGreaterThan(-1);
    expect(ensureStart).toBeGreaterThan(storageStopStart);
    expect(statusWriterStart).toBeGreaterThan(ensureStart);

    const storageStopBlock = mergedLoader.slice(storageStopStart, ensureStart);
    const ensureBlock = mergedLoader.slice(ensureStart, statusWriterStart);
    expect(storageStopBlock).not.toContain("write_status(");
    expect(ensureBlock).not.toContain("key.json");
    expect(ensureBlock).not.toContain(".device_id");
    expect(ensureBlock).not.toContain(".license_status");
  });

  it("retains the existing validation endpoint, persistence paths, and post-validation gates", () => {
    expect(mergedLoader).toContain('API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(mergedLoader).toContain('KEY_DIR .. "/key.json"');
    expect(mergedLoader).toContain('DEVICE_FILE = KEY_DIR .. "/.device_id"');
    expect(mergedLoader).toContain('STATUS_FILE = KEY_DIR .. "/.license_status"');
    expect(mergedLoader).toContain("gate_server_maintenance(json, response, key, on_authorized)");
    expect(mergedLoader).toContain("fetch_active_announcement(validated_key)");
  });
});
