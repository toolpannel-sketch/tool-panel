import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

describe("A-to-B copied-state standalone diagnostic", () => {
  const source = readFileSync(resolve(process.cwd(), "AtoBCopiedLicenseStateDiagnostic.lua"), "utf8");

  it("uses the canonical endpoint and B-only copied test-key path", () => {
    expect(source).toContain('local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(source).toContain('local COPIED_TEST_KEY_FILE = KEY_DIR .. "/.a_to_b_test_key.json"');
    expect(source).toContain('mode == "A" and read_file(NORMAL_KEY_FILE) or copied_raw');
    expect(source).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)');
  });

  it("reports only non-secret fixed copied-state outcomes", () => {
    expect(source).toContain('local RESULT_FILE = KEY_DIR .. "/.a_to_b_copied_state_diagnostic"');
    expect(source).toContain('report(mode == "A" and "PASS" or "ACCEPTED")');
    expect(source).toContain('report("REJECTED")');
    expect(source).toContain('report("UNDETERMINED")');
    expect(source).not.toContain('print(key)');
    expect(source).not.toContain('print(device_id)');
    expect(source).not.toContain('print(payload)');
    expect(source).not.toContain('print(data)');
  });

  it("does not write or generate a device identity, normal key, status, or production flow", () => {
    const executable = source
      .split("\n")
      .filter(line => !line.trimStart().startsWith("--"))
      .join("\n");
    expect(executable).not.toContain('io.open(DEVICE_FILE, "wb")');
    expect(executable).not.toContain('math.randomseed');
    expect(executable).not.toContain('io.open(NORMAL_KEY_FILE, "wb")');
    expect(executable).not.toContain('.license_status');
    expect(executable).not.toContain('save_validated_key');
    expect(executable).not.toContain('run_authorized_main');
    expect(executable).not.toContain('MAINTENANCE_URL');
    expect(executable).not.toContain('ANNOUNCEMENT_URL');
    expect(executable).not.toContain('TELEGRAM_');
  });
});
