import { describe, expect, it } from "vitest";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

describe("A-to-B B-side stage diagnostic", () => {
  const source = readFileSync(resolve(process.cwd(), "AtoBCopiedStateBStageDiagnostic.lua"), "utf8");

  it("uses only B's copied-test key path and the existing canonical endpoint", () => {
    expect(source).toContain('local COPIED_TEST_KEY_FILE = KEY_DIR .. "/.a_to_b_test_key.json"');
    expect(source).toContain('local API_URL = "https://luapanel-8355ybgt.manus.space/api/license/validate"');
    expect(source).toContain('http_wrapper:RequestForLua(API_URL, "POST", headers, payload, 0, 0)');
  });

  it("reports fixed non-secret stages only", () => {
    expect(source).toContain('local RESULT_FILE = KEY_DIR .. "/.a_to_b_b_stage_diagnostic"');
    expect(source).toContain('report("B_OWN_IDENTITY_UNAVAILABLE")');
    expect(source).toContain('report("CANONICAL_REJECTED")');
    expect(source).toContain('report("CANONICAL_ACCEPTED")');
    expect(source).not.toContain('print(key)');
    expect(source).not.toContain('print(device_id)');
    expect(source).not.toContain('print(payload)');
    expect(source).not.toContain('print(data)');
  });

  it("does not create or overwrite identity, normal key, status, or production flow", () => {
    const executable = source
      .split("\n")
      .filter(line => !line.trimStart().startsWith("--"))
      .join("\n");
    expect(executable).not.toContain('io.open(DEVICE_FILE, "wb")');
    expect(executable).not.toContain('math.randomseed');
    expect(executable).not.toContain('io.open(NORMAL_KEY_FILE, "wb")');
    expect(executable).not.toContain('.license_status');
    expect(executable).not.toContain('run_authorized_main');
    expect(executable).not.toContain('MAINTENANCE_URL');
    expect(executable).not.toContain('ANNOUNCEMENT_URL');
    expect(executable).not.toContain('TELEGRAM_');
  });
});
